% ______ Решение ху HF(x,L)=0 относительно х шаблоне L1:h:L5 (вправо)
% ______ Исп-ся в fzero(dva). Возм переход через Т(смена io:1->2)
function X = Solv52fT(KZ,nT,n,c,dva,io,h,L1, q,x10,x20,Xot,Lot)
% x10, x20 -  прибл корни для i=1,2

global eVTs HFs ahis bJYIK
global Em100 
global io_

%_________________________1 Общие данные_______________________________ 
X   = nan(q,1); 
eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT}; 
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1); 

h2 = h+h;
L3 = L1+h2;
Lv = [L1 L1+h L3 L3+h L3+h2];   
[e1v e3v V2v T2v] = eVT( KZ, Lv.*Lv, dva);
Vev = sqrt(V2v)*Em100;      

e11=e1v(1);  e31=e3v(1);  V21=V2v(1);  Ve1=Vev(1);  T21=T2v(1);
e12=e1v(2);  e32=e3v(2);  V22=V2v(2);  Ve2=Vev(2);  T22=T2v(2);

io_1 = true; ah = ahi{io};  bv = bvs{io}; bn = bns{io};

if nT==1 || io==2,  KIN = @KIW2;
else                KIN = @KIN1Bz;  end

d   = x10-x20;
x01 = [x10-d; min(x10+d,Ve1)];
f1  =  HF(n,c,e11,e31,T21,V21,x01,ah,bv);  
x01 = KIN(n,c,e11,e31,T21,V21,x01,ah,bn,HF,Ve1,f1);
x1  = fzero(@(x) HF(n,c,e11,e31,T21,V21,x,ah,bn),x01);  
 
x02 = [x20-d; min(x20+d,Ve2)];
f2  =  HF(n,c,e12,e32,T22,V22,x02,ah,bv); 
x02 = KIN(n,c,e12,e32,T22,V22,x02,ah,bn,HF,Ve2,f2);  
x2  = fzero(@(x) HF(n,c,e12,e32,T22,V22,x,ah,bn),x02);

X(1) = x1;  X(2) = x2; 

%_____________________2 Цикл: поиск корней____________________________
i  = 3;
Xp = x2;
Lp = L1 - h;
L2 = Lv(2); % ДЛЭ для х2 в сторону отсечки по одной точке,Xot~=0, ТСВ5-7
x0ep = x1*Xot*(Lot-L1)/(x1*(L2-L1)+Xot*(Lot-L2));

while i <= q 
  e1 = e1v(i);  e3 = e3v(i);
  V2 = V2v(i);  T2 = T2v(i);  
  Ve = Vev(i); 
     
  x0e = extDLor(x1,x2,Xot, Lp-h,Lp,Lot);  % отличие от Solv15
  %hx  = abs(Xp-x0e); % точн зн на пред.шаге - экстрап.зн. на текущ.шаге
     
  if Xp == x0ep,  x0 = [x0e-AP;  x0e+AP];  %min(x0e+AP,Ve)]; 
  else
     dX = Xp-x0ep;
     AP = abs(dX);         % АбсПог на пред шаге
     AP2 = AP+AP;   
     if dX > 0,  x0 = [x0e-AP/2;    x0e+AP2]; %min(x0e+AP2,Ve)];
     else        x0 = [x0e-AP2-AP2; x0e];   end 
   end
     
  if io_1  && x0e*x0e > T2
     if x0(1)^2 < T2,  x0 = [x0e; x0e+AP2]; end 
     io_1 = false;  
     io = 2;     
     ah = ahi{io};  bn = bns{io};  bv = bvs{io};
  end  
                             % строка-отладка  
  %figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f  =  HF(n,c,e1,e3,T2,V2,x0,ah,bv);
  x0 = KIN(n,c,e1,e3,T2,V2,x0,ah,bn,HF,Ve,f);
  if ischar(x0),  X = ['Solv52fT-KIN-KIN1B ' x0];  return,end 
          
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);         
  catch ME, FL = -10;     end       % f(x0(1))*f(x0(2))>0                            
 
  if FL == 1             % К след(i+1-му) корню  
     X(i) = Xp;   x1 = x2;   x2 = Xp;  
     i    = i+1;
     x0ep = x0e;                      
     Lp   = Lp+h;
  else                 % Выход   
     X = sprintf(['Solv52fT: Корень не найден\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % цикла по i
io_= io;