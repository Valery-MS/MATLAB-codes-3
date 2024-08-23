%____________% ввод универсальный _______________________________________
function I = inpU(tit, I, im, wid, G, varargin) 
% если последний аргумент = NaN, то Esc и Canc при вводе игнорируются
% I={SOV or Arrays}- вектор; SOV - SetOfVar(набор переменных)
% im - {имена},   G={границы I}
% wid - {w1...wL}, L-длина I(=LI)
% if I{k}is SOV, wk is ROW=[ширины ф-тов для I{k}]; else wk не исп.
% ! в 1-м символе имени озн, что у данного массива мб изменена размерность
% ! в 2-м символе имени озн, что данные в окне предст в виде: Iнач : Iкон
if ~isvector(I) || ~isvector(G) 
   I = 'н.зн I и гр.зн G дб векторы';     return,end
if isempty(I), I = 'Вх.аргумент I не дб пустым';  return,end

LI = length(I);
if LI ~= length(G)
   I = 'к-во строк ввода ~= к-ву границ'; return,end

z = cell(LI,1);     SOI = zeros(LI,2);  % Sizes of I
F = cell(1,LI);     C = z;
for j = 1:LI
   if ~isnumeric( I{j}) || ~isnumeric( G{j})
      I = 'содержимое I и G дб числа';  return,end 
   if any( G{j}(:,1) > G{j}(:,2) )
      I = 'Неверные границы';           return,end
   SOI(j,:)  = size(I{j});
   [Rim Cim] = size(im{j});
   if Rim >  1, I = 'В окне - одно имя, либо строка имен';  return,end
   if Cim == 1  % I{j} - переменная: число, вектор или матрица
      if any(size(G{j}) ~= [1 2])
         I = sprintf('Для перем.I{%g} size(G) ~= [1 2]',j); return,end
      if size(wid{j},2) ~= 1
         I = sprintf('Для перем.I{%g} к-во.длин ~= 1',j);   return,end
   elseif length(I{j}) ~= length(G{j}(:,1)) % I{j} - набор переменных
      I = 'к-во переменных в строке ~= длине гран-м-цы'; return
   end      
   
   za   = '';
   for k = 1:Cim           
      F{j} = [F{j} sprintf('%%%dg ',wid{j}(k))];
      zk   = sprintf(' %s: %g  %g    ',im{j}{k}, G{j}(k,1), G{j}(k,2));            
      za   = [za zk]; 
   end
   str = im{j}{1};
   if numel(str) >=2 && str(2) == '!'
      C{j} = sprintf('%g : %g',I{j}([1 end]));
   else
      if Cim > 1 || all( SOI(j,:)==[1 1]), C{j} = sprintf(F{j},I{j});
      else                                 C{j} = num2str(I{j},F{j}); end
   end
   z{j} = za; 
end

op.Interpreter = 'tex'; op.Resize = 'on';   op.WindowStyle = 'modal';  
if     isempty(varargin),    ERRon = false;  Na = false;
elseif isnan(varargin{1}),   ERRon = false;  Na = true; 
elseif isnan(varargin{end}), ERRon = true;   Na = true;
else                         ERRon = true;   Na = false;
end 
NL    = zeros(LI,1);
for j = 1:LI,  NL(j) = size(I{j},1); end
while true
   C1 = inputdlg( z, tit, NL, C, op);
   if isempty(C1), if Na,  prie('Дб непустой ввод');  continue
                   else    I = '';                    return,end,end
   C = C1;            
   I = cellfun(@str2num,C,'UniformOutput',false);   
   if any(cellfun(@isempty,I)),prie('Некоррек. ввод чисел');continue,end          
   E1 = false;  E2 = false;
   for j=1:LI  
      if all(size(im{j}) ~= [1 1]) || im{j}{1}(1)~='!'
         E1 = E1 || any(size(I{j}) ~= SOI(j,:) );  end
   end
   if E1,  prie('Неверная размерность');    continue,end
   for j=1:LI,  E2 = E2 || any(any( I{j}' <  G{j}(:,1) )) ...
                        || any(any( I{j}' >  G{j}(:,2) ));end   
   if E2,  prie('Выход за границы');        continue,end
   if ~ERRon, return 
   else if  eval(['(' varargin{1} ')']),  return
        else  prie(['Не вып доп условие\n' varargin{1}]); end
   end
end

% _______ Пока не исп. Ввод функции F(х,varargin) _______________________________
function I = inpFX( tit, I, im, varargin) 
if ~ischar(I),   prie('Inp mb  char array');  return,end
%if Lzag ~= length(I), prie('К-во заголовков д/б= к-ву строк');return,end
op.Interpreter = 'tex'; op.Resize = 'on';  op.WindowStyle = 'modal'; 
x = -1;
if isempty(varargin),        Na = false;
else                         LV = length(varargin);
   if isnan(varargin{LV}),   Na = true;     LV = LV-1; 
   else                      Na = false;    end
   for i = 1:LV
      try   eval([varargin{i} '=1;']);
      catch ME, prie(sprintf(...
          'Неверно задан %g-й арг ф-ции\n%s',i,ME.message));
      end
   end
end
[RF CF] = size(I);
  
while true
   C = inputdlg(im,tit,[RF 2*CF],{I},op);  
   if isempty(C),  if Na,  prie('Дб непустой ввод');  continue
                   else    I = '';                    return,end,end
   I = C{1}; 
   try   cellfun(@eval,C,'UniformOutput',false);   return
   catch ME, prie(['Неверно заданы функции\n' ME.message]),  end
end
