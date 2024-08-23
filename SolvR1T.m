% ______ Решение ху HF(x,L)=0 относительно х для L=L1:hL:L9 вправо
% ______ nm1=1. Возм переход через Т
% Не срабатывает вообще! Т.е. смены io нет.
function X = SolvR1T(KZ,nT,n,c,dva,~,hL,L6, q,x1,x2,x0ep,LZ2)   


global stat 
global eps100  Em100 
global eVTs  HFs ahis bJYIK
global qHF;  qK1=0; qF1=0; km1=0;  qK2=0; qF2=0; km2=0; sm=0;

%_________________________1 Общие данные_______________________________ 
X   = nan(q,1);
eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT}; 
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1);
ah = ahi{1};  bv = bvs{1};  bn = bns{1}; 

[e1v e3v V2v T2v] = eVT( KZ, (L6:hL:LZ2).^2, dva);
Vev = sqrt(V2v)*Em100;

%L = L6-hL;
io_1 = true;  % io == 1
if nT==1,  KIN = @KIN1;
else       KIN = @KIN1B; end

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
  %hx  = abs(x0e - Xp); 
     
  if Xp == x0ep,  x0 = [max(x0e-AP,eps100);  min(x0e+AP,Ve)]; 
  else
     dX = Xp-x0ep;
     AP = abs(dX);         % АбсПог на пред шаге
     AP2 = AP+AP;   
     if dX > 0,  x0 = [x0e; min(x0e+AP2,Ve)];
     else        x0 = [x0e-AP2; x0e];   end 
  end
     
  if io_1  &&  x0e*x0e > T2
     if x0(1)^2 < T2,   x0 = [x0e; x0e+AP2]; end 
     io_1 = false;  
     sm = i;
     ah = ahi{2};     bn = bns{2};  bv = bvs{2};
     if nT==2, KIN = @KIN1B; end
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
     if io==1, qK1=qK1+1; qF1=qF1+k;  if k>km1, km1=k;end    
     else      qK2=qK2+1; qF2=qF2+k;  if k>km2, km2=k;end,end  
  end

  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);
  catch ME, FL = -10;   end    % f(x0(1))*f(x0(2))>0                     
 
  if FL == 1                % К след(i+1-му) корню    
     X(i) = Xp;    x1 = x2;  x2 = Xp;
     i    = i+1;
     x0ep = x0e;                     
  else                      % Выход   
     X = sprintf(['SolvR1T: Корень не найден\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % цикла по i

stat(20:28,1) = [qK1;qF1; round(qF1/qK1);km1;  sm;  qK2;qF2;round(qF2/qK2);km2];