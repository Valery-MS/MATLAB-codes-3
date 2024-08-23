%________ опр КИ-ла при движ вЛево (для nm1=2 методом маятника)
% Смены io нет, io - любое
% f(xv) > 0, xv - 2-вектор
function x0 = KIL2old(n,c,e1,e3,T2,V2,xv,ah,bn,HF,Xf,fv,x1,x2)   
% x1,x2 - предыд корни
%global Ep9 Ep8

xv2 = xv(2);
Cp = xv2;
d  = 1e-8*Cp;    % шаг для м.касательных
h0  =-1e-3/Cp;   % шаг для м.секущих  h<0
h  = h0;
Fp = fv(2); 
C  = Cp+h;     
F  = HF(n,c,e1,e3,T2,V2, C, ah,bn);  
dF = F-Fp;
k1 = 1.4;   k2 = 1.4;
k3 = 2;     k4 = 2;
i=0;
% a_=x1;b_=x2;h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,@bePMv);plot(x_,y_);title(sprintf('x1=%g %g',x1));grid
if dF<0   
   if F < 0,  x0 = [C; xv2];       return
   else       h  = -k1*F *h/dF;  Cp = C; Fp = F; end 
   
   if Cp+h < xv(1) % Cp+h левее левого конца => касательная в т. xv1
      Cp = xv(1);
      Fp = fv(1); 
      C  = Cp+h0;  
      
      F  = HF(n,c,e1,e3,T2,V2, C, ah,bn);  
      dF = F-Fp;
      if dF<=0 && F<0,  x0 = [C; Cp];  return,end 

      h = -k1*F *h0/dF;  Cp = C; Fp = F;      
   end    
else    % h>0 Cp+h правее правого конца => касательная в т. Сp+h
   Cp = Cp-k2*Fp*h/dF;
   h  = -h0;
   C  = Cp+h0;
   F  = HF(n,c,e1,e3,T2,V2,C, ah,bn);
   if F<=0
      h = h+h;
      while true
         Cp = C;  C = Cp+h;
         if HF(n,c,e1,e3,T2,V2,C,ah,bn)>=0,  x0 = [Cp; C]; return,end
         h = h+h;
      end 
   end
   
   Fp = HF(n,c,e1,e3,T2,V2,Cp,ah,bn);
   dF = F-Fp;
   h  = -k1*F *h/dF;  Cp = C; Fp = F;
end                     
C  = Cp+h;     

while true
   i=i+1;
    
   F = HF(n,c,e1,e3,T2,V2,C,ah,bn); 
   if F <= 0 
      if     C < Cp,  x0 = [C; Cp];  return 
      elseif C < xv2, x0 = [C; xv2]; return 
      else
         h = h+h;
         while true
            Cp = C; 
            C  = Cp+h;
            if HF(n,c,e1,e3,T2,V2,C,ah,bn) >= 0
               x0 = [Cp; C];        return
            end
            h = h+h;
         end             
      end          
   elseif i < 3             % Метод секущих
      dF = F-Fp;
      if dF < 0,  h = -k3*F *h/dF;   Cp=C;  Fp=F;   
      else        h = -k3*Fp*h/dF;   end
   elseif F<Fp && h>0   % Метод касательных  ТСВ5-33
      Cp = C+d; 
      Fp = HF(n,c,e1,e3,T2,V2,Cp,ah,bn);    
      dF = Fp-F;     % нормально дб dF<0
      if Fp <= 0
         if Cp < xv2,  x0 = [Cp; xv2]; return
         else     % между C и Ck - Е-корень
            h = h+h; 
            while true
               C  = Cp+h;
               if HF(n,c,e1,e3,T2,V2,C,ah,bn) >= 0
                  x0 = [Cp; C];  return
               end
               Cp = C;  h = h+h;  
            end             
         end
      else
         if dF>0,  Cp=C; Fp=F; end
         h = -k4*Fp*d/dF;
      end
   else  % F>Fp || h<0
      if F>Fp && h<0,  C=Cp;  F=Fp;  end 
      Cp = C-d; 
      Fp = HF(n,c,e1,e3,T2,V2,Cp,ah,bn);    
      dF = Fp-F;     % нормально дб dF<0
          
      if    Fp<=0,  x0 = [Cp; C];  return
      else
         if dF> 0,  Cp=C; Fp=F;  end 
         h = k4*Fp*d/dF;
      end
   end   
   C = Cp+h; 
   % Если х0==char, то - перескок
   if     h<0 && C<x2,  x0 = sprintf('KIL2: %g=C < x2=%g',C,x2); return
   elseif h>0 && C>(Xf+2*x2-x1)/2,  x0 = 'KIL2: C > (Xf+x)/2'; return
   end
end