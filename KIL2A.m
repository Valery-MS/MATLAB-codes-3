%________ опр КИ-ла при движ вЛево (для nm1=2 методом маятника)
function x0 = KIL2A(n,c,e1,e3,T2,V2,x0,ah,bn,HF,XF,f)                    
%global Ep9
global Pi

A  = x0(1);   
Cp = A;
d  = 1e-8*Cp;   % шаг для м.касательных
h  = 1e-3/Cp;   % шаг для м.секущих  h<0
Fp = f(1); 
C  = Cp+h;     
F  = HF(n,c,e1,e3,T2,V2, C, ah,bn);  
dF = F-Fp;
k1 = 1.3;   k2 = 1.4;
k3 = 2;     k4 = 2;
i=0; Pi = 1;
if dF < 0    
   if Fp < 0,  x0 = [C; B];       U(1)=U(1)+1;  return
   else        h  = -k1*F *h/dF;  Cp = C; Fp = F; end 
else           h  = -k2*Fp*h/dF;  isT = false;
end                     
C  = Cp+h;  

nap = 0;     % счетчик шагов в одном направлении без изм длины шага
mi = 0;   ma = 0;
while true, Pi=Pi+1;
   if C >= XF  
      FF = HF(n,c,e1,e3, T2,V2, XF, ah,bn);
      if F*FF<0, x0 = [Cp; XF]; 
      else       x0 = 'Корня в напр XFar нет';  return,end
   end 
    
   Fp = F;  
   F  = HF( n, c, e1,e3, T2, V2, C, ah,bn);
   if F < 0 
      if h<0,     x0 = [C; Cp];     return 
      else
         while true
            Cp = C; 
            C  = C+h;
            if HF(n,c,e1,e3,T2,V2, C, ah,bn) >= 0
               x0 = [Cp; C];        return
            end
            h = h+h;
         end             
      end
   end
                        % ТСВ5-31
   if F > Fp   % поворот маятника при перепрыгивании лунки
      nap = 0;  
      if h < 0,  mi = C;  Fmi = F;
      else       ma = C;  Fma = F;  end
      h = -h/2;  
   else
      if nap<=2,  nap = nap+1; 
      else        nap = 0;  h = h+h;  end
      
      if h > 0
         if ~ma || C+h<=ma,      Cp  = C;   % нет поворота
         else                               % поворот
            if F<Fma,  mi = Cp;  Fmi = Fp; 
            else       mi = C;   Fmi = C;  end
            h  = -0.4*(ma-C); 
            Cp = ma;  F = Fma;
         end
      elseif ~mi || C+h>=mi,  Cp  = C;      % нет поворота
      else                                  % поворот
         if F<Fmi,  ma = Cp;  Fma = Fp;
         else       ma = C;   Fma = F;  end
         h = 0.6*(C-mi);
         Cp = mi;  F = Fmi;
      end
   end  
   C = Cp+h;
end 