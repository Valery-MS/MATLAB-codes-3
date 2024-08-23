% ______ Решение ху HF(x,L)=0 относительно х шаблоне L1:h:L5 (вправо)
% ______ Исп-ся для XRS2
% Для i=1 ( в точке L1 ) io=1
% Для i=2 ( в точке L2, а => и в L3-L5 ) io=2
function X = Solv52C( nT, n,c, ~, h,L1, q,  x01,~,x02,f2, ...
                      xE1,xE2, Xot,Lot, e1v,e3v,V2v,T2v ) 
% ~,~ это io==1,  f1==1                
% xEi - Е-корень или прибл Е-КИН для Li
% x0i - прибл Н-КИН  для Li
% fi  = -1,0,1,2
 
global LURp LUR
global HFs ahis bJYIK %eVTs
global Em100 

%_________________________1 Общие данные_______________________________ 
X   = nan(q,1);   
%eVT = eVTs{nT};
HF  = HFs{ nT};
ahi = ahis{nT};
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1); 

%h2 = h+h;
%L3 = L1+h2;
%Lv = [L1 L1+h L3 L3+h L3+h2];
%[e1v e3v V2v T2v] = eVT( KZ, Lv.*Lv, dva);
Vev = sqrt(V2v)*Em100;      % раньше было V2 = V^2, чтобы V^2=V2 точно     
Tv  = sqrt(T2v);
e11=e1v(1);  e31=e3v(1);  V21=V2v(1);  Ve1=Vev(1);  T21=T2v(1);
e12=e1v(2);  e32=e3v(2);  V22=V2v(2);  Ve2=Vev(2);  T22=T2v(2);

io = 1; ah=ahi{io};  bv=bvs{io};  bn=bns{io};% f1==1, тк смена при переходе L1->L2

if nT==1,  KIN = @KIW2;
else       KIN = @KIN1Bz;  end

f1  =  HF(n,c,e11,e31,T21,V21,x01,ah,bv);      % io=1 и без проверки
x01 = KIN(n,c,e11,e31,T21,V21,x01,ah,bn,HF,Ve1,f1);   
x1  = fzero(@(x) HF(n,c,e11,e31,T21,V21,x,ah,bn),x01);    

io = 2; ah=ahi{io};  bv=bvs{io};  bn=bns{io};
if f2 ~= 0     %тк io=2, то прога KIN1B не нужна 
   f2  =   HF(n,c,e12,e32,T22,V22,x02,ah,bv);
   x02 = KIW2(n,c,e12,e32,T22,V22,x02,ah,bn,HF,Ve2,f2);
end
x2 = fzero(@(x) HF(n,c,e12,e32,T22,V22,x,ah,bn),x02);

X(1) = x1;  X(2) = x2;
LURp = LUR;
if     xE1>0,  LUR = x1-xE1;
elseif xE2>0,  LUR = x2-xE2;
else           LUR = 0;
end

%_____________________ 2 Цикл: поиск корней ____________________________ 
i  = 3;
Xp = x2;
L2 = L1+h;
Lp = L2;   % ДЛЭ для х2 в сторону отсечки по одной точке,Xot~=0, ТСВ5-7
x0ep = x1*Xot*(Lot-L1)/(x1*(L2-L1)+Xot*(Lot-L2));
x0 = [0;0];

while i <= q 
   e1 = e1v(i);  e3 = e3v(i);
   V2 = V2v(i);  T2 = T2v(i);  
   Ve = Vev(i);  T  = Tv(i);
     
   x0e = extDLor(x1,x2,Xot, Lp-h,Lp,Lot);  % отличие от Solv51
   %hx  = abs(Xp-x0e); % точн зн на пред.шаге - экстрап.зн. на текущ.шаге
    
   if Xp == x0ep,  x0 = [x0e-AP; x0e+AP]; % min(x0e+AP,Ve)]; 
   else
      dX = Xp-x0ep;
      AP = abs(dX);         % АбсПог на пред шаге
      AP2 = AP+AP;   
      if dX>0,  x0(1)=x0e-AP/2;  x0(2)=x0e+AP2;  %min(x0e+AP2,Ve)];
      else      x0(1)=x0e-AP2*2; x0(2)=x0e;   end 
   end

   if x0(1) <= T
      if LUR,  x0(1) = T+LUR; 
      else     x0(2) = T+AP/4; end
      x0(2) = T+AP; 
   end
                      % строка-отладка  
  %figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f  =  HF( n,c,e1,e3,T2,V2,x0,ah,bv);
  % здесь io=2,=> не надо рассм случай nT==2 && io==1, рассм-й в др прогах
  x0 = KIW2(n,c,e1,e3,T2,V2,x0,ah,bn,HF,Ve,f);
               
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);         
  catch ME, FL = -10;    end       % f(x0(1))*f(x0(2))>0
                            
  if FL == 1                 % К след(i+1-му) корню  
     X(i) = Xp;   x1 = x2;  x2 = Xp;
     i    = i+1;
     x0ep = x0e;                    
     Lp   = Lp+h;
  else                     % Выход   
     X = sprintf(['Solv52C: Корень не найден\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % цикла по i