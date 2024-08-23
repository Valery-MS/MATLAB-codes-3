%________ ��� �� ��� 3-�� ��. Mathcad-9.���������� ��-��� ______________
function HF = HF3( n, e1,e3, cx1, cx2, x2, x22z, x32, ah, be)
% ���: ��������� ���-� � ��������:
% ������������� ��� ������������ ������ ��� ���������� � ��������������
% => ��������� ��������� ���-�� �������� � ����� ������������: v(:,[1 1])

global qHF; qHF=qHF+1;  % �-��(quantity) ������� �.�-��� HF - �����. ����������

x3 = sqrt(x32);
be( n, cx1, cx2, x2, x3) 

[a1,a2,b1,b2,c1,c2,d1,d2,e,f,g,h] = ah( cx1, cx2, x2, x3);
a = a2 - a1;      b = b2 - b1;      c  = c2 + c1;      d  = d2 + d1;
a_= a2 - a1.*e1;  b_= b2 - b1.*e1;  c_ = c2 + c1.*e3;  d_ = d2 + d1.*e3;

nU2 = (n*n)*(e3.*x22z + x32)./(x22z + x32);
HF = (a.*d - b.*c).*(a_.*d_- b_.*c_)./nU2 ...
    +(e.*h - f.*g).^2 .*nU2               ...
    -(a.*h - b.*g).*(a_.*h - b_.*g)       ...
    -(c.*f - d.*e).*(c_.*f - d_.*e)       ...
  -2*(c.*h - d.*g).*(a .*f - b .*e);