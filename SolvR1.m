% ______ Решение ху HF(x,L)=0 относительно х для L=L1:hL:L9 вправо
% ______ nm1=1 
% Срабатывает только при io=2
function X = SolvR1(KZ,nT,n,c,dva,io,hL,L6, q,x1,x2,x0ep,LZ2) 

% x1 = XC(4) = X(L5-hL) = X(L6-2hL)
% x2 = XC(5) = X(L5)    = X(L6-hL)

global stat 
global eVTs HFs ahis bJYIK
global eps100  Em100 
global qHF;  qK=0; qF=0; km=0;

%_________________________1 Общие данные_______________________________ 
X   = nan(q,1);
eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT}; 
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1);
ah  = ahi{io};  bv  = bvs{io}; bn  = bns{io}; 

[e1v e3v V2v T2v] = eVT( KZ, (L6:hL:LZ2).^2, dva); 
Vev = sqrt(V2v)*Em100;
%L = L6-hL;
if nT==1 || io==2,  KIN = @KIN1;
else                KIN = @KIN1B; end
x0 = zeros(2,1);  

%_____________________ 2 Цикл: поиск корней ____________________________  
i  = 1;
Xp = x2;

while i <= q 
  e1 = e1v(i);  e3 = e3v(i); 
  V2 = V2v(i);  T2 = T2v(i); 
  Ve = Vev(i);
  %L = L+hL;
  %[e1 e3 V2 T2] = eVT( KZ, L*L, dva); 
  %Ve = sqrt(V2)*Em100;
     
  x0e = extDLor1( x1,x2);   
     
  dX = Xp-x0ep;
  AP = abs(dX);         % АбсПог на пред шаге
  AP2 = AP+AP;   
  if     dX > 0,  x0(1) = x0e-AP/2;    x0(2) = min(x0e+AP2,Ve);
  elseif dX < 0,  x0(1) = x0e-AP2;     x0(2) = x0e; 
  else            x0(1) = max(x0e-AP,eps100);  x0(2) = min(x0e+AP,Ve); 
  end 
                           % строка-отладка  
  %figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f = HF(n,c,e1,e3,T2,V2,x0,ah,bv);
  
  qHFa = qHF;
  if f(1)*f(2)>0  % f1*f2>0 годится,тк Е-корня нет
     x0 = KIN( n,c,e1,e3,T2,V2,x0,ah,bn,HF,Ve,f); 
     if ischar(x0)
        X=sprintf('Solv51 nT=%d io=%d i=%d/n%s',nT,io,i,x0); return
     end 
  end
  
  k = qHF-qHFa;        % к-во обращений к ф-ции в KIN
  if k
     qK=qK+1; qF=qF+k;  if k>km, km=k;end    
  end
  
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);
  catch ME, FL = -10;   end % f(x0(1))*f(x0(2))>0
                            
  if FL == 1                % К след(i+1-му) корню    
     X(i) = Xp;    x1 = x2;  x2 = Xp;
     i    = i+1;
     x0ep = x0e;                     
  else                      % Выход   
     X = sprintf(['SolvR1: Корень не найден\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % цикла по i

stat(15,1) = io ;
if qK,   stat(16:19,1) = [qK; qF; round(qF/qK); km];  end