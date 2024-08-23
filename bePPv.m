%________nT=1, sign([x1 x2]^2)=++=PP, xi - �������, KO=[1 1] JJYv _______
function bePPv(n,cx1,cx2,x2,x3)
% �-��� JJYv � IJYv  � ����� ����� J1 DJ1 ���������
global J1 DJ1 J2c DJ2c  Y2c DY2c  J2 DJ2  Y2 DY2  DKK3
N     = [n n-1 n+1];
qx    = numel(cx1);
NN    = N( ones(qx,1),:);
ones3 = [1 1 1];

cX1 = cx1(:);             % ������ � �������
cX1 = cX1(:, ones3);      % �������� meshgrid-�-��
J   = besselj( NN, cX1);     
J1  = J(:,1);
DJ1 = 0.5*(J(:,2) - J(:,3));

cX2  = cx2(:);
cX2  = cX2(:, ones3);
Jc   = besselj( NN, cX2);
J2c  = Jc(:,1);
DJ2c = 0.5*(Jc(:,2) - Jc(:,3));

X2  = x2(:);
X2  = X2(:, ones3);
J   = besselj( NN, X2);
J2  = J(:,1);
DJ2 = 0.5*(J(:,2) - J(:,3));

Yc   = bessely( NN, cX2);
Y2c  = Yc(:,1);
DY2c = 0.5*(Yc(:,2) - Yc(:,3));

Y   = bessely( NN, X2);
Y2  = Y(:,1);
DY2 = 0.5*(Y(:,2) - Y(:,3));

X3   = x3(:);
X3   = X3(:, ones3);
K3   =  besselk( NN, X3);
DKK3 = -0.5*(K3(:,2) + K3(:,3))./K3(:,1);