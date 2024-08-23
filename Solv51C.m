% ______ Решение ху HF(x,L)=0 относительно х на шаблоне L1:h:L5 
% ______ начиная от L1 вправо nm1 = 1. Для XRS1
% Для i=1 ( в точке L1 ) io=1
% Для i=2 ( в точке L2 ) io=2
function X = Solv51C(nT,n,c,~,hL,L1, q,x01,f1,x02,f2,e1v,e3v,V2v,T2v) 

% io = io2, тк движение - вправо и L2 правее(>) L1
%global TFL  infC  %stat1 vhea
global HFs ahis bJYIK  %eVTs
global Em100
%________________________ 1 Общие данные _______________________________ 
X   = nan(q,1);       
%eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT};
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1); 
 
%h2 = hL+hL;
%L3 = L1+h2;
%Lv = [L1 L1+hL L3 L3+hL L3+h2];
%[e1v e3v V2v T2v] = eVT( KZ, Lv.*Lv, dva);
Vev = sqrt(V2v)*Em100;      % раньше было V2 = V^2, чтобы V^2=V2 точно     

e11=e1v(1);  e31=e3v(1);  V21=V2v(1);  Ve1=Vev(1);  T21=T2v(1);
e12=e1v(2);  e32=e3v(2);  V22=V2v(2);  Ve2=Vev(2);  T22=T2v(2);

io = 1; ah=ahi{io};  bv=bvs{io};  bn=bns{io};
if f1(1) ~= 0
   f1 = HF(n,c,e11,e31,T21,V21,x01,ah,bv);
   if f1(1)*f1(2)>0
      if nT==1, x01=KIN1( n,c,e11,e31,T21,V21,x01,ah,bn,HF,Ve1,f1);
      else      x01=KIN1B(n,c,e11,e31,T21,V21,x01,ah,bn,HF,Ve1,f1);
      end 
      if ischar(x01), X = ['Solv51C x01=' x01];  return,end 
   end
end    
x1 = fzero(@(x) HF(n,c,e11,e31,T21,V21,x,ah,bn),x01);     

io = 2; ah=ahi{io};  bv=bvs{io};  bn=bns{io};
if f2(1) ~= 0
   f2 = HF(n,c,e12,e32,T22,V22,x02,ah,bv);
   if f2(1)*f2(2)>0 % условие с KIN1B не реализ, тк io==2
      x02 = KIN1( n,c,e12,e32,T22,V22,x02,ah,bn,HF,Ve2,f2);
      if ischar(x02), X = ['Solv51C x02=' x02];  return,end        
   end
end
x2 = fzero(@(x) HF(n,c,e12,e32,T22,V22,x,ah,bn),x02);       

X(1) = x1;  X(2) = x2;

%_____________________ 2 Цикл: поиск корней ____________________________   
i  = 3;
Xp = x2;
x0ep = x1*L1/(L1+hL);  % ДЛЭ в сторону отсечки по одной точке, Xot=0,ТСВ4-86
% Мб точнее э-я x0ep=Xfa*x1*L1/((Xfa-x1)*Lv(2)+x1*L1); ТСВ5-24 ?
x0 = [0;0];

while i <= q 
  e1 = e1v(i);  e3 = e3v(i);
  V2 = V2v(i);  T2 = T2v(i);  
  Ve = Vev(i);  
     
  x0e = extDLor1(x1,x2);  % % отличие от Solv25
  %hx  = abs(Xp-x0e); % точн зн на пред.шаге - экстрап.зн. на текущ.шаге
     
  if Xp == x0ep,  x0 = [x0e-AP;  x0e+AP];   %min(x0e+AP,Ve)]; 
  else
     dX = Xp-x0ep;
     AP = abs(dX);         % АбсПог на пред шаге
     AP2 = AP+AP;   
     if dX>0,  x0(1)=x0e-AP/2;  x0(2)=min(x0e+AP2,Ve);
     else      x0(2)=x0e-AP2;   x0(2)=x0e;   end 
  end
  
  %строка-отладка  
  %figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f = HF(n,c,e1,e3,T2,V2,x0,ah,bv);
  if f(1)*f(2)>0    % io==2; поэтому KIN1B не нужно
     x0 = KIN1(n,c,e1,e3,T2,V2,x0,ah,bn,HF,Ve,f);
     if ischar(x0),  X = ['Solv51C ' x0];  return,end   
  end
  
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);         
  catch ME, FL = -10;    end       % f имеет од знаки на концах x0        

  if FL == 1           % К след(i+1-му) корню  
     X(i) = Xp;  x1 = x2;  x2 = Xp;
     i    = i+1;
     x0ep = x0e;                    
  else                 % Выход   
     X = sprintf(['Solv51C: Корень не найден\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % цикла по i