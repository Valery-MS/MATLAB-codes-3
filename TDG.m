% _______3D-графика х.ф-ции______________________________________________
function TDG( Di,  QS,    ...
              L19, hL, KZ, nT, n,  c, ...
              GXm, m,  qX, ...
              dva, qL, NAma ) 
Vmax = 100;
SV = sprintf('%d-СВ, n=%d', QS, n);
if m == 1,  GXm(1) = 0.1;  end
qKur = 20;
P1  = [hL qL qX qKur];      

if Di,  SKL2 = [L19 100];    
else    SKL2 = [sqrt(dva)*NAma/L19(2) 100 100];  end
    
P2  = {SKL2; [GXm 100]; 20};
grX = [0.01 1000];
grK = [5 1e5];      
while true   
   switch MEN({SV,'Задать'},'Сетки д/заданного m','Сетки произвольные')
   case 1, P1 = inpN('П-ры сеток', P1,...
                     {'hL' 'qL' 'qX' 'qKur'}, [5 9 8 8],...
                     [ 1e-15 1; 5 500; 5 500; 0 300], 2:4, NaN);      
           SKL = [grVL( Di, dva, L19, P1(1), GXm(1), NAma, Vmax)  P1(2)];
           SKX = [GXm P1(3)]; 
           qKur = P1(4);
           
   case 2, P2 = inpU( 'Произв сетки', P2,...
                    { {'L1' 'L2' 'qL'}; {'X1' 'X2' 'qX'}; {'qKur'}},...
                    {[12 12 16] [12 19  8] 10}, ...
                    {[L19; L19; grK]; [grX; grX; grK]; [0 300]},...
                    'I{1}(1)<=I{1}(2) || I{2}(1)<=I{2}(2)',NaN);
           SKL = P2{1};
           SKX = P2{2};
           qKur = P2{3};
   case 0, return
   end 
   Grafs( Di, KZ, nT, n, c, SKL, SKX, dva, qKur);
end 

%________________ выч ГРаниц VL _____________________________________
function  VL19 = grVL( Di, dva, LZ, hVL, Xmin, NAma, Vmax) 
if Di, Lmax = min( LZ(2), sqrt(dva)*NAma/Xmin);     
       VL19 = [LZ(1), floor(Lmax/hVL)*hVL];    % округл с недост до 0.1
else   VL19 = [ceil(Xmin/hVL)*hVL, Vmax];      % округл с изб до 0.1 
end  

%_______ все Графики хф _____________________________________________
function Grafs( Di, KZ, nT, n, c, SKL, SKX, dva, qKur)
if Di, tVL = '\lambda';  else tVL = 'V';  end 
tmenu = { 'Поверхность', '0-уровни','Каркас1', 'Каркас2',...
         'контуры', 'Контуры+марк авт', 'Контуры+марк'};
     
txt = {'1 yel  Хг<XT Xд^2=Xг^2-T^2<0 => In,Kn' ...
       '2 cyan Хг>XT Xд^2>0          => Jn,Yn' ...
       '3 red  Хг>V => Х.ф-ция  не определена'};   
tit1 = sprintf('nT=%d, n=%d,  2a=%g',nT, n, sqrt(dva)/pi);

[VEP HF eT ahs bms] = vheab( nT, 3 );           
[e1 e3 V_2]         = VEP( KZ, [SKL(1)^2 SKL(2)^2], dva); 
X1 = SKX(1);
if X1*X1 > V_2(2)
   X1 = sqrt(V_2(2));  SKX(1) = X1;     % ТСВ3-18 расшир SX
end  
 
T2 = eT(e1,e3).*V_2;
if nT < 3
   X9 = SKX(2);
   Yq = X9*X9;
   Y1 = X1*X1;
   if     Yq < T2(2),  ios = 1;    % ТСВ3-15
   elseif Y1 > T2(1),  ios = 2;
   else                ios = [1 2];
   end
else                   ios = 1;
end

L  = setK(SKL)';  % дб строка
Q  = L.^2;
qo = numel(ios);
SX = setK( SKX ); % дб столбец
subplot(1,1,1)
Gfig = gcf;

[e1v e3v V2v] = VEP( KZ, Q, dva); 
T2v           = eT(e1v,e3v).*V2v;
L1  = SKL(1);    L9 = SKL(2); 
T   = sqrt(T2v);
V   = sqrt(V2v);

fig = figure('Name',tit1);             
fill( [L1 L9 L9 L1], [X1 X1 X9 X9], 'w')
hold       
T9 = T(end);
V1 = V(1);
fill( [L L1],    [T T9],    'y')
fill( [L L9 L1], [T V1 V1], 'c'); 
fill( [L L9],    [V V1],    'r');
if X1 > T9, fill( [L1 L1 L9 L9], [X1 T9 T9 X1], 'w');  end
if X9 < V1, fill( [L1 L1 L9 L9], [V1 X9 X9 V1], 'w');  end
plot( L,[T;V]) 
titlab( txt,{'\lambda' 'T,V'})
prib( 'Далее' ) 
T1  = T(1);
Lob = [1.1*L1  1.2*L1];
Xob = [1.2*X1  0.9*T1];
qL  = numel(L);

%[L2m Xm]        = meshgrid( Q, SX );        % meshgrid-м-цы(L,SX)
%[Lm Xm]         = meshgrid( L, SX );
%[e1m e3m V_2m ] = VEP( KZ, L2m, dva); 
%T2m             = eT(e1m,e3m).*V_2m;
%проверить и заменить: 8 нижних строк дб быстрее 3 верхних. - В 4 раза!

onesX = ones( numel(SX),1); 
e1m   = e1v ( onesX,:);
e3m   = e3v ( onesX,:);
V_2m  = V2v ( onesX,:);
T2m   = T2v ( onesX,:);
Lm    = L   ( onesX,:);
Xm    = SX  ( :, ones(1,numel(L)));
for io = ios                    % io - индекс области особенности    
   figure(fig)
   text( Lob(io), Xob(io), num2str(io),'FontSize',14,'color','k') 
   
   Z = HF( n, c, e1m, e3m, T2m, V_2m, Xm, ahs{io}, bms{io}); 
   
   if qo == 2                                % ТСВ3-19
      Tm = T( onesX,:);
      if io == 1,  Z( Xm > Tm ) = NaN;
      else         Z( Xm < Tm ) = NaN;  end
   end
   tit2 = sprintf('%s, сетка %dx%d %s',tit1, SKX(3), qL, txt{io});
                  
   while true
      me = MEN({sprintf('nT=%d',nT),'3D графики'},tmenu);
      figure(Gfig);
      if     me==1, surfc(    Lm, Xm, Z)
      elseif me==2, contour(  Lm, Xm, Z, [0 0],'k')
      elseif me==3, meshc(    Lm, Xm, Z)
      elseif me==4, meshz(    Lm, Xm, Z)   
      elseif me==5, contour3( Lm, Xm, Z, qKur)
      elseif me==6, [cHF,hHF]= contour3( Lm, Xm, Z);      clabel(cHF,hHF); 
      elseif me==7, [cHF,hHF]= contour3( Lm, Xm, Z,qKur); clabel(cHF,hHF);      
      elseif me==0, break
      end
      hidden off
      titlab( tit2, {tVL,'X'} ); 
   end
end
delete(fig)