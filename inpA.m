%___________ ввод массива(строка,ст-ц,м-ца) _____________________________
function I = inpA(tit,I,im,wid,G,varargin)
% I=массив;
% im=string-имя I; 
% wid=шир ф-та на одно число;  
% G=[1x2]-array
% ! в начале имени означает,что у массива мб изменена размерность

if any(size(G) ~= [1 2]) && any(size(G) ~= [2 1])
                           I = 'Границы дб 1х2-array';    return,end
if     isempty(im),        I = 'Не задано имя';           return
elseif ~ischar(im),        I = 'Имя дб строкой символов'; return,end
if isempty(I),             I = 'Не задан массив';         return,end
[RI CI] = size(I);

if     isempty(varargin),       Na = false;      ERRon = 0;  
elseif isnan(varargin{1}),      Na = true;       ERRon = 0; 
else   v1 = varargin{1};
   if  isnan(varargin{end}),    Na = true;    narMax = 8;
   else                         Na = false ;  narMax = 7; end
   if nargin == narMax,  v2 = varargin{2}; end
   if isnumeric(v1) && all(mod(v1,1)==0),        ERRon = 1;  
      if nargin == narMax  
         try   te = eval(v2); 
               v2 = ['(' v2 ')']; 
               ERRon = 2;           
         catch ME, I = ['Неверно задано 2 усл\n' ME.message];
               return
         end
      end
   else
      try   te = eval(v1); 
            v1 = ['(' v1 ')'];  
            ERRon = 3;
      catch ME,    I = ['Неверно задано 1 усл\n' ME.message];
            return
      end
      if nargin == narMax         
         if all(mod(v2,1)==0),                   ERRon = 4; 
         else   I = 'Неверен вектор пров целоч'; return,end
      end
   end
end   

op.Interpreter = 'tex';  op.Resize = 'on';   op.WindowStyle = 'modal';
%len = round(3*size(num2str(I),2));
S = num2str(I);   
z = sprintf('%s  %g %g',im,G(1),G(2));
while true
   C = inputdlg(z,tit,[RI wid],{S},op);
   if isempty(C),  if Na,  prie('Дб непустой ввод');  continue
                   else    I = '';                    return,end,end
   S = C{1};
   I = str2num(S);
   if isempty(I),              prie('Некорр ввод чисел');    continue,end
   if im(1) ~= '!'
      if any(size(I) ~= [RI CI])
         prie('Неверная разм массива');continue,end
   end 
   if any(any(I<G(1))) || any(any(I>G(2)))
                               prie('Выход за границы');     continue,end
   if ~ERRon, return
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
        else  prie(['Не вып доп условие\n' dop]);  end
   end
end