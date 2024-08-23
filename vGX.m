% ____________Границы Х для 3 сл СВ________________________________
function GX = vGX( nT, n, c, XnkH, m9)
% KIN: корневой ин-л - это ин-л, содержащий корень х.ф.
HFos = { @HF_12o; @HF_12o; @HF_3o;  @HF_4o  };
HFfs = { @HF_13f; @HF_24f; @HF_13f; @HF_24f };
xxxs = { @xxx1;   @xxx2;   @abs;    @abs    }; 
                  % abs нужны, чтобы в KINs опр-ть режим: отсечка или даль
koro = XOF( HFos{nT}, xxxs{nT}, n, c, m9, XnkH);
if ischar(koro), GX = koro; return,end

knan = length( find( isnan(koro) ) );
if knan
   GX = [ sprintf(...
   'Найдено %d корней отсечки вместо %d,\n тк задан малый отрезок Х:\n',...
   m9-knan,m9) sprintf('%g  ',koro)];  return
end

korf = XOF( HFfs{nT}, [], n, c, m9, XnkH );
if ischar(korf)
   GX = ['Корни в отсечке найдены\n' sprintf('%g  ',koro) ...
        '\nв дальн.зоне - нет\n' korf ]; return
end

knan = numel(find(isnan(korf)));
if knan 
   GX = ['Корни в отсечке найдены\n' sprintf('%g  ',koro) ...
   sprintf('\nВ дальн.зоне найдено %d корней из %d:\n', m9-knan,m9)...
   sprintf('%g  ',korf)];  return
end
GX = [koro korf]; 
%if n == 1,  vGX = [[0; koro(1:end-1)] korf];
%else        vGX = [koro korf];  end

% Зн-я Х для Оts и Far-режимов(правые края лунок(т.е Н-корней) 
% Лунка - это пара Е- и Н-корней х.ф-ции HF для данного m
%________________________________________________________________________
function kor = XOF( f, xxx, n, c, m9, XnkH)

global  eew
GGX = XnkH(1:2);            
fna = func2str(f); 
zag = sprintf('%s  n=%d  m=[1 %d] c=%g', fna, n, m9, c);
%                       ВЫБОР П-РОВ
subplot(1,1,1)
kor = nan(m9,1);    
H   = XnkH(3);           
e1  = eew(1);       e3 = eew(2);    e1_3 = e1-e3;
u1  = (e1-1)/e1_3;  u3_= (1-e3)/e1_3;  
first = true;
j0  = 3;
i0  = 0;                % нач зач счетчика корней

if n == 1 && isa(xxx,'function_handle'),  d = 1;  kor(1) = 0;
else                                      d = 0;  end
qK = m9-d; 
iX = nan(1,qK);

while true
   X  = (GGX(1) : H : GGX(2)+H/2)';    
   qX = numel(X);
   Y  = f( n, c, X, e1, e3, u1, u3_, xxx, 2); % nv=2: JYIK для в-ров
   plot( X,Y,'r');
   titlab(zag, {'X',fna});
   
   if first, first = false;
      Plus = length(Y(Y>0));       % sigY - преобладающий знак ф-ции 
      if Plus > qX-Plus,  sigY = 1;
      else                sigY = -1; end
   end 
   
   Up = Y(2) > Y(1);
   Uk = sigY==1;       % условие, при совпадении U с к-м, находится j:
   i  = i0;            % Х(j) - область корня 
   j  = j0;
   while j <= qX && i < qK     % считаем к-во корней графика Y(X)
      U  = Y(j)>Y(j-1);
      if Up ~= U
         Up  = U; 
         if U == Uk
            i = i+1;
            iX(i) = j;   % индекс j массива Х: i-й корень ~ Х(j) 
         end 
      end
      j = j+1;
   end
      
   if i < qK
      GGX(2) = GGX(2)*m9/i;
      j0 = j;
      i0 = i;
   else break
   end
end

if fna(end) == 'o',  rej = 'отсечке';
else                 rej = 'дальнем режиме';  end
prib('Х.функция в %s\nДальше', rej);

for i = 1:qK 
   j = iX(i);
   if Y(j)*sigY < 0
      s = j+1;
      while Y(s)*sigY < 0, s = s+1; end
      ab = X(s-1:s);
   elseif Y(j-1)*sigY < 0
      ab = X(j-1:j);
   else
      ab = KIN_pend( n,c, X(j-2:j), Y(j), e1,e3, u1,u3_, xxx, f);
      if ischar(ab)
         J = [j-2 j];
         kor = sprintf(['KIN_pend: корень не найден\n' ...
               'X(%d %d)=[%.5g %.5g], Y(X)=[%.5g %5g]'],J,X(J),Y(J));
              
         [H X Y] = podborH( zag,H,n,c, X(j-3:end), Y(j-3:end),...
                            e1, e3, u1, u3_, xxx, f ); 
         return
      end       
   end       
      
   if numel(ab)==1, kor(i+d) = ab;
   else
      try kor(i+d) = fzero(@(x) f(n,c,x,e1,e3,u1,u3_,xxx,1), ab);
      catch ME,  kor = ME.message;  return 
      end
   end   
end  % i
 
%______поиск Корн интервала ХC, содержащего корень, методом маятника___
function ab = KIN_pend( n,  c, AB, fB, e1, e3, u1, u3_, xxx, f)
                        
A   = AB(1);     S  = AB(2);     B  = AB(3);
sig = sign(fB);  h  = (B-A)*0.25;
C   = B-h;       Ce = C*eps;

fC  = f(n,c,C,e1,e3,u1,u3_,xxx,1);     % nv=1: JYIK для числа
if fC*sig < 0,  ab = [C B];  return    % ТСВ2-л.67
end

if fC == 0    
   if f(n,c,C-Ce,e1,e3,u1,u3_,xxx,1)*sig < 0,  ab = C;  
   else                                        ab = [C+Ce B];  end
   return
end

C  = A+h;
fC = f( n, c, C, e1, e3, u1, u3_, xxx, 1 );  
if fC*sig < 0,   ab = [C S];      return
end

if fC == 0
   if f(n,c,C-Ce,e1,e3,u1,u3_,xxx,1)*sig < 0,   ab = C;  
   else                                         ab = [C+Ce S];  end
   return
end

C  = B+h/2;
ahd2 = 0.5*h;
h  = -h;   
fC = fB;
first = true;
while abs(h) > eps
   fp = fC; 
   C  = C+h;
   fC = f( n, c, C, e1, e3, u1, u3_, xxx, 1);     
   if fC*sig < 0            
      ab = [C C+ahd2]; 
      return
   elseif fC == 0
      if f(n,c,C-Ce,e1,e3,u1,u3_,xxx,1)*sig < 0, ab = C;     
      else                                       ab = [C+Ce C+ahd2]; end
      return
   elseif abs(fC) > abs(fp)        % поворот
      if first,  h = -h;  first = false;
      else       h = -0.5*h;  end
      hd2 = 0.5*h;  ahd2 = abs(hd2);
      C   = C-hd2;
   end
end
ab = '';

%__________ Выч ХФ в отсечке и дали для разных nT ___________________
%__________ ХФ для nT=1|2 в отсечке _________________________________
function f = HF_12o( n, c, x, e1, e3, u1, u3_, xxx, nv)
% MatCad-10.Упрощ.(9)
% В отсечке для nT =1|2: x12z > 0 и x22z > 0
global  J1 DJ1  J2c Y2c   J2 Y2   DJ2c DY2c 
JJYo = {@JJYon @JJYov};
[cx1 cx2 x2] = xxx( c, x, u3_);
%JD1(n,cx1);            % JJY
%JYD2ot(n,cx2,x2);
JJYo{nv}( n, cx1, cx2, x2)

A2 = cx2.*J1;    A1 = cx1.*DJ1*u3_;   u  = J1.*u1; 
a2 = A2.*DJ2c;   a1 = A1.*J2c;        r1 = u.*J2c;  
b2 = A2.*DY2c;   b1 = A1.*Y2c;        r2 = u.*Y2c;

f = HF3o( n, e1, e3, a1, a2, b1, b2, r1, r2, J2, Y2 );

%_______ Отсечка: nT=1, иксы - числа(скаляры), доп: x2^2 > 0, т.е.KO=[1 1] 
function JJYon( n, cx1, cx2, x2)
global J1 DJ1    J2c DJ2c  J2    Y2c DY2c  Y2
N    = [n n-1 n+1];    

xJ   = [cx1; cx2];
J    = besselj( [N; N], [xJ xJ xJ]);
J1   = J(1,1);
DJ1  = 0.5*(J(1,2) - J(1,3));
J2c  = J(2,1);
DJ2c = 0.5*(J(2,2) - J(2,3));
J2   = besselj(n,x2);

Y    = bessely( N, cx2);
Y2c  = Y(1);
DY2c = 0.5*(Y(2) - Y(3));
Y2   = bessely(n,x2);

%______ Отсечка: nT=1, иксы - векторы-столбцы, доп: x2^2 > 0, т.е.KO=[1 1]
function JJYov( n, cx1, cx2, x2)
global J1 DJ1 J2c DJ2c  Y2c DY2c  J2 Y2
N     = [n n-1 n+1];
qx    = numel(cx1);
NN    = N( ones(qx,1),:);
ones3 = [1 1 1];

cx1m = cx1(:, ones3);      % создание meshgrid-м-цы
J    = besselj( NN, cx1m);     
J1   = J(:,1);
DJ1  = 0.5*(J(:,2) - J(:,3));

cx2m = cx2(:, ones3);
Jc   = besselj( NN, cx2m);
J2c  = Jc(:,1);
DJ2c = 0.5*(Jc(:,2) - Jc(:,3));

J2   = besselj( n, x2);

Yc   = bessely( NN, cx2m);
Y2c  = Yc(:,1);
DY2c = 0.5*(Yc(:,2) - Yc(:,3));

Y2  = bessely( n, x2);

%________ Выч cx1 cx2 x2  для nT=1 ________________________________
function [cx1 cx2 x2] = xxx1( c, x, u3_)  % x1 > x2
cx1 = c*x;       x2 = x*sqrt(u3_);  cx2 = c*x2;   
%______________________ для nT=2 ________________________________
function [cx1 cx2 x2] = xxx2( c, x, u3_)  % x1 < x2
cx2 = c*x;       cx1 = cx2/sqrt(u3_);  x2 = x;   

%___________ ХФ для nT=3 в отсечке _______________________________________
function f = HF_3o( n, c, x, e1, e3, u1, u3_, ~,nv)
global  J1 DJ1  J2c Y2c   J2 Y2   DJ2c DY2c 
JIKo = {@JIKon @JIKov};
cx1 = c*x;   
x2  = x*sqrt(-u3_); 
cx2 = c*x2;
%JD1(n,cx1);              %  JIK
%IKD2ot(n,cx2,x2);
JIKo{nv}( n, cx1, cx2, x2)

wc_ = Y2c./J2c;      
a2  = J1.*cx2.*DJ2c./J2c;   a1 = cx1.*DJ1*u3_;  r1 = J1.*u1;               
b2  = a2.*DY2c./DJ2c;       b1 = a1.*wc_;       r2 = r1.*wc_; 

f = HF3o( n, e1, e3, a1, a2, b1, b2, r1, r2, 1, Y2./J2);

%______Отсечка: nT=1, иксы - числа(скаляры), доп: x2^2 < 0, т.е. KO=[1 -1]
function JIKon(n,cx1,cx2,x2)
global J1 DJ1 J2c DJ2c  Y2c DY2c  J2  Y2 
N = [n n-1 n+1];
J = besselj( N, cx1);     
J1  = J(1);
DJ1 = 0.5*(J(2) - J(3));

I = besseli( N, cx2);
J2c  = I(1);
DJ2c = 0.5*(I(2) + I(3));
J2   = besseli(n,x2);

K = besselk( N, cx2);
Y2c  = K(1);
DY2c = -0.5*(K(2) + K(3));
Y2   = besselk(n,x2);

%_____ Отсечка: nT=1, иксы - векторы-столбцы, доп: x2^2 < 0, т.е. KO=[1 -1]
function JIKov(n,cx1,cx2,x2)
global J1 DJ1 J2c DJ2c  Y2c DY2c  J2  Y2
N     = [n n-1 n+1];
qx    = numel(cx1);
NN    = N( ones(qx,1),:);
ones3 = [1 1 1];

cx1m = cx1(:, ones3);      % создание meshgrid-м-цы
J    = besselj( NN, cx1m);     
J1   = J(:,1);
DJ1  = 0.5*(J(:,2) - J(:,3));

cx2m = cx2(:, ones3);
Ic   = besseli( NN, cx2m);
J2c  = Ic(:,1);
DJ2c = 0.5*(Ic(:,2) + Ic(:,3));

J2   = besseli(n,x2);

Kc   = besselk( NN, cx2m);
Y2c  = Kc(:,1);
DY2c = -0.5*(Kc(:,2) + Kc(:,3));

Y2   = besselk(n,x2);

%___________ ХФ для nT=4 в отсечке ______________________________________
function f = HF_4o( n, c, x, e1, e3, u1, u3_, ~,nv)
global  J1 DJ1  J2c Y2c   J2 Y2   DJ2c DY2c 
IJYo = {@IJYon @IJYov};
cx2 = c*x;
cx1 = cx2/sqrt(-u3_); 
%ID1(n,cx1);       %IJY
%JYD2ot(n,cx2,x);
IJYo{nv}(n,cx1,cx2,x)

j1 = -cx1.*DJ1./J1;            
a2 = cx2.*DJ2c;     a1 = j1.*J2c*u3_;  r1 = u1*J2c; 
b2 = cx2.*DY2c;     b1 = j1.*Y2c*u3_;  r2 = u1*Y2c;     

f = HF3o( n, e1, e3, a1, a2, b1, b2, r1, r2, J2, Y2);  

%_______Отсечка: nT=2, иксы - числа(скаляры), KO=[1 -1] ______________
function IJYon(n,cx1,cx2,x2)
global J1 DJ1   J2c DJ2c  J2    Y2c DY2c  Y2 
N   = [n n-1 n+1];
I   = besseli(N, cx1);     
J1  = I(1);
DJ1 = 0.5*(I(2) + I(3));

J    = besselj( N, cx2);
J2c  = J(1);
DJ2c = 0.5*(J(2) - J(3));
J2   = besselj(n,x2);

Y    = bessely( N, cx2);
Y2c  = Y(1);
DY2c = 0.5*(Y(2) - Y(3));
Y2   = bessely(n,x2);

%_______Отсечка:  nT=2, иксы - векторы, KO=[1 -1]_______________________
function IJYov(n,cx1,cx2,x2)
global J1 DJ1   J2c DJ2c  J2  Y2c DY2c  Y2
N     = [n n-1 n+1];
qx    = numel(cx1);
NN    = N( ones(qx,1),:);
ones3 = [1 1 1];

cx1m = cx1(:, ones3);      % создание meshgrid-м-цы
I   = besseli( NN, cx1m);     
J1  = I(:,1);
DJ1 = 0.5*(I(:,2) + I(:,3));

cx2m  = cx2(:, ones3);
Jc    = besselj( NN, cx2m);
J2c   = Jc(:,1);
DJ2c  = 0.5*(Jc(:,2) - Jc(:,3));

J2   = besselj(n,x2);

Yc   = bessely( NN, cx2m);
Y2c  = Yc(:,1);
DY2c = 0.5*(Yc(:,2) - Yc(:,3));

Y2   = bessely(n,x2);

%________Завершающее выч хф в отсечке _____________________________
function f = HF3o( n, e1, e3, a1, a2, b1, b2, r1, r2, Z1, Z2 )
a  = a2-a1;       a_= a2-a1*e1; 
b  = b2-b1;       b_= b2-b1*e1;
rZ = r1.*Z2 - r2.*Z1;
f  = ( a.*Z2 - b.*Z1 ).*(a_.*Z2 - b_.*Z1) - (n*n*e3)*(rZ.*rZ);

% ___________ частный вар-т HF для nT=1|3 в far-области _________________
% MatCad-10.Упрощ.(7)
function f = HF_13f( n, c, x, ~,~,~,~,~,nv)
cx1 = c*x; 
N   = [n n-1 n+1];
if nv == 1
   J = besselj( N, cx1);  
   f = (0.5*(J(2) - J(3)))^2-(n*J(1)/cx1)^2; 
else   
   qx   = numel(cx1);
   NN   = N( ones(qx,1),:);

   cx1m = cx1(:, [1 1 1]);      % создание meshgrid-м-цы
   J    = besselj( NN, cx1m);     
   f = (0.5*(J(:,2) - J(:,3))).^2 - (n*J(:,1)./cx1).^2;
   % проверить, что быстрее
   %f = DBF(1, @besselj, n ,cx1).^2-(n*besselj(n,cx1)./cx1).^2; 
end

% ___________ частный вар-т HF для nT=2|4 в far-области _________________
function f = HF_24f( n, c, x, ~,~,~,~,~,nv)
% MatCad-10.Упрощ.(8)
% n, c, x, KZ, dvapi, NAG2, iNA, xxx - арг в HF_12o
global J2c Y2c J2 Y2 DJ2c DY2c DJ2 DY2
JYf = {@JYfn @JYfv};
x2  = x;             
cx2 = c*x2;    
JYf{nv}(n,cx2,x2)

xx = cx2.*x2; 
f=  (n*(J2 .*Y2c - J2c.*Y2 )).^2 - (cx2.*(J2 .*DY2c - DJ2c.*Y2)).^2 - ...
  (x2.*(J2c.*DY2 - DJ2.*Y2c)).^2 + (xx .*(DJ2.*DY2c - DJ2c.*DY2)/n).^2 ...
+2*xx.*(J2 .*DY2 - DJ2.*Y2)     .*       (J2c.*DY2c - DJ2c.*Y2c);
 
%________иксы - числа(скаляры), доп: x2^2 > 0, т.е.KO=[1 1] 
function JYfn( n, cx2, x2)
global J2c DJ2c  J2 DJ2    Y2c DY2c  Y2 DY2 
N    = [n n-1 n+1];    

xJ   = [cx2; x2];
J    = besselj( [N; N], [xJ xJ xJ]);
J2c  = J(1,1);
DJ2c = 0.5*(J(1,2) - J(1,3));
J2   = J(2,1);
DJ2  = 0.5*(J(2,2) - J(2,3));

xY   = [cx2; x2];
Y    = bessely( [N; N], [xY xY xY]);
Y2c  = Y(1,1);
DY2c = 0.5*(Y(1,2) - Y(1,3));
Y2   = Y(2,1);
DY2  = 0.5*(Y(2,2) - Y(2,3));

%______иксы - векторы, доп: x2^2 > 0, т.е.KO=[1 1]
function JYfv(n,cx2,x2)
global  J2c DJ2c  J2 DJ2   Y2c DY2c  Y2 DY2
N     = [n n-1 n+1];
qx    = numel(cx2);
NN    = N( ones(qx,1),:);
ones3 = [1 1 1];

cx2m  = cx2(:, ones3);    % создание meshgrid-м-цы
Jc    = besselj( NN, cx2m);
J2c   = Jc(:,1);
DJ2c  = 0.5*(Jc(:,2) - Jc(:,3));

x2m  = x2(:, ones3);
J    = besselj( NN, x2m);
J2   = J(:,1);
DJ2  = 0.5*(J(:,2) - J(:,3));

Yc   = bessely( NN, cx2m);
Y2c  = Yc(:,1);
DY2c = 0.5*(Yc(:,2) - Yc(:,3));

Y   = bessely( NN, x2m);
Y2  = Y(:,1);
DY2 = 0.5*(Y(:,2) - Y(:,3));

%______________визуальный ПОДБОР шага H, когда КИН не найден______________
function [H X Y] = podborH( zag, H, n,  c, ...
                            X,   Y, e1, e3, u1, u3_, xxx, f)
while true
   plot(X,Y,'.b');
   grid on;  titlab(zag,{'x',zag(1:4)});  
   vH = H;
   vH = inpN( 'Прав кор( H ). Изм шаг H?', vH, {'H'}, 3, [eps 1], 1, NaN);
   if isempty(vH), break,end
   H = vH; 
   X = X(1) : H : X(end)+0.01*H;
   Y = f( n, c, X, e1, e3, u1, u3_, xxx, 2); 
end

%______________ 2-слойный световод ______________________________________
% _____________ выч Границ Х для СВ-2____________________________________
function GX2 = GraniX_12( KZ, n, L_2, m9 )
global nuliJ0 nuliJ1    
if     n == 1, GX2 = [[0; nuliJ1(1:end-1)]  nuliJ0];
elseif n > 1
               ee2 = n_2kZ( L_2, KZ(:,1)) / n_2kZ( L_2, KZ(:,2));
               Xot = vnJJX( n, m9, @JJX,(ee2-1)/(ee2+1));
               GX2 = [Xot  vnBF( @besselj, n-1, length(Xot))]; 
else               
               GX2 = [nuliJ0   nuliJ1];
end

% _____________выч Xотс: hf=Jn-2/Jn-1+(e1-1)/(e1+1)=0___________________
function Xot = vnJJX(n,QR,hf,del)
% Унгер,с.302 
Xot = nan(QR,1);  it  = 0;  
h   = 1;          i   = 1;
xa  = h;          hfa = hf(n,xa,del); 
xb  = 2*h;        hfb = hf(n,xb,del);       
while i <= QR
   while hfa * hfb > 0,
      hfa = hfb;  xb = xb+h;  hfb = hf(n,xb,del);  end
   try   [Xot(i),fv,FL,out] = fzero(@(x) hf(n,x,del),[xb-h xb]);
   catch ME, AT = sprintf('%s\nпри поиске %g-го корня',ME.message,i);
      if exist('fv','var')
         AT = [AT sprintf('\nf = %g, FL = %g\n%s',fv,FL,out.message)];
      end
      prie(AT);  
   end
   
   if FL < 0,  it = it+1;
   else        it = 0;    i = i+1;  end 
   
   if it > 20
      prie('20 итераций\nВместо %g найдено %g точек Xотс',QR,i-1);
      Xot(i:end) = [];  
      return
   end
   hfa = hfb;  xb = xb+h;  hfb = hf(n,xb,del);
end