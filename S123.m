% ________выч дисперсий S1,S2,S3 и других дисп х-к______________________
function  UTO = S123( QS, LZ, hL, KZ, nT, n,c, GXmmm, mm, n_290, dvaX, dvaX1 )
% if UTO==0, завершение пр-мы нормальное,
% else      UTO = 'диагн.сообщение при Аварийном Выходе'
% (1:5+q,k,NM) = [m; dva; L1; L9; q; XL; xw; XR] - k-й столбец для NM
% dvaX(le1,m9) = hL

UTO = 0;     
SZ  = size(dvaX);
qm  = SZ(2);                     % к-во аз чисел m
vv  = false;
%if nKT >= 12,  vv = false;  else  vv = true;  end

m2as = cell(qm);

for i = 1:qm                   % m dva 
   m2as{i} = sprintf('%2d  %.5g', dvaX(1,i),sqrt(dvaX(4,i))/pi);
end

LZ1 = LZ(1);
LL0 = [LZ1 dvaX(2,1)];
LL  = LL0; 
sL0 = setH([LL0 hL]);
mmmi = mm(1):mm(2);        % рейндж mm, изменяемый в цикле
basa = mm(1)-1;
while true
   if ~vv,  vv = true;
   else    
      mL = {mmmi; LL}; 
      if length(mmmi) > 10,  mL{1} = mm;  end
      mL = inpU('Графики дисперсий', mL,...
           { {'!!азимутальные числа m1 : m9'}; {'L1'  'L9'} },...
           { 3 [10 10]}, { mm; [LL0; LL0] },...
           ['I{1}(1) <= I{1}(end) && all(mod(I{1},1)==0)' ...
            '&& I{2}(1) < I{2}(2)']);
      if prich(mL), break,end
      mmmi = mL{1};   LL  = mL{2};       
   end
   
   mmo = mmmi-basa;
   iL  = LL(1) <= sL0 & sL0 <= LL(2);  % возможное сужение ин-ла
   L   = sL0(iL);
   n_2 = n_290( iL,:);
   suzLe = L(1)-1e-10 > sL0(1);        % инт-л L СУЖен слева(LEft)
   L9s   = dvaX( 2, mmo);
   qLs   = dvaX( 3, mmo);
   dvas  = dvaX( 4, mmo);  
   Lots  = dvaX( 5, mmo);
   Xs    = dvaX( [false(5,1);  iL], mmo);  % только Х-ы, соотв-е iL   
   S     = v_S123( L, hL, n_2, dvas, Xs,  2, 0);

   UTO = shuto_S123( m2as(mmo),    QS, ...
                     KZ,   nT,     n,    L,    c, ...
                     GXmmm(mmo,:), mm,   n_2, ...
                     L9s,  qLs,    dvas, Lots, Xs, ...                     
                     S,    suzLe,  dvaX1);
   if ischar(UTO),   return,end
end

% ___________ Вычисление дисп х-к S123 __________________________________
function S = v_S123 (L, hL, n_2, dvas, Xs, id,ip) 
% S - дисп х-ки
% L   дб столбцом
% n_2 = n_290(iL,NM) : 2 столбца значений n^2 для слоев с max и min n^2

% Искл.т и-ла До дифф-я (id)   0  0  0    1  1  1    2  2  2
% Искл.т и-ла После DIFi(ip)   0  1  2    0  1  2    0  1  2
% cумма искл.в рез-те точек    0  1  2    1  2  3    2  3  4

SZ  = size (Xs);
qX  = SZ(1);
qm  = SZ(2);
NA_2 = n_2(:,1)-n_2(:,2);    % квадрат апертуры
S   = nan (qX,8,qm);  
L2 = L.*L;
for i = 1:qm   
   L2dva = L2/dvas(i);
   V_2 = NA_2./L2dva;
   Xi  = Xs(:,i);
   X2  = Xi.^2;
   nef = sqrt(n_2(:,1)-X2.*L2dva);              
   ngr = nef -DIFi(1, nef,     hL, 0, 0).*L; % ip=0, те исп 2 нецентр РС =>
   S(:,1,i) =-DIFi(2, nef,     hL, 0, 0).*L; % ngr и S1 опр во всех точках
   S(:,2,i) = DIFi(2, ngr,     hL,id,ip); 
   S(:,3,i) = DIFi(2, S(:,1,i),hL,id,ip);   
   S(:,1:3,i) = S(:,1:3,i)/0.299792458e-3;
               % X  nef ngr  Bef            Bgr             
   S(:,4:8,i) = [Xi nef ngr (V_2-X2)./V_2  (ngr.^2-n_2(:,2))./NA_2];
end
%_________SHow и УТОчнение дисп х-к S123_________________________________
function  UTO = shuto_S123 ( m2a,  QS,    ...
                             KZ,   nT,    n,    L,    c, ...
                             GXmm, mmG,   n_2,  ...
                             L9s,  qLs,   dvas, Lots, Xs, ...
                             S,    suzLe, dvaX1 )     
% m2a информация о: моде(n,m,NM) и dva 
Di  = 1;
UTO = 0;
Gra = {'Дисперсии',   'Эфф и групп х-ки', 'Отдельно',...
       '3D-график хф','Уточнение кривой', 'Выход'};
   
Otd = {'Дисперсия S1', 'Дисперсия S2', 'Дисперсия S3', 'X',  ...
       'n_э',          'n_г',          'B_э',          'B_г', 'Выход'};  
qidp = [0 0 0   1 1 1   2 2 2;...
        0 1 2   0 1 2   0 1 2]';
lab = {'\lambda',''}; 

me   = 1;
m    = mmG(1);
dm   = mmG(1)-1;     %  сдвиг по m
RL  = 1;             %  RL=1(2) вправо(влево)
hL   = L(2)-L(1);
Lend = L(end);
qL   = length(L);
qu0  = 3;            %  К-во т. Уточнения
qid  = 0; qip = 2; 
moda = ['HE' num2str(n)];
first = true;
tme  = sprintf('Графики %d-CB', QS);
while me && me~=6
   if first,  first = false;  me = 1;
   else       me = menu(tme, Gra);  end
   
   if     me==1, sp_S123(2,2, moda,m2a, Otd(1:4), lab,L, Lots, S(:,1:4,:));
   elseif me==2, sp_S123(2,2, moda,m2a, Otd(5:8), lab,L, Lots, S(:,5:8,:));
   elseif me==3   
      while true
         me1 = menu(Gra{3}, Otd);
         if me1 == 0 || me1 == 9,  break,end
         sp_S123( 1,1, moda, m2a, Otd(me1), lab, L, Lots, S(:,me1,:) );
      end    
   elseif me == 4  
      m_   = inpA(Gra{4}, m, 'm', 10, mmG, 1, NaN);  % m1 <= m_ <= m9
      mdm  = m_-dm;                                  % 1 <= mdm <= m9-dm
      dva_ = dvas( mdm );
      fig  = figure;
      NAma = sqrt( max( n_2(:,1)-n_2(:,2) ));
      TDG( Di,          QS,    ...
           L([1 end])', hL, KZ, nT, n, c, ...
           GXmm(mdm,:), m_, qL, ...
           dva_,        qL, NAma )
      prib('Построение 3-D графиков закончено')
      delete(fig)
   elseif me == 5  % Уточнение кривой
      mRL = inpN( Gra{5}, [m RL], {'m' '1-вправо, 2-влево'},...
                  [5 15], [mmG; 1:2], 1:2, NaN); 
              
      m   = mRL(1);     RL = mRL(2);   
      if n==1 && m==1,  nm1 = 1;  else nm1 = 2;  end
      a   = 1;             
      mdm = m-dm; 
      qLm = qLs(mdm);
      b   = qLm;
      Lot = Lots( mdm );  
      dva = dvas( mdm );
      GXm = GXmm( mdm, :);
      Xot = GXm(1);    Xf = GXm(2);
      
      if RL == 2
         if suzLe  
            prie('Для уточнения кривой Х слева ввести L1=Lmin'); break,end
      elseif Lend < L9s(mdm)-1e-10
         prie('Для уточнения кривой Х справа ввести L9=Lmax'); break
      end      

      while true                     % опр к-ва т.осцилляции qosc
         I  = a:b; 
         H1 = subplot(221); hold(H1,'off'); 
         [AX H11 H12]=plotyy(L(I),[S(I,5,mdm) S(I,6,mdm)],L(I),Xs(I,mdm)); 
         grid on
         set( [get(AX(1),'Ylab') get(AX(2),'Ylab') ],{'Str'},...
         {'nef, ngr';'x(\lambda)'})
         YLim = get(AX(1),'YLim');
         Y1 = YLim(1);
         hY = (YLim(2)-Y1)/20;
         I1 = I(1);  LI1 = L(I1);
         text( [Lot Lot LI1 LI1], ...
               [Y1 Y1+hY  S(I1,5,mdm)+hY S(I1,6,mdm)+hY ],...
               {'\bullet' ...
               ['\lambda_{отс}' sprintf('=%.4g',Lot)] ...
               'nef' 'ngr'}, 'FontSize',9)
         title(sprintf('nef, ngr  -%d-  x', length(I))); 
         xlabel('\lambda')
         
         H2=subplot(222); hold(H2,'off'); plot(L(I),S(I,1,mdm)); title('S1'); grid on
         H3=subplot(223); hold(H3,'off'); plot(L(I),S(I,2,mdm)); title('S2'); grid on 
         H4=subplot(224); hold(H4,'off'); plot(L(I),S(I,3,mdm),'.');
         title(sprintf('S3, qidp = %d %d, DIFF%d',qid,qip)); grid on
                       
         mem = menu('Подбор РС',...
                        '1. К-во искл тт  0 0',...
                        '2. К-во искл тт  0 1',...
                        '3. К-во искл тт  0 2',...
                        '4. К-во искл тт  1 0',...
                        '5. К-во искл тт  1 1',...
                        '6. К-во искл тт  1 2',...
                        '7. К-во искл тт  2 0(ум)',...
                        '8. К-во искл тт  2 1',...
                        '9. К-во искл тт  2 2',...
                        'Увеличить масштаб', 'Уменьшить масштаб',...
                        'Оставить этот вариант');
         if mem < 10
            qid = qidp(mem,1);  qip = qidp(mem,2);
            S = v_S123( L, hL, n_2, dvas, Xs, qid, qip); 
         elseif mem == 10            
            if RL == 2 
               if b == 2
                  prib('Увеличить данный масштаб нельзя');  continue,end
               b = max( round(b/2), 2); 
            else
               if a == b-1
                  prib('Увеличить данный масштаб нельзя');  continue,end 
               a = min( round(a+0.5*(b-a)), b-1);
            end                        
         elseif mem == 11            
            if RL == 2
               if b == qL
                  prib('Уменьшить данный масштаб нельзя');  continue,end
               b = min( b*2, qLm);
            else
               if a == 1
                  prib('Уменьшить данный масштаб нельзя');  continue,end                          
               a = max( round(a-0.5*(b-a)), 1); 
            end                
         else
            hold(H1,'on');  hold(H2,'on');
            hold(H3,'on');  hold(H4,'on');  break
         end
      end
       
      qu0 = inpA('', qu0, 'ч.т уточнения' , 30, [3 qL], 1);
      if isempty(qu0),  break,end
                  
      sln9 = 1;            sln0 = 2;
      ic   = 0;            clrs = 'rgbcmk';        
      if RL == 2              % уточнение слева
         iu   = qu0+1;        % Индекс точки, после к-й нач-ся Уточнение
         i0   = 1:iu;  
         Xnew = Xs(iu-1, mdm );                   
      else                    % уточнение справа
         iu   = qL-qu0-sum(isnan(Xs(:,mdm)));
         i0   = iu : iu+qu0;  
         Xnew = Xs(iu+1, mdm ); 
      end 
      
      Lu    = L(iu);    
      Xu    = Xs (iu, mdm ); 
      Xmax  = Xs (i0, mdm );
      N_2max= n_2(i0,: );
      Stmax = S  (i0,:,mdm );
      qu    = qu0;            qu2 = qu0*2;   qumax = 0; 
      quh   = qu0*hL;
      izm   = true;
      quOSC = 16384;
      OSC   = false;   % ОСЦИЛЛЯЦИИ не было
      qPO   = 5;       % К-во точек, на к-х Проверяется к-во Осцилляций
      if n==1 && m==1, extR = @extDLor1;
      else             extR = @extDLor;  end
      
      while true       % Нахождение неосциллирующего S3
        if izm
        ic  = ic+1;           clr = clrs( mod( ic,6)+1);
        h   = quh/qu;
        h2  = h/2; 
        if ~OSC && qu > qumax
           qumax = qu;  
           if RL == 2
              Lu_h = Lu-h;
              X01 = extDLf( Lu_h, Lu, Xnew(end), Xu, Xf, Lu+h2);
              X02 = extDLf( Lu_h, Lu, Xnew(end), Xu, Xf, Lu-h2);  
              Xg  = Xf;
              if nm1==1,  Solv = @SolvL1; else Solv = @SolvL2;  end
           else 
              Luph = Lu+h;
              X01 = extDLo( Lu, Luph, Lot, Xu, Xnew(1), Xot, Luph-h2);
              X02 = extDLo( Lu, Luph, Lot, Xu, Xnew(1), Xot, Luph+h2); 
              Xg  = Xot;
              if nm1==1,  Solv = @SolvR1; else Solv = @SolvR2;  end
           end 
          
           L1   = Lu+h2;                    
           Xnew = Solv( KZ,   nT,   n,   c,    NM, ...
                        Xg,   extR, h,   L1,   qu, ...
                        dva,  Lot, [X01; X02], 2,1 );

           if ischar(Xnew),  UTO = ['shuto_S123\n' Xnew];  return,end
                          
           Lnew   = ( L1 : h : L1 + (qu-1)*h )';
           N_2new = n_2_2( Lnew.^2, KZ(:, [sln9 sln0]));
           qu1 = qu2+1;
           J1  = (1 : qu1)';    
           J   = logical( mod( J1,2) );
           Lt  = (Lu :h2: Lu+qu*h)';
           Lmax = Lt;
           
           Xt = nan(qu1,1);   N_2t   = nan(qu1,2);  
           Xt( J) = Xmax;     N_2t( J,:) = N_2max;  
           Xt(~J) = Xnew;     N_2t(~J,:) = N_2new;  
           Xmax   = Xt;       N_2max     = N_2t;    
           Stmax  = v_S123( Lmax, h2, N_2max, dva, Xmax, 2,0);
           St     = Stmax; 
           
           qPO1 = qPO+1;
           RAZ = St(2:qPO1,3)-St(1:qPO,3);
           sch = 0;
           for i = 1:qPO-1
               if RAZ(i)*RAZ(i+1) < 0, sch = sch+1;  end
               if sch >= 2,  OSC = true;  break;  end
           end    
                        
           if OSC   % откат к предыд (удвоенному) шагу
              quOSC  = qu/2;
              if quOSC < qu0
                 tS3 = sprintf('%g ',St(1:qPO1,3));
                 AV1 = sprintf(['Для S3 к-во осцилляций = %d,\n' ...
                      'но откат к пред шагу невозможен,\n'...
                      'т.к.это первое уточнение'],OSC);
                 UTO = sprintf('shuto_S123\n%s\nS3=\n%s',AV1,tS3);
                 fig = figure;
                 plot(St(1:qPO1,3));
                 title(sprintf('Осцилляция S3 обнаружена на %d точках',qPO1))                
                 prie(AV1)
                 delete(fig)
                 return
              else
                 qumax  = quOSC;
                 I = 1:2:qu1;
                 Lmax   = Lmax(  1:2:end ); 
                 Xmax   = Xmax(  1:2:end ); 
                 N_2max = N_2max(1:2:end,: );
                 Stmax  = v_S123( Lmax, h, N_2max, dva, Xmax, 2,0);
              end
           end
        else
           hi = qumax/qu;
           Lt = Lmax(  1:hi:end ); 
           St = Stmax( 1:hi:end,: );
        end
        
        subplot(221);  plot( Lt, St(:,5:6),clr);
        title(sprintf('nef, ngr, к.т =%d+%d, h=%g=%g/%d',...
                      iu, qu2, h2, hL, qu2/qu0));              grid on;   
        subplot(222);  plot( Lt, St(:,1), clr);  title('S1');  grid on;   
        subplot(223);  plot( Lt, St(:,2), clr);  title('S2');  grid on;   
        subplot(224);  plot( Lt, St(:,3), clr);  title('S3');  grid on; 
        end % izm
                
        meu = menu('Уточнение решения',...
                   '1.Уменьшить шаг',...
                   '2.Откат к пред шагу',...
                   '3.Указать диапазон и постр графики',...
                   '4.Выход');
        if     meu == 1
            izm =  qu2 <= quOSC;
            if izm 
               qu  = qu2;
               qu2 = qu*2;
               hold(H1,'on');  hold(H2,'on');
               hold(H3,'on');  hold(H4,'on'); 
            else
               prib('Шаг уменьш нельзя\nОсцилляция');
            end                         
        elseif meu == 2
           izm =  qu >= qu0;
           if izm,  qu2 = qu;
              qu  = qu/2;                    
              hold(H1,'off');  hold(H2,'off');
              hold(H3,'off');  hold(H4,'off'); 
           else
              prib('Шаг увеличен до первонач\nУм-ть');
           end
        elseif meu == 3
           izm = true;
           if RL == 2,  LL = L(iu:end);
           else         LL = L(1:iu);  end
           
           while true
             x  = diap( L(1), L(end));
             iL = x(1)< LL & LL < x(2);
             iv = x(1)< Lt  &  Lt < x(2);
             
             hold(H1,'off');  hold(H2,'off');
             hold(H3,'off');  hold(H4,'off');
             subplot(221); 
                plot( L(iL),[S(iL,5,mdm) S(iL,6,mdm)], Lt(iv), St(iv,5:6)); 
                text( Lt(end)+hL, St(end,5), 'nef')
                text( Lt(end)+hL, St(end,6), 'ngr')
                title(sprintf('nef, ngr, к.т=%d+%d, h=%g=%g/%d',...
                    iu, qu, h2, hL, qu/qu0)); 
                grid on
             subplot(222); 
                plot( L(iL),S(iL,1,mdm), Lt(iv), St(iv,1)); 
                grid on;    title('S1');
             subplot(223); 
                plot( L(iL),S(iL,2,mdm), Lt(iv), St(iv,2));
                grid on;    title('S2');
             subplot(224); 
                plot( L(iL),S(iL,3,mdm), Lt(iv), St(iv,3));
                grid on;    title('S3');
             if ~MEN,  break,end
           end         
        else break
        end  % meu == 4
      end    % Конец нахождения неосциллирующего S3
      
      hold(H1,'off');  hold(H2,'off');
      hold(H3,'off');  hold(H4,'off');
      UTO = [Lt; Xt]; 
   end
end

%______ ДИФф-е ф-ции F, заданной в M точках, с исключениями крайних тт
%        в зависимости от выбора РС на концах и-ла ___________________
function DF = DIFi( k, F, h, qid, qip)  
% qid - К-во Исключенных точек До    дифф-я 
% qip - К-во Исключенных точек После дифф-я
% Исключение точек: с правого края - qid и c левого - qid
% Аналогично - qip
% qip = 0: В 1-й и 2-й точках исп ДВЕ нецентральные несимм РС
% qip = 1: В n-1 и n-й точках исп ДВЕ аналогичные(антизеркальные) РС
% qip = 2: В центральной части исп центральные симм РС
% Производная Df определена во всех точках
M = length(F);       DF = nan(M,1);
m = M-2*qid;
I = qid+1 : M-qid;   f  = F(I);   Df = DF(I);         

if k == 1  
   L = [ 1.0  -8.0   0  8.0 -1.0];          z = 12*h;
   if qip <= 1
      f1 = f(1:5);      f2 = f(m-4:m);
      Df(2)  = [ -3.0 -10.0  18.0  -6.0  1.0]*f1;
      Df(m-1)= [ -1.0   6.0 -18.0  10.0  3.0]*f2;
      if qip == 0
         Df(1) = [-25.0 48.0 -36.0  16.  -3.0]*f1;
         Df(m) = [ 3.0 -16.0  36.0 -48.0 25.0]*f2;
      end
   end
else       
   L = [-1.0  16.0 -30.0  16.0 -1.0];          z = 12*h*h;
   if qip <= 1
      f1 = f(1:5);      f2 = f(m-4:m);
      Df(2)  = [ 11.0 -20.0   6.0   4.0 -1.0]*f1;
      Df(m-1)= [ -1.0   4.0   6.0 -20.0 11.0]*f2;
      if qip == 0
         Df(1) = [ 35.0 -104.0 114.0  -56.0 11.0]*f1;
         Df(m) = [ 11.0 -56.0  114.0 -104.0 35.0]*f2;
      end
   end
end
for i = 1:m-4, Df(i+2) = L*f(i:i+4); end
DF(I) = Df/z;

%_____________ Дифф-е ф-ции f, заданной в n точках _____________________
% Во 2-й точке исп ОДНА нецентральная несимм РС
% В n-1 точке исп ОДНА аналогичная(антизеркальная) РС
% В центральной части исп центральные симм РС
% Df(1) = Df(n) = NaN
function Df = DIFi1( k, f, h)  
m  = length(f);   Df = nan(m,1);
f1 = f(1:5);      f2 = f(m-4:m);
if k == 1  
   L      = [  1.0  -8.0   0     8.0 -1.0];        z = 12*h;
   Df(2)  = [ -3.0 -10.0  18.0  -6.0  1.0]*f1;
   Df(m-1)= [ -1.0   6.0 -18.0  10.0  3.0]*f2;
else       
   L      = [ -1.0  16.0 -30.0  16.0 -1.0];        z = 12*h*h;
   Df(2)  = [ 11.0 -20.0   6.0   4.0 -1.0]*f1;
   Df(m-1)= [ -1.0   4.0   6.0 -20.0 11.0]*f2;
end
for i = 1:m-4, Df(i+2) = L*f(i:i+4); end
Df = Df/z;

%_____________ Дифф-е ф-ции f, заданной в n точках _____________________
% В точках 3,...,n-2 исп Центральне симм РС
% Df(1) = Df(2) = Df(n-1) = Df(n) = NaN
function Df = DIFi2( k, f, h)  
m  = length(f);   Df = nan(m,1);
if k == 1,   L = [ 1.0  -8.0   0    8.0 -1.0];      z = 12*h;
else         L = [-1.0  16.0 -30.0  16.0 -1.0];     z = 12*h*h; end

for i = 1:m-4, Df(i+2) = L*f(i:i+4); end
Df = Df/z;

%__________SubPlot дисп х-к S123_______________________________________
function   sp_S123 (I, J, moda, m2a, ZaG, lab, L, Lots, S)
siS = size(S);
qX  = siS(1);
if length(siS) == 3,  qm  = siS(3);  else  qm = 1;  end
ed  = ones(1,qm);

if    qm == 1,  it = 1; % Индекс Текст.переменной m2a
      mmG = m2a{1}(1:2); 
else
   if  qm < 12,  mmG = ['= [' sprintf('%.2s ',m2a{:} ) ']'];
   else          mmG = ['in [' m2a{1}(1:2) ' ' m2a{end}(1:2) ']'];  end
   if strcmp( m2a{1}(1:2), ' 1' ),  it = 2:qm; % it нач с 2,тк Lots(1)=Inf
   else                             it = 1:qm;   end
end
lenit = length(it);
if lenit == 1,  iG = 1;   
else            iG = [1 lenit];  end

mm = cellfun(@(x) sprintf('%.2s',x),m2a(it), 'UniformOutput', false);
for k = 1:I*J
    subplot(I,J,k)
    plot(L, reshape(S(:,k,:), qX, qm)) 
    
    XLim = get(gca,'XLim');
    x1   = XLim(2)*1.01;
    x2   = XLim(2)*1.04;    
    iS   = sum( ~isnan(S(:,k,end)) );
    
    if qm ~= 1,  text ([x1 x1], [S(iS,k,1) S(iS,k,end)],...
                 { m2a{1}(1:2) m2a{end}(1:2) }, 'FontSize', 6);
    end 
    
    YLim = get(gca,'YLim');
    Y2 = YLim(2);
    Y1 = YLim(1);
    if k == 1 
       if qm == 1
          text ( x1,      S(iS,k,1), m2a{1}(1:9), 'FontSize', 8);  
       else
          hy = ( Y2-Y1 )/ (qm+1);
          text ( x2, Y2, 'm   2a','FontSize',8); 
          text ( x2*ed, setK( [Y2-hy Y1+hy qm]), m2a,'FontSize',8); 
       end
    end
        
    hold on; grid on
    titlab([ZaG{k} '.  ' moda 'm, m ' mmG],lab);
    
    Y0 = Y1*ed(it);
    plot ( Lots(it), Y0, '.r');  
    text ( Lots(iG), Y0(iG)-(Y2-Y1)*0.03, mm(iG),'FontSize',6);  
    hold off; 
end

% ________квадраты пп n^2 для 2 слоев с к-тами Z(:,1) и Z(:,2)____________
function  n_2s = n_2_2( L_2, Z)
n_2s = [ n_2kZ( L_2, Z(:,1))   n_2kZ( L_2, Z(:,2)) ];
