%__________ nT=2, ���: �x1^2 < 0, �.�.KO=[-1 1] _______________________
function beMPm(n,cx1,cx2,x2,x3)
% cx2,x2 - ������� ����� => 
% J2c DJ2c  J2 DJ2   Y2c DY2c  Y2 DY2 - ���������� meshgrid-�-��
% cx1,x3 - meshgrid-������� 
global J1 DJ1   J2c DJ2c  J2 DJ2   Y2c DY2c  Y2 DY2   DKK3
N       = [n n-1 n+1];
[qX qL] = size(cx1);
NN      = N( ones(qX,1),:);
onesL   = ones(1,qL);
% cx1 - ������� �� ���������� ��������, => J1 ������� ��� ���
% J1v = besseli(n, cx1(:,1)); q=size(cx1,2); J1 = J1v(:,ones(1,q)) 
% ��� q=2 �������� ���������,  ��� ����� q ������� � ��-�� ����������
% ��� ��������� ����������� � ��� Jc, JYc,Y
J1  = besseli(n, cx1);   DJ1 = 0.5*(besseli(n-1,cx1) + besseli(n+1,cx1));

cX2  = cx2(:, [1 1 1]);    % �������� qX*3-�-�� �� qX*2-�-��
Jc   = besselj( NN, cX2);     
J2c  = Jc(:,1);                  J2c  = J2c (:, onesL);
DJ2c = 0.5*(Jc(:,2) - Jc(:,3));  DJ2c = DJ2c(:, onesL);

X2   = x2(:, [1 1 1]);     % �������� meshgrid-�-�� �� n-x
J    = besselj( NN, X2);     
J2   = J(:,1);                   J2  = J2 (:, onesL);
DJ2  = 0.5*(J(:,2) - J(:,3));    DJ2 = DJ2(:, onesL);

Yc   = bessely( NN, cX2);     
Y2c  = Yc(:,1);                  Y2c  = Y2c (:, onesL);
DY2c = 0.5*(Yc(:,2) - Yc(:,3));  DY2c = DY2c(:, onesL);

Y    = bessely( NN, X2);     
Y2   = Y(:,1);                   Y2  = Y2 (:, onesL);
DY2  = 0.5*(Y(:,2) - Y(:,3));    DY2 = DY2(:, onesL);

DKK3 =-0.5*(besselk(n-1,x3) + besselk(n+1,x3))./besselk(n,x3);