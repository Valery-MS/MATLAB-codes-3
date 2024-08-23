%______________________________________________________
function I = inpN( tit, I, im, wid, G, varargin)
% I  = wid-vector; G=wid*2-matrix
% im = {wid-string-vector} ����� �������� ����������
% varargin = empty,    ��� �������
%          = intArr, ����: [2 3], �������� �� �������� I(2), I(3)
%          = string, ������ ��� � �������� I, ��������: 'I(1)<I(2)'
%          = intArr,string  ���  string,intArr - 2 �������
if any(G(:,1) > G(:,2)),       I = '�������� �������';       return,end
if isempty(im),                I = '�� ����� ������ ���';   return,end
if any(cellfun(@isempty,im)),  I = '�� ��� ����� �������';   return,end
RG = size(G,1); 

lenim = length(im);
if isempty(I), [RI CI] = size(im);  lI = lenim;
else           [RI CI] = size(I);   lI = length(I); end
%if RI ~= 1,     I = '�������� ������ � �� ����� �� ��������';return,end
if lI ~= lenim,       I = '�-�� ��-��� ~= �-�� �� ���';     return,end
if lI ~= length(wid), I = '�-�� ��-��� ~= �-�� ���� �-���';  return,end
if lI ~= RG,          I = '�-�� ��-��� ~= �-�� ������';      return,end

if     isempty(varargin),       Na = false;   ERRon = 0;  
elseif isnan(varargin{1}),      Na = true;    ERRon = 0; 
else   v1 = varargin{1};
   if  isnan(varargin{end}),    Na = true;    narMax = 8;
   else                         Na = false ;  narMax = 7; end
   if nargin == narMax,  v2 = varargin{2}; end
   if isnumeric(v1) && all(mod(v1,1)==0),        ERRon = 1;  
      if nargin == narMax  
         try te = eval(v2);  v2 = ['(' v2 ')'];  ERRon = 2;           
         catch ME, I = [ME.message '\n 2 ���'];    return,end
      end
   else
      try te = eval(v1);  v1 = ['(' v1 ')'];     ERRon = 3;
      catch  ME,   I = [ME.message '\n 1 ���'];    return,end
      if nargin == narMax         
         if all(mod(v2,1)==0),                   ERRon = 4; 
         else   I = '������� ������ ���� �����'; return,end
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
   if isempty(C),  if Na,  prie('�� �������� ����'); continue
                   else    I = '';                   return,end,end
   S = C{1};   
   try I = reshape( str2num(S), RI,CI);
   catch ME, prie(ME.message);    continue,end
   
   if isempty(I),              prie('������ ���� �����');    continue,end
   rI = reshape( I, lI, 1 );
   if any( rI < G(:,1)) || any( rI > G(:,2))
                               prie('����� �� �������');     continue,end
   if ~ERRon,   return
   else switch  ERRon
        case 1, ERR = any(mod(I(v1),1));          
                dop = sprintf('��� I(%g)',v1);
        case 2, ERR = any(mod(I(v1),1)) || ~eval(v2);
                dop = [sprintf('��� I(%g) & ',v1) v2];
        case 3, ERR = ~eval(v1);      dop = v1;
        case 4, ERR = ~eval(v1) || any(mod(I(v2),1));
                dop = [v1 sprintf('��� I(%g) & ',v2)];
        end
        if ~ERR, return  
        else     prie(['�� ��� ��� �������\n' dop]); end
   end
end
