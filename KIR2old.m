%________ опр КИ-ла при движ вПраво(для nm1=2 методом маятника)
function x0 = KIR2old(n,c,e1,e3,T2,V2, x0,ah,bn,HF,Ve,f)
global Em9 
global Pi

% ТСВ5-8
% f(1),f(2) > 0
% LUR = xH-xE - луночный (характ) размер

A  = x0(1);   F = f(1);
Ae = A*Em9;
h  = F*(A-Ae)/(HF(n,c,e1,e3,T2,V2, Ae, ah,bn)-F);
if h < 0,  Cp = A; C = Cp+h+h;  Pi = 1;
else
   B  = x0(2); FB = f(2);
   Be = B*Em9; 
   hB = FB*(B-Be)/(HF(n,c, e1,e3, T2,V2, Be, ah,bn)-FB);
   Cp = B+hB;
   if hB < 0,   h = (A+h-Cp)*0.25;  C = Cp+h+h;  
   else         h = hB;             C = Cp+h;   end 
   Pi = 2;
end 

nap = 0;      % счетчик шагов в одном направлении без изм длины шага
mi = 0;  ma = 0;
firV = true;
while true, Pi=Pi+1;
   if C >= Ve  
      if firV  && Cp == Ve  %if fV выч(firV=0), то еще кор не найд: fC*fV>0 
         firV = false;
         FV = HF(n,c,e1,e3,T2,V2, Ve, ah,bn);
         if F*FV<0,  x0 = [Cp; Ve];  return,end
      end
      C = Cp; h = 0.5*h;
      continue
   end  
   
   Fp = F;  
   F  = HF(n,c,e1,e3,T2,V2, C, ah,bn);
   if F < 0 
      if h < 0,   x0 = [C; Cp];     return 
      else
         while true
            Cp = C; 
            C  = C+h;
            if HF(n,c,e1,e3,T2,V2, C, ah,bn) >= 0
               x0 = [Cp; C];    return
            end
            h = h+h;
         end               
      end  
   end
                           % ТСВ5-31
   if F > Fp  % поворот маятника при перепрыгивании лунки
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
      elseif ~mi || C+h>=mi,    Cp  = C;    % нет поворота
      else                                  % поворот
         if F<Fmi,  ma = Cp;  Fma = Fp;
         else       ma = C;   Fma = F;  end
         h = 0.6*(C-mi);
         Cp = mi;  F = Fmi;
      end
   end  
   C = Cp+h;
end 