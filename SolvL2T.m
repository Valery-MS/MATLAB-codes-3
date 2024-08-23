% ______ Решение ху HF(x,L)=0 относительно х для L=L1L:h:L9 влево
% nm1 = 2 (m >=2)
% Начинается с io==2. Возм изм io:2->1(переход корня через Т)
% Перескок мб только в ф-ции KIL*: когда итерации перескочили через горб
% В пр-ме же х0е опр-ся дост близким к Н-корню => if корень найден сразу
% т.е. без KIL, то он не явл перескоком. 
% => после fzero проверка на перескок не нужна
function X = SolvL2T(KZ,nT,n,c,dva,io,hL,L1L, q,x1,x2,x0ep,LZ1,Xf) 

% x1 = X(L1L), x2 = X(L1L-hL)
global infC stat %TSV vhea
global eVTs HFs ahis bJYIK
%global XEL LUNL LUR  %LUR - вх и вых арг-т
global LTE LTH
global qHF; qK1=0; qF1=0; km1=0;  qK2=0; qF2=0; km2=0;  sm=0;
mdm  = str2double(infC(3:4))-str2double(infC(9:10));
LTE = NaN;  LTH = NaN;

%_________________________ 1 Общие данные _______________________________ 
X   = nan(q,1);   % XEL = X;
eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT};
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1); 
io_2 = true;  ah  = ahi{io};  bv = bvs{io};  bn = bns{io};
[e1v e3v V2v T2v] = eVT( KZ, (L1L:-hL:LZ1).^2, dva);

%dXs=zeros(1,q);

%_____________________ 2 Цикл: поиск корней ____________________________ 
i  = 1; 
Xp = x2;
Lp = L1L+hL;
x0 = zeros(2,1);  xe = x0;
N = 3;  Nq = N*q;  Nq1 = Nq-1;  N1 = N-1; NqN = 2/(Nq-N); % нормировка AP
%dXp = Xp-x0ep;
KIL = @KIL22;
xmT1 = false;  xmT2 = false;

while i <= q 
  e1 = e1v(i);  e3 = e3v(i);  
  V2 = V2v(i);  T2 = T2v(i);  % при движ влево Ve не нужно
  %[e1 e3 V2 T2] = eVT( KZ, (Lp-hL)^2, dva);
     
  x0e = extDLfr ( x1,x2,Xf, Lp+hL,Lp );

  dX = Xp-x0ep;  %dXs(i)=dX;              
  AP   = abs(dX);             % АбсПог на пред шаге 
  AP_2 = AP/2;
  d = AP*(Nq1-N1*i)*NqN;
  if     dX > 0,  xe(1) = x0e-AP_2;  xe(2) = x0e+d;  
  elseif dX < 0,  xe(1) = x0e-d;     xe(2) = x0e+AP_2; 
  else            xe(1) = x0e;       xe(2) = x0e+AP; 
  end
  sa = (Xp+x0e)/2;
  if xe(1) <= sa,  xe(1) = sa;  end
  x0 = xe;
  
  if io_2
     xmT1 = x0(1)^2 < T2;    % x0<T
     if xmT1
        T = sqrt(T2);
        if x0(2) < T,   xmT2 = true;
           KIL = @KIL21; 
           io = 1;   ah = ahi{io};  bn = bns{io};   bv = bvs{io}; 
           T1 = T-2*d;
           if T1 < x0(1),  x0(1) = max(T1,sa); end
           x0(2) = min(T-d,(x0(1)+T)/2);   
        else
           x0(1) = T+d/2;  x0(2) = T+d;  
        end
     end
  end
                            % строка-отладка
  %figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('x0=%g %g',x0));grid
  f = HF(n,c,e1,e3,T2,V2,x0,ah,bv);
  
  qHFa = qHF;
  % След блок сделан без учета nT=2. Возм переделка в аналог KIW2B(Sol52)
  if f(2)<0
     h = x0(2)-x0(1);  h = h+h;
     C = x0(2);
     while true
        Cp = C;    C  = C+h;
        if HF(n,c,e1,e3,T2,V2,C,ah,bv) >= 0
           x0(1) = Cp;   x0(2) = C;  break
        end
        h = h+h;
     end    
  elseif f(1) > 0    % & f(2) >= 0
     x0 = KIL(n,c,e1,e3,T2,V2,x0,ah,bn,HF,Xf,f,x1,x2); 
     
     if ischar(x0)
         X = sprintf('SolvL2T:перескок io=%d i=%d\n%s',io,i,x0); return
     elseif io_2
        if isnan(x0(1)) %|| xmT1 && ischar(x0) % смена io
           if xmT2
              io = 2;   ah = ahi{io};  bn = bns{io};   bv = bvs{io}; 
              KIL = @KIL22; 
              x0(1) = T+d/2;  x0(2) = T+d;  
           else
              sm = i-1;
              io_2 = false;
              KIL = @KIL2; 
              io = 1;   ah = ahi{io};  bn = bns{io};   bv = bvs{io}; 
              x0 = xe;  % на случай, если х0=char
              if ~xmT1, T = sqrt(T2);  end
              T1 = T-2*d;
              if T1<x0(1), x0(1) = T1;   x0(2) = T-d;
              else         x0(2) = (3*xe(1)+T)/4; %if x0(2)>T, x0(2)=(3*xe(1)+T)/4;end     
              end
           end
           f = HF(n,c,e1,e3,T2,V2,x0,ah,bv);

           if f(2)<0
              h = x0(2)-x0(1);    h = h+h;
              C = x0(2);
              while true
                 Cp = C;  C = C+h;
                 if HF(n,c,e1,e3,T2,V2,C,ah,bv) >= 0
                    x0(1) = Cp;   x0(2) = C;  break
                 end
                 h = h+h;
              end  
           elseif f(1) > 0    % & f(2) >= 0
              x0 = KIL(n,c,e1,e3,T2,V2,x0,ah,bn,HF,Xf,f,x1,x2);    
              if ischar(x0)
                 X = sprintf('SolvL2T:переск в смену io->1 i=%d\n%s',i,x0); return
              elseif isnan(x0(1))
                 X = sprintf('SolvL2T:3-я смена io:2->1->2->1 i=%d',i); return
              end
           end   
        elseif xmT2 
           io_2 = false;
           KIL = @KIL2; 
           sm = i-1;
        end
     end
  end 
  
  k = qHF-qHFa;        % к-во обращений к ф-ции в KIN
  if k
     if io==1, qK1=qK1+1; qF1=qF1+k;  if k>km1, km1=k;end    
     else      qK2=qK2+1; qF2=qF2+k;  if k>km2, km2=k;end,end  
  end
  
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);
  catch ME, FL = -10;   end        % f имеет од знаки на концах x0                             

  if FL == 1                 % К след(i+1-му) корню    
     %if Xp < x2 || Xp > (Xf + x2+x2-x1)*0.5  
     %   X = sprintf('SolvL2T: переСКОК => надо испр алгоритм  i=%d io=%d',i,io);
     %   return
     %end   
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
     
     X(i) = Xp;  x1 = x2;  x2 = Xp;
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

stat(6:14,mdm) = [qK1;qF1;round(qF1/qK1);km1;  sm;  qK2;qF2;round(qF2/qK2);km2];