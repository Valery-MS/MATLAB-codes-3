%________ nT=2 , доп: x1^2 > 0, т.е.KO=[1 1] _____________________
% cx2, x2 - главн числа =>
% J2c DJ2c  Y2c DY2c  J2 DJ2  Y2 DY2 - однородные meshgrid-м-цы
% cx1,x3 - meshgrid-матрицы 
function bePPm2(n,cx1,cx2,x2,x3)
global J1 DJ1 J2c DJ2c  Y2c DY2c  J2 DJ2  Y2 DY2  DKK3
N       = [n n-1 n+1];
[qX qL] = size(cx1);
NN      = N( ones(qX,1),:);
onesL   = ones(1,qL);

J1  = besselj(n, cx1);   DJ1 = 0.5*(besselj(n-1,cx1) - besselj(n+1,cx1));

cX2  = cx2(:, [1 1 1]);    % создание meshgrid-м-цы по n-x
Jc   = besselj( NN, cX2);     
J2c  = Jc(:,1);                  J2c  = J2c (:, onesL);
DJ2c = 0.5*(Jc(:,2) - Jc(:,3));  DJ2c = DJ2c(:, onesL);

X2   = x2(:, [1 1 1]);     % создание meshgrid-м-цы по n-x
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
