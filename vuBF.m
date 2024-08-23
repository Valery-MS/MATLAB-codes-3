% ____________Выч уровней б.ф-ции F(x)___________________________________
function nu = vuBF( F, man, Lev)
nu = zeros(man+1,1);  xa = eps;         
h  = 1;               AT = '';                                 
for n = 1:man+1,       j = 0;    
   ZL = @(x) F(n-1,x)-Lev;
   Fa = ZL(xa);    xb = xa+h;    Fb = ZL(xb);
   if     Fa == 0, nu(n) = xa;  continue
   elseif Fb == 0, nu(n) = xb;  continue,end
   
   while  Fa * Fb > 0,   j = j+1; 
      if j > 700, prie('Fa*Fb = %g*%g >0\n700 раз!\n',Fa,Fb); return,end
      Fa = Fb;   xb = xb+h;   Fb = ZL(xb);
   end      
   try [nu(n) fv FL out] = fzero(ZL,[xb-h xb]);
   catch ME, AT = sprintf('%s\nn = %g,  уровень = %g',ME.message,n,Lev);
      if exist('FL','var')
         AT = [AT sprintf('\nf=%g, FL=%g\n%s',fv,FL,out.message)];end
   end
 
   if ~exist('FL','var') || FL < 0
      prie('Авост\nНайдено %g корней из %g\n%s',n-1,man,AT);
      nu(n:end) = [];  return
   end
   xa = nu(n); 
end
