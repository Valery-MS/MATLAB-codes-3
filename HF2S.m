%            2-слойный световод
%____________ХФ 2 сл СВ_________________________________________________
function f = HF2S( nT, n, c, e1, V_2, x, KO )
% 2 сл СВ, здесь NTR=NR № режима
% nT, c, KO - не используются
[x2, y2, J, xDJJ, yDKK] = JK(n, V_2, x);

y22 = y2./x2;
A = xDJJ.*J.*y22;
B = yDKK.*J; 

f  = (A+B).*(e1.*A+B)-(n*J).^2./x2.*V_2.*(e1.*y22+1);
i0 = x == 0;
if any(i0)
   if n == 1,  f(i0) = -0.5*e1*y2(i0);
   else        f(i0) = 0;  end
end

%_______________________________________________________________________
function [x2, y2, J, xDJJ, yDKK] = JK(n, V_2, x)
x2 = x.^2;       y2 = V_2-x2;   
y2(y2<0) = NaN;  y = sqrt(y2);
J    = besselj(n,x);
xDJJ = 0.5*(besselj(n-1,x)-besselj(n+1,x)).*x./J;
yDKK =-0.5*(besselk(n-1,y)+besselk(n+1,y)).*y./besselk(n,y);
xDJJ(x<eps) =  n;  
yDKK(y<eps) = -n; 
