%_______________________I = ROW; G=[G1 G2]- 2 �����____________________
function I = inpRI( tit, I, im, G, varargin) 
% ���� ���� ��� = NaN, �� Esc, Canc ������������,�.�. ���� �� ��������
% ���� ������ �����(Row of Integer), ����� I �/��������
% im - ��� I (char)
% varargin = char, ������ ������� � �������� I, ��������: 'I(1)<I(2)'
if size(I,1) ~= 1,  I = '���.�� �������� ������ �� �������'; return,end
if any(size(G) ~= [1 2]) || G(1) > G(2) 
   I = '��.��. �� ������� �� 2-� ����������� �����';         return,end
op.Interpreter = 'tex';  op.Resize = 'on';   op.WindowStyle = 'modal'; 
z = sprintf('%g< %s <%g     ',G(1),im,G(2));
if     isempty(varargin),    ERRon = false;  Na = false;
elseif isnan(varargin{1}),   ERRon = false;  Na = true; 
elseif isnan(varargin{end}), ERRon = true;   Na = true;
else                         ERRon = true;   Na = false;  end 
S   = num2str(I);                
while true   
   C = inputdlg(z,tit,1,{S},op);
   if isempty(C),  if Na,  prie('�� �������� ����'); continue
                   else    I = '';                   return,end,end
   S = C{1};           I = str2num(S);   
   if isempty(I),      prie('������������ ���� �����');     continue,end      
   if size(I,1) ~= 1,  prie('�������� ������ �� �������');  continue,end
   if any(I<G(1)) || any(I>G(2)), prie('����� �� �������'); continue,end                  
   if any(mod(I,1)),   prie('���� ������� �����');          continue,end   
   if ERRon
      if    eval(['(' varargin{1} ')']),  return
      else  prie(['�� ��� ��� �������\n' varargin{1}]);  end
   end
end