%________ Выч к-тов a...h для ХФ при ko = [1 1] __________________
% где КО = [sign(x1^2) sign(x2^2)] = [z1 z2] - Классификатор Ос-тей _____
% т.е. для случая [x1^2>0 x2^2>0] == [+ +] == [P P] == nT = 1 || 2
function [a1,a2,b1,b2,c1,c2,d1,d2,e,f,g,h] = ahPP(cx1, cx2, x2, x3)

global J1 DJ1   J2c DJ2c   Y2c DY2c   J2 DJ2   Y2 DY2 DKK3     
u  = J1.*cx1;         v  = DJ1.*cx2;     S1 = J1.*(cx2./cx1-cx1./cx2);   
a2 = u.*DJ2c;         a1 = v.*J2c;       e  = S1.*J2c;
b2 = u.*DY2c;         b1 = v.*Y2c;       f  = S1.*Y2c;  

                      v  = x2.*DKK3;     S2 = x2./x3+x3./x2;
c2 = x3.*DJ2;         c1 = v.*J2;        g  = S2.*J2;     
d2 = x3.*DY2;         d1 = v.*Y2;        h  = S2.*Y2; 
% ab = 1./(cx1.*cx2);  gd = 1./(x3.*x2.*K3);         
