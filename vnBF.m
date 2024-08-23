% ____________Выч QN Нулей б.ф-ции F(x)__________________________________
function nu = vnBF( F, n, QN)
nu = zeros(QN,1);    h   = 1;
xb = 1;              Fb  = F(n,xb); 
i  = 1;              Qit = 20;                    
while i <= QN
   Fa = Fb;    xb = xb+h;    Fb = F(n,xb);
   if     Fa == 0, nu(i) = xb-h;  continue
   elseif Fb == 0, nu(i) = xb;    continue,end 
   
   while Fa * Fb > 0,   Fa = Fb;   xb = xb+h;   Fb = F(n,xb); end
   
   try [nu(i) fv FL out] = fzero(@(x) F(n,x),[xb-h xb]);
   catch ME,  AT = sprintf('%s\nпри поиске %g-го корня',ME.message,i);
      if exist('fv','var')
         AT = [AT sprintf('\nf = %g, FL = %g\n%s',fv,FL,out.message)];end
      prie(AT);  return
   end  
  
   if FL < 0,  it = it+1;
   else        it = 0;    i = i+1;  end                 
   if it > Qit
      prie('Найдено %g корней из %g',i-1,QN);
      nu(i:end) = [];  return
   end
end
