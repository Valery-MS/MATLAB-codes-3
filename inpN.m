%______________________________________________________
function I = inpN( tit, I, im, wid, G, varargin)
% I  = wid-vector; G=wid*2-matrix
% im = {wid-string-vector} имена вводимых переменных
% varargin = empty,    нет условий
%          = intArr, напр: [2 3], проверка на целочисл I(2), I(3)
%          = string, содерж усл в символах I, например: 'I(1)<I(2)'
%          = intArr,string  или  string,intArr - 2 условия
if any(G(:,1) > G(:,2)),       I = 'Неверные границы';       return,end
if isempty(im),                I = 'Не задан вектор имён';   return,end
if any(cellfun(@isempty,im)),  I = 'Не все имена заданвы';   return,end
RG = size(G,1); 

lenim = length(im);
if isempty(I), [RI CI] = size(im);  lI = lenim;
else           [RI CI] = size(I);   lI = length(I); end
%if RI ~= 1,     I = 'вводимые данные и их имена дб строками';return,end
if lI ~= lenim,       I = 'к-во эл-тов ~= к-ву их имён';     return,end
if lI ~= length(wid), I = 'к-во эл-тов ~= к-ву длин ф-тов';  return,end
if lI ~= RG,          I = 'к-во эл-тов ~= к-ву границ';      return,end

if     isempty(varargin),       Na = false;   ERRon = 0;  
elseif isnan(varargin{1}),      Na = true;    ERRon = 0; 
else   v1 = varargin{1};
   if  isnan(varargin{end}),    Na = true;    narMax = 8;
   else                         Na = false ;  narMax = 7; end
   if nargin == narMax,  v2 = varargin{2}; end
   if isnumeric(v1) && all(mod(v1,1)==0),        ERRon = 1;  
      if nargin == narMax  
         try te = eval(v2);  v2 = ['(' v2 ')'];  ERRon = 2;           
         catch ME, I = [ME.message '\n 2 усл'];    return,end
      end
   else
      try te = eval(v1);  v1 = ['(' v1 ')'];     ERRon = 3;
      catch  ME,   I = [ME.message '\n 1 усл'];    return,end
      if nargin == narMax         
         if all(mod(v2,1)==0),                   ERRon = 4; 
         else   I = 'Неверен вектор пров целоч'; return,end
      end
   end
end   
  
z = '';  F = '';
for k = 1:lI
    p   = wid(k);
    F   = [F sprintf('%%%d.%dg',round(2*p+3+length(im{k})),p)];
    %frm = sprintf('%%.%dg \\\\leq %%s \\\\leq %%.%dg    ',p,p);
    frm = sprintf('%%.%dg < %%s < %%.%dg    ',p,p);
    z   = [z sprintf(frm,G(k,1),im{k},G(k,2))]; 
end
S = sprintf( F, I);

op.Interpreter = 'tex';  op.Resize = 'on';   op.WindowStyle = 'modal'; 
LT  = length(tit);       Lpromp    = max(cellfun(@length,im));
if 2*LT < Lpromp, numlin = 1;
else              numlin = [1 length(z)]; end  %round(lI*sum(wid))

while true
   try,       C = inputdlg( {z}, tit, numlin, {S}, op);
   catch ME,  prie(ME.message);
   end
   if isempty(C),  if Na,  prie('Дб непустой ввод'); continue
                   else    I = '';                   return,end,end
   S = C{1};   
   try I = reshape( str2num(S), RI,CI);
   catch ME, prie(ME.message);    continue,end
   
   if isempty(I),              prie('некорр ввод чисел');    continue,end
   rI = reshape( I, lI, 1 );
   if any( rI < G(:,1)) || any( rI > G(:,2))
                               prie('выход за границы');     continue,end
   if ~ERRon,   return
   else switch  ERRon
        case 1, ERR = any(mod(I(v1),1));          
                dop = sprintf('Цел I(%g)',v1);
        case 2, ERR = any(mod(I(v1),1)) || ~eval(v2);
                dop = [sprintf('Цел I(%g) & ',v1) v2];
        case 3, ERR = ~eval(v1);      dop = v1;
        case 4, ERR = ~eval(v1) || any(mod(I(v2),1));
                dop = [v1 sprintf('Цел I(%g) & ',v2)];
        end
        if ~ERR, return  
        else     prie(['Не вып доп условие\n' dop]); end
   end
end
