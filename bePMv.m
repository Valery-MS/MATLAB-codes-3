%________nT=1, иксы - векторы, доп: x2^2 < 0, т.е. KO=[1 -1] _JIKv_______
function bePMv(n,cx1,cx2,x2,x3)
global J1 DJ1 J2c DJ2c  Y2c DY2c  J2 DJ2  Y2 DY2  DKK3
N     = [n n-1 n+1];
qx    = numel(cx1);
NN    = N( ones(qx,1),:);
ones3 = [1 1 1];

cX1 = cx1(:);             % преобр в столбец
cX1 = cX1(:, ones3);      % создание meshgrid-м-цы
J   = besselj( NN, cX1);     
J1  = J(:,1);
DJ1 = 0.5*(J(:,2) - J(:,3));

cX2  = cx2(:);
cX2  = cX2(:, ones3);
Ic   = besseli( NN, cX2);
J2c  = Ic(:,1);
DJ2c = 0.5*(Ic(:,2) + Ic(:,3));

X2  = x2(:);
X2  = X2(:, ones3);
I   = besseli( NN, X2);
J2  = I(:,1);
DJ2 = 0.5*(I(:,2) + I(:,3));

Kc   = besselk( NN, cX2);
Y2c  = Kc(:,1);
DY2c = -0.5*(Kc(:,2) + Kc(:,3));

K   = besselk( NN, X2);
Y2  = K(:,1);
DY2 = -0.5*(K(:,2) + K(:,3));

X3   = x3(:);
X3   = X3(:, ones3);
K3   =  besselk( NN, X3);
DKK3 = -0.5*(K3(:,2) + K3(:,3))./K3(:,1);
