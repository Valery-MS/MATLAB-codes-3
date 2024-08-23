%_______________________I = ROW; G=[G1 G2]- 2 числа____________________
function I = inpRI( tit, I, im, G, varargin) 
% если посл арг = NaN, то Esc, Canc игнорируются,т.е. ввод дб непустым
% ввод строки целых(Row of Integer), длина I м/меняться
% im - имя I (char)
% varargin = char, содерж условие в символах I, например: 'I(1)<I(2)'
if size(I,1) ~= 1,  I = 'Нач.зн вводимых данных дб строкой'; return,end
if any(size(G) ~= [1 2]) || G(1) > G(2) 
   I = 'Гр.зн. дб строкой из 2-х неубывающих чисел';         return,end
op.Interpreter = 'tex';  op.Resize = 'on';   op.WindowStyle = 'modal'; 
z = sprintf('%g< %s <%g     ',G(1),im,G(2));
if     isempty(varargin),    ERRon = false;  Na = false;
elseif isnan(varargin{1}),   ERRon = false;  Na = true; 
elseif isnan(varargin{end}), ERRon = true;   Na = true;
else                         ERRon = true;   Na = false;  end 
S   = num2str(I);                
while true   
   C = inputdlg(z,tit,1,{S},op);
   if isempty(C),  if Na,  prie('Дб непустой ввод'); continue
                   else    I = '';                   return,end,end
   S = C{1};           I = str2num(S);   
   if isempty(I),      prie('Некорректный ввод чисел');     continue,end      
   if size(I,1) ~= 1,  prie('Вводимые данные дб строкой');  continue,end
   if any(I<G(1)) || any(I>G(2)), prie('Выход за границы'); continue,end                  
   if any(mod(I,1)),   prie('Ввод нецелых чисел');          continue,end   
   if ERRon
      if    eval(['(' varargin{1} ')']),  return
      else  prie(['Не вып доп условие\n' varargin{1}]);  end
   end
end