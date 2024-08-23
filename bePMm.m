%________ nT=1 , доп: x2^2 < 0, т.е. KO=[1 -1]_____________________
% cx1 - главное число => J1 DJ1 - однородные meshgrid-м-цы
% cx2,x2,x3 - meshgrid-матрицы 
function bePMm(n,cx1,cx2,x2,x3)
global J1 DJ1 J2c DJ2c  Y2c DY2c  J2 DJ2  Y2 DY2  DKK3
N       = [n n-1 n+1];
[qX qL] = size(cx1);
NN      = N( ones(qX,1),:);
onesL   = ones(1,qL);

cX1 = cx1(:, [1 1 1]);    % создание meshgrid-м-цы по n-x
J   = besselj( NN, cX1);     
J1  = J(:,1);               J1  = J1 (:, onesL);
DJ1 = 0.5*(J(:,2)-J(:,3));  DJ1 = DJ1(:, onesL);
% сравнить и удалить б.медленный вар-т выч J1, DJ1 
J1  = besselj(n, cx1);   DJ1 = 0.5*(besselj(n-1,cx1) - besselj(n+1,cx1));

J2c = besseli(n, cx2);   DJ2c= 0.5*(besseli(n-1,cx2) + besseli(n+1,cx2));
J2  = besseli(n, x2);    DJ2 = 0.5*(besseli(n-1,x2)  + besseli(n+1,x2));
Y2c = besselk(n, cx2);   DY2c=-0.5*(besselk(n-1,cx2) + besselk(n+1,cx2));
Y2  = besselk(n, x2);    DY2 =-0.5*(besselk(n-1,x2)  + besselk(n+1,x2));

DKK3 =-0.5*(besselk(n-1,x3) + besselk(n+1,x3))./besselk(n,x3);