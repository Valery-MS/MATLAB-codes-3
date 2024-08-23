% ______ Решение ху HF(x,L)=0 относительно х для L=L1:h:L9 вправо
% nm1 = 2:   m >= 2 или n > 1
% io не изм, => без выч Т и сравнения Т < Х
% Срабатывает только при io=2
function X = SolvR2(KZ,nT,n,c,dva,io,hL,L6, q,x1,x2,x0ep,L9,Xot,Lot)

% x1 = X(L6), x2 = X(L6+hL)            
global infC stat %TSV vhea
global eVTs HFs ahis bJYIK
%global XER LUNR                %qLUR LUR LLUR - вх и МБ вых арг-т            
global LTE LTH
global Em100 Ep100 
global qHF; qK=0; qF=0; km=0;
mdm  = str2double(infC(3:4))-str2double(infC(9:10));
LTE = NaN;  LTH = NaN;

%______________________ 1 Общие данные _______________________________ 
X   = nan(q,1);   %XER = X;
eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT}; 
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1);
ah  = ahi{io};  bv  = bvs{io}; bn  = bns{io}; 
x0  = zeros(2,1);  
%[e1v e3v V2v T2v] = eVT( KZ, (L6:hL:L9).^2, dva);
%Vev = sqrt(V2v)*Em100;

%_____________________ 2 Цикл: поиск корней ____________________________  
i  = 1;
Xp = x2;
Lp = L6-hL;

while i <= q 
  %e1 = e1v(i);  e3 = e3v(i); 
  %V2 = V2v(i);  T2 = T2v(i);
  %Ve = Vev(i);
  [e1 e3 V2 T2] = eVT( KZ, (Lp+hL)^2, dva);
  Ve = sqrt(V2)*Em100;
     
  x0e = extDLor( x1,x2,Xot, Lp-hL,Lp,Lot);
  %hx  = abs(x0e - Xp); 

  dX  = Xp-x0ep;
  AP  = abs(dX);          % АбсПог на пред шаге 
  r   = Ve-x0e;   
  AP2 = AP+AP;
  if r > AP || r<0,  r = AP; end
  if     dX > 0,  x0(1) = x0e-r;          x0(2) = min(x0e+AP2,Ve);
  elseif dX < 0,  x0(1) = x0e-AP2-AP2;    x0(2) = x0e+r/2;
  else            x0(1) = max(x0e-AP,Xot*Ep100);  x0(2) = min(x0e+AP,Ve); 
  end
                               %строка-отладка  
  %figure;a_=x0(1)*(1-1e-16);b_=x0(2)*(1+1e-16);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f = HF(n,c,e1,e3,T2,V2,x0,ah,bv);
  
  qHFa = qHF;
  % След блок сделан без учета nT=2. Возм переделка в аналог KIW2B(Solv52)
  if f(2) < 0
     h = x0(2)-x0(1);
     C = x0(2);
     while true
        Cp = C;
        C  = max(C+h, Ve);
        if HF(n,c,e1,e3,T2,V2,C,ah,bv) >= 0
           x0(1) = Cp;   x0(2) = C; break
        end
        h = h+h;
     end     
  elseif f(1) > 0
     x0 = KIR2(n,c,e1,e3,T2,V2,x0,ah,bn,HF,Ve,f); 
  end
  
  k = qHF-qHFa;       % к-во обращений к ф-ции в KIN
  if k
     qK=qK+1; qF=qF+k;  if k>km, km=k;end    
  end 
               
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);
  catch ME, FL = -10;   end        % f имеет од знаки на концах x0                      

  if FL == 1                 % К след(i+1-му) корню    
     if Xp > x2 || Xp < x2-2*(x1-x2)
        X = sprintf('SolvR2: переСКОК i=%d => надо испр алгоритм',i);
        return
     end 
     %{ 
     % поиск Е-корня - временно
     hE = 10*abs((x0(2)-x0(1)));
     C  = min(x0);
     while C > Xot
        Cp = C;
        C  = C-hE;
        T  = sqrt(T2);
        if C < T
           LTE = Lp+hL;
        end  
        
        if HF(n,c,e1,e3,T2,V2,C,ah,bn) >= 0
           try XER(i) = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),[Cp; C]);
               break
           catch ME,    prib(['SolvR2\n' ME.message]);
           end
        else
           hE = hE+hE;
        end
     end     % конец поиска Е-корня 
     %}
     
     X(i) = Xp;   x1 = x2;  x2 = Xp;
     i    = i+1;
     x0ep = x0e;                   
     Lp   = Lp+hL;
  else                    % Выход   
     X = sprintf(['SolvR2: Корень не найден\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % цикла по i
%LUNR = X-XER;

stat(15,mdm) = io;
if qK,   stat(16:19,mdm) = [qK; qF; round(qF/qK); km];  end