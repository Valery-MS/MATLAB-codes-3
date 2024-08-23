% ______ Решение ху HF(x,L)=0 относительно х на шаблоне L1:h:L5 
% ______ начиная от L1 вправо nm1 = 1 
% ______ для fzero(dva)
function X = Solv51f_(KZ,nT,n,c,dva,io,hL,L1, q,x10,x20)   

% io = io2, тк движение - вправо и L2 правее(>) L1
% x10,x20 - начальные приближения для L1,L2
%global TFL  infC  %stat1 vhea
global eVTs HFs ahis bJYIK
global Em100
global io_
%________________________ 1 Общие данные ________________________________ 
X   = nan(q,1); 
eVT = eVTs{nT};
HF  = HFs{ nT};
ahi = ahis{nT};
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1);  

h2 = hL+hL;
L3 = L1+h2;
Lv = [L1 L1+hL L3 L3+hL L3+h2];
[e1v e3v V2v T2v] = eVT( KZ, Lv.*Lv, dva);
Vev = sqrt(V2v)*Em100;      % раньше было V2 = V^2, чтобы V^2=V2 точно     

e11=e1v(1);  e31=e3v(1);  V21=V2v(1);  Ve1=Vev(1);  T21=T2v(1);
e12=e1v(2);  e32=e3v(2);  V22=V2v(2);  Ve2=Vev(2);  T22=T2v(2);

ah = ahi{io};  bv = bvs{io};  bn = bns{io};

d   = x10-x20;
x01 = [x10-d; min(x10+d,Ve1)];
f1  = HF(n,c,e11,e31,T21,V21,x01,ah,bv);  
if f1(1)*f1(2)> 0
   if nT==1 || io==2, x01 = KIN1( n,c,e11,e31,T21,V21,x01,ah,bn,HF,Ve1,f1);
   else               x01 = KIN1B(n,c,e11,e31,T21,V21,x01,ah,bn,HF,Ve1,f1);
   end
   if ischar(x01),  X=sprintf('Solv51f nT=%d io=%d i=1/n%s',nT,io,x01);end
end
x1 = fzero(@(x) HF(n,c,e11,e31,T21,V21,x,ah,bn),x01); 

x02 = [x20-d; min(x20+d,Ve2)];
f2  = HF(n,c,e12,e32,T22,V22,x02,ah,bv);
if f2(1)*f2(2)>0    
   if nT==1 || io==2, x02 = KIN1( n,c,e12,e32,T22,V22,x02,ah,bn,HF,Ve2,f2);
   else               x02 = KIN1B(n,c,e12,e32,T22,V22,x02,ah,bn,HF,Ve2,f2);
   end  
   if ischar(x02),  X=sprintf('Solv51f nT=%d io=%d i=2/n%s',nT,io,x02);end
end
x2 = fzero(@(x) HF(n,c,e12,e32,T22,V22,x,ah,bn),x02);

X(1) = x1;  X(2) = x2;
%tX = x1*eps100;                % чувствительность по Х для х0

%_____________________ 2 Цикл: поиск корней ____________________________
FL = 4;     
i  = 3;
Xp = x2;
x0ep = x1*L1/Lv(2);  % ДЛЭ в сторону отсечки по одной точке ТСВ4-86

while i <= q 
   if FL == 4 %FL < = 8 || FL >= 20 % при 1-м входе или переходе к след т.
     e1 = e1v(i);  e3 = e3v(i);
     V2 = V2v(i);  T2 = T2v(i);  
     Ve = Vev(i); 
     
     x0e = extDLor1(x1,x2);  % extDLor1 | extDLor  or=Отсеч-Равномер
     %hx  = abs(Xp-x0e); % точн зн на пред.шаге - экстрап.зн. на текущ.шаге
     
     if Xp == x0ep,  x0 = [x0e-AP; x0e+AP]; % min(x0e+AP,Ve)]; 
     else
        dX = Xp-x0ep;
        AP = abs(dX);         % АбсПог на пред шаге
        AP2 = AP+AP;   
        if dX > 0,  x0 = [x0e; x0e+AP2]; %[x0e-AP/2; min(x0e+AP2,Ve)];
        else        x0 = [x0e-AP2-AP; x0e];   end 
     end
   end
  
  %строка-отладка  
  %figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f = HF(n,c,e1,e3,T2,V2,x0,ah,bv);
  if f(1)*f(2)>0
     if nT==1 || io==2, x0 = KIN1( n,c,e1,e3,T2,V2,x0,ah,bn,HF,Ve,f);
     else               x0 = KIN1B(n,c,e1,e3,T2,V2,x0,ah,bn,HF,Ve,f); 
     end
     if ischar(x0)
        X=sprintf('Solv51f nT=%d io=%d i=%d/n%s',nT,io,i,x0); return
     end      
  end
               
  if FL==4 || FL==5 %|| FL==6 || FL==7
     try   [Xp,~,FL,out] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);        
     catch ME, FL = -10;           % f(x0(1))*f(x0(2))>0
     end         
  end                   

  if FL == 1               % К след(i+1-му) корню  
     X(i) = Xp;  x1 = x2;   x2 = Xp;  
     i    = i+1;
     x0ep = x0e;                    
     FL   = 4;   
  else                       % Выход   
     inf = sprintf(['Solv51: Корень не найден FL=%d\ni=%d  Ve=%g\n' ...  
           'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g]'],...
           FL,i,Ve, x0(1), x0(end), f(1), f(end));
      
     if FL==-10,  X = sprintf('%s\n%s\n', ME.message, inf); 
     else         X = sprintf('%s\n%s\n', out.message, inf); end 
     return 
  end
end % цикла по i
io_= io;