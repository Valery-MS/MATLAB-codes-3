% ______ Решение ху HF(x,L)=0 относительно х для L=L1L:h:L9 влево
% nm1 = 2 (m >=2)
% Смены io нет, => без выч Т и сравнения Т < Х
% Не срабатывает вообще! Т.е. для m>=2 смены io есть всегда
function X = SolvL2(KZ,nT,n,c,dva,io,hL,L1L, q,x1,x2,x0ep,LZ1,Xf)   

% x1 = X(L1L), x2 = X(L1L-hL)                    
global infC  stat 
global eVTs HFs ahis bJYIK
%global XEL LUNLn LUR            %LUR -  вх и вых арг-т
global LTE LTH
global qHF;  qK=0; qF=0; km=0;
mdm  = str2double(infC(3:4))-str2double(infC(9:10));
LTE = NaN;  LTH = NaN;

%_________________________ 1 Общие данные _______________________________ 
X   = nan(q,1);  %XEL = X;
eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT};
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1); 
ah  = ahi{io};  bv  = bvs{io};  bn  = bns{io};

[e1v e3v V2v T2v] = eVT( KZ, (L1L:-hL:LZ1).^2, dva);

%dXs=zeros(1,q);

%_____________________ 2 Цикл: поиск корней ____________________________   
i  = 1; 
Xp = x2;
Lp = L1L+hL;
x0 = zeros(2,1);  
N = 3;  Nq = N*q;  Nq1 = Nq-1;  N1 = N-1; NqN = 2/(Nq-N); % нормировка AP
%dXp = Xp-x0ep;

while i <= q 
  e1 = e1v(i);  e3 = e3v(i);  
  V2 = V2v(i);  T2 = T2v(i);
  %[e1 e3 V2 T2] = eVT( KZ, (Lp-hL)^2, dva);
  
  x0e = extDLfr ( x1,x2,Xf, Lp+hL,Lp );  

  dX = Xp-x0ep;   %dXs(i)=dX;    
  AP   = abs(dX);             % АбсПог на пред шаге 
  AP_2 = AP/2;
  d = AP*(Nq1-N1*i)*NqN;
  if     dX > 0,  x0(1) = x0e-AP_2;  x0(2) = x0e+d;  
  elseif dX < 0,  x0(1) = x0e-d;     x0(2) = x0e+AP_2; 
  else            x0(1) = x0e;       x0(2) = x0e+AP;
  end
     %{
     d  = (dX+dX-dXp)/1.5;
     if     d>0, x0(1) = x0e;                                  x0(2) = x0e+d;
     elseif d<0, x0(1) = max(x0e+d,Xp+min(abs(dX),abs(dXp)));  x0(2) = x0e; 
     else        ad = abs(dX);  x0(1) = x0e-ad;                x0(2) =x0e+ad;  
     end
     dXp = dX;
     %}
                          % строка-отладка  
  %figure;a_=x0(1)*(1-1e-15);b_=x0(2)*(1+1e-15);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('x0=%g %g',x0));grid
  f = HF(n,c,e1,e3,T2,V2,x0,ah,bv);
  
  qHFa = qHF;
  % След блок сделан без учета nT=2. Возм переделка в аналог KIW2B(Solv52)
  if f(2)<0
     h = x0(2)-x0(1);
     h = h+h;
     C = x0(2);
     while true
        Cp = C;
        C  = C+h;
        if HF( n,c, e1,e3, T2,V2, C, ah,bv) >= 0
           x0(1) = Cp;  x0(2) = C;  break
        end
        h = h+h;
     end    
  elseif f(1) > 0
     x0 = KIL2(n,c,e1,e3,T2,V2,x0,ah,bn,HF,Xf,f,x1,x2); 
     if ischar(x0)
        X = sprintf('SolvL2: io=%d i=%d\n%s',io,i,x0); return
     end     
  end
  
  k = qHF-qHFa;       % к-во обращений к ф-ции в KIN
  if k
     qK=qK+1; qF=qF+k;  if k>km, km=k;end    
  end 
  
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);
  catch ME, FL = -10;   end        % f имеет од знаки на концах x0                        
 
  if FL == 1                                
     %{
     % поиск Е-корня
     hE = min(abs(x0(2)-x0(1)), hx);
     T  = sqrt(T2);     
     C  = min(x0);   
     ahE = ah;
     bnE = bn;
     firT = true;
     while true
        Cp = C;   
        C  = C-hE; % положительным (hE>0) считается напр влево
        if Xp > T && C < T && firT
           C  = T*(1+1e-6);
           Ce = C*(1+1e-6);
           ff = HF(n,c,e1,e3,T2,V2, [C;Ce], ah,bv);
           hE = -ff(1)*(Ce-C)/(ff(1)-ff(2));
           C  = C-hE;   % экстрапол по 2-м знач
           tX  = x1*1e-9; % чувствительность HF по Х при X~T уменьшать нельзя !
           % - возникает гиперосцилляция HF в ос точке
           Tm = T-10*tX;
           if C < Tm  || ff(1) < ff(2)  % смена io: 2->1 для E-корня
              LTE = Lp-hL;
              firT = false; 
              Cp  = Tm-tX;
              hE  = Xp-T;
              C   = Cp-hE;
              ahE = ahi{1};
              bnE = bns{1};
           end
        end
        F = HF(n,c,e1,e3,T2,V2,C,ahE,bnE);
        if F >= 0
           try
             XEL(i) = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ahE,bnE),[C; Cp]);
             break
           catch ME
             prib(['SolvL2\n' ME.message])
           end
        else
           hE = hE+hE; 
        end
     end     
     if i > 2
        if abs(XEL(i) -X(i)) <= 1e-6
           infC(3:4), i
        end
     end
     if any(isnan(XEL(1:i)))
        infC(3:4), i
     end
     % конец поиска Е-корня       
     %}
     
     X(i) = Xp;  x1 = x2;  x2 = Xp;   % К след(i+1-му) корню    
     Lp   = Lp-hL;
     i    = i+1;
     x0ep = x0e;                       
  else                        % Выход   
     X = sprintf(['SolvL2T: Корень не найден\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % цикла по i
%LUNL = X-XEL;

stat(1,mdm) = io;
if qK,   stat(2:5,mdm) = [qK; qF; round(qF/qK); km];  end