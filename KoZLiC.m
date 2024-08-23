% ___________ % выч KZ как Линейной Комб строк eKZ__________________
function [pvZ KZ nT] = KoZLiC( QS,KZ,LZ, pvZ, PGB)
switch menu('Вычисление к-тов Зельмаера',...
    'Сразу во всех слоях на основе баз.профилей: 100% GeO2 и B2O3',...
    'Послойно на основе лин.комб коэф.Зельм', ...
    'Выход')
case 1
   [pvZ KZ] = KZ100( QS, PGB ); %выч к-тов Зельм  световода
   nT = nTSV1( QS, KZ, LZ );
   if ischar(nT),  pvZ = ''; return,end
   if MEN('','Показать профили'), showProf( QS,KZ,LZ, pvZ, PGB, 1,0); end

case 2 
    poF = 'По Флемингу';  
    poK = 'По Кобаяши';
    nns = 1:QS;   
    Us  = sprintf('length(I)<=%g', QS);        
    T2  = ['После задания профилей во всех слоях\n'...
           'профили можно корркетировать выборочно'];
    fir = true; 
    while true
       if fir,  fir = false;
          T = 'Выч.коэф.Зельмаера\n1-й раз - для всех слоев';
          D = '(по ум)';                     
       else
          T = 'Выч.к.Зельм\nВыборочно по слоям';
          D = '';                  
          nns = inpRI('Номера задаваемых слоёв',nns,'nn',[1 QS],Us);
          if isempty(nns), break,end
       end
          
       for sl = nns
          T1 = [T '\n' sprintf('%g-слой', sl)];
          pvZsl = pvZ(:,sl); 
          PGBsl = PGB(:,sl);
          switch MEN( T1, [poF D], poK)
          case 0
             if ~isempty(D)
                 [Z pv] = inpKZ( QS,sl, pvZsl, PGBsl, poF, 4,7,9);
                 poFK   = poF; 
             end                    
          case 1
              [Z pv] = inpKZ( QS, sl, pvZsl, PGBsl, poF, 4,7,9);    
              poFK   = poF;                      
          case 2
              [Z pv] = inpKZ( QS, sl, pvZsl, PGBsl, poK, 10, 14, 17);
              poFK   = poK;  
          end
                  
          if ischar(Z),  prie(Z);
          else
             KZ (:,sl) = Z;
             pvZ(:,sl) = pv;
             L = setK([LZ 100]);  
             showProfsl( QS,KZ,L, pvZ, PGB, 1, poFK, sl, 1);
          end
       end  

       if ~MEN( T2, 'Корректировать')
          nT = nTSV1( QS, KZ, LZ );
          if ischar(nT),   return,end
       end
    end
    
case 3, nT = 'Отказ от выч к-тов Зельмаера';  
end

% ________%выч к-тов Зельм KZ на основе 100% Ge и В_______________
function [pvZ KZ] = KZ100( QS, PGB) 
global  eKZ 
pvZ = cell(2,QS); 
for i = 1:QS,   pvZ(:,i) = {'2 3';'100'}; end
KZ = 0.01*( eKZ(3:8,1)*(100.0-PGB(1,:)-PGB(2,:)) +eKZ(3:8,2:3)*PGB);

% ____________% ввод Коэфф. Зельмаера __________________________________
function [Zsl pvZsl] = inpKZ( QS, sl, pvZsl, PGBsl, t, N1,N2,N3) 
global  eKZ          
if sl <= QS  &&  all(PGBsl) == 0
   Zsl = eKZ(3:end,1); return,end

pv0 = pvZsl;
               %к-ты eKZ, выбр-е базовыми
bZ = {{sprintf('%s\n\nНомера строк:  ',eKZ_t)},...
      {'Задать веса: if pass, p1=...=pN, else p1+...+pN=100'}};
  
d0  = sprintf('%d %d;...',N1,N2,N1,N3,N2,N3,N3-1,N3);  
d0(end-3:end) = [];
if isempty(pv0{1}),  pv0 = {d0;''};  end

if sl <= QS,  tit = sprintf('%d слой. К-ты Зельм-%s',sl,t);
else          tit = 'Задание к-тов Зелм. для 100%B'; end

pv = cellfun( @str2num, pv0, 'UniformOutput', false);
if isempty(pv)
   Zsl = 'inpKZ: Содерж ячейки pv(пары,веса) дб численным';
   return
end

while true
   pv = inpU( tit, pv, bZ, {50 50}, {[1 17];[0 100]});
   if ischar(pv), Zsl = ['inpKZ: ' pv]; return,end
   
   [p,v]   = pv{:}; % - p-пары номеров, v-веса строк с №№ p массива eKZ
   [rp,cp] = size(p);
   mi      = min(min(p));
   if cp~=2 || 3<mi && mi<N1 || max(max(p))>N3,  prie(...
      ['   Д.быть:\n1) №№ задаются парами, разделяются знаком ";"\n'...
      '   напр., к-ты на базе комб пар строк 1, 4 и 5, 8 - 1 4;5 8\n'...
      '   на базе k-й стр - k k (можно, если %Ge=eKZ(1,k) и %B=eKZ(2,k)'...
      '\n2) %d<=№строки<=%d'],N1,N3);  
      continue
   end

   if rp~=1 && (~isempty(v) && (sum(v)~=100 || rp~=length(v)))
      prie(['Д/быть:\n1) К-во весов=к-во пар\n'...
      '2) Если веса заданы, то их сумма=100']); 
      continue
   end
   break
end

if isempty(v) || rp==1,   v = 100.0*ones(1,rp)/rp; end
pvZsl = {matstr(p);  matstr(v)};    
Zsl = KZsl( QS, sl, pvZsl, PGBsl);

%________преобр. м-цы чисел в симв. строку строк, разд ';'_______
function s = matstr(m)
if isempty(m), s = '';
else  r = size(m,1);     s = num2str(m(1,:));
  if  r>1, for i = 2:r,  s = [s ';' num2str(m(i,:))]; end,end
end

%____________% выч к-ты Зельм для слоя sl ____________________________
function Zsl = KZsl( QS, sl, pvZsl, PGBsl) 
% if sl = QS+1, Z выч для базы В2О3
global eKZ 
Zsl  = zeros(6,1);
[pG,pB,ns,v,rp] = infProf( QS, sl, pvZsl, PGBsl);
  
for k = 1:rp
   T = ns(k,1);    % Two strings
   if T ~= ns(k,2), T = ns(k,1:2); end
   GB   = 0.01*eKZ(1:2,T);
   f    = eKZ(3:8,T)-eKZ(3:8,1)*(1-sum(GB));
   isZk = false;
  
   if length(T) == 1,  isZk = true;
      if sl <= QS
         if pG==GB(1) && pB==GB(2),  Zk = eKZ(3:8,T);
         elseif pG==0 && GB(1)==0,   Zk = (1-pB)*eKZ(3:8,1)+pB*f/GB(2);
         elseif pB==0 && GB(2)==0,   Zk = (1-pG)*eKZ(3:8,1)+pG*f/GB(1); 
         else Zsl = sprintf('Слой %d\nСтрока %g) %g, %g не соотв G=%g B=%g',...
                    sl,T,GB,pG,pB);  return
         end
           
      else        % sl=QS+1 - рассч к-ты для 100% B2O3
         if GB(1) == 0,  Zk = f/GB(2);
         else  Zsl = sprintf('Слой %d\nСтрока %g) %g %g не соотв 100%%B',...
                   sl,T,GB);  return
         end
      end
   elseif det(GB) == 0
      Zsl = sprintf('Слой %d\nСтроки %g %g\nвырожд.м-ца=\n%g %g\n%g %g',...
          sl,T,GB');     return
   else Z100 = f/GB;
   end
  
   if ~isZk
      if sl <= QS,  Zk = (1-pG-pB)*eKZ(3:8,1)+Z100*[pG;pB];
      else          Zk = Z100(:,2); end
   end
   Zsl = Zsl+v(k)*Zk; 
end

%_________ Информация о профиле _____________________________________
function [pG, pB, ns, v, rp] = infProf( QS, sl, pvZsl, PGBsl)
% pG=%Ge,pB=%Bor, ns-пары № строк eKZ, v-их веса, rp=rows q-ty of ns
if sl <= QS
   spGB = 0.01*PGBsl;            %PGB(:,sl);
   pG = spGB(1);  pB = spGB(2);
else
   pG = NaN;      pB = NaN;
end

[ps,vs] = pvZsl{:};
ns = str2num(ps);   v = 0.01*str2num(vs);   rp = size(ns,1);

% ______ Тип СВ с дисп __________________________________________
function nT = nTSV1( QS, KZ, LZ )
% nT      = № типа профиля
% TSV =  {'1. n1 >  n2 >  n3',    '3. n1 >  n3 >= n2',
%         '2. n2 >= n1 >  n3',    '4. n2 >= n3 >= n1'}
K    = 40; 
L    = setK([LZ K]);
L_2  = L.^2; 
n1_2 = n_2kZ( KZ(:,1), L_2 );  % n^2 в 1 слое 
n2_2 = n_2kZ( KZ(:,2), L_2 );

if QS == 2                         % nT = 5, ч-бы iNA(nT)=[1 2]
   if n1_2(K) > n2_2(K),  nT = 5;  % и vhea{:,nT}=ф-циям для 2-СВ
   else                   nT = 'n1_2 < n2_2';   end 
else 
   n3_2 = n_2kZ( KZ(:,3), L_2 ); 
   if n1_2(K) > n2_2(K)
      if n2_2(K) > n3_2(K)      
         if   any(    n1_2 > n2_2 & n2_2 > n3_2),  nT = 1;
         else nT ='1. n1_2 > n2_2 > n3_2'; end
      else  % n2_2 <= n3_2
         if   any(    n1_2 > n3_2 & n3_2 > n2_2),  nT = 3;
         else nT ='3. n1_2 > n3_2 = n2_2'; end
      end
   else     % n1_2 <= n2_2
      if n1_2(K) > n3_2(K)
         if   any(    n2_2 > n1_2 & n1_2 > n3_2),  nT = 2; 
         else nT ='2. n2_2 > n1_2 > n3_2'; end
      else  % n1_2 <= n3_2
         if   any(    n2_2 > n3_2 & n3_2 > n1_2),  nT = 4;  
         else nT ='4. n2_2 > n3_2 > n1_2'; end
      end
   end
end
 
% ______ Тип СВ без дисп ___________________________
function [nT NA2] = nTSV0( pn2_2, ee)
% NA - Number of Aperture на сетке L 
% pn2_2 = pn2^2 - квадрат пп во 2-м слое
% ee =  e1     для 2-СВ
% ee = [e1 e3] для 3-СВ
% TSV =  {'1. n1 >  n2 >  n3',    '3. n1 >  n3 >= n2,
%         '2. n2 >= n1 >  n3',    '4. n2 >= n3 >= n1'}
pn1_2 = pn2_2*ee(1);    
if size(ee,2) == 1   % 2-СВ
   if nargout == 2
      if pn1_2 > pn2_2,  nT = 1; else  nT = 2; end
   end
   NA2 = abs(pn1_2-pn2_2);
else                 % 3-СВ
   pn3_2 = pn2_2*ee(2); 
   if pn1_2 > pn2_2
      if pn2_2 > pn3_2
         NA2 = pn1_2-pn3_2;  
         if nargout == 2, nT = 1; end              
      else
         NA2 = pn1_2-pn2_2;
         if nargout == 2, nT = 3; end
      end  % pn2 <= pn3       
   else                                              % pn1 <= pn2        
      if pn1_2 > pn3_2
         NA2 = pn2_2-pn3_2;  
         if nargout == 2, nT = 2; end     
      else
         NA2 = pn2_2-pn1_2;                          % pn1 <= pn3
         if nargout == 2, nT = 4; end
      end
   end
end 
