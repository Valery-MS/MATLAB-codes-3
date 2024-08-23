%________ опр КИH при движ вЛево для nm1=2 ТСВ5-35
function x0 = KIL2T_B(n,c,e1,e3,T2,V2,x0,ah,bn,HF,XF,f)              
%global Ep9 Ep8
global Pi it U
                           % ТСВ5-36
Cp = x0(2); 
d  = 1e-8*Cp;   % шаг для м.касательных
h  =-1e-3/Cp;   % шаг для м.секущих  h<0
Fp = f(2); 
C  = Cp+h;     
F  = HF(n,c,e1,e3,T2,V2, C, ah,bn);  
dF = F-Fp;
k1 = 1.3;   k2 = 1.4;
k3 = 2;     k4 = 2;
i=0; 
if dF < 0   
   isT = true; T = sqrt(T2);  
   if Fp < 0,  x0 = [C; B];       U(2)=U(2)+1;  return
   else        h  = -k1*F *h/dF;  Cp = C; Fp = F; end 
else           h  = -k2*Fp*h/dF;  isT = false;
end                     
C  = Cp+h;     

while true
   it=it+1;  i=i+1;
   if isT  &&  C <= T
      Tp = T+d;
      if HF(n,c,e1,e3,T2,V2,Tp,ah,bn)<=0, x0 = [Tp; Cp]; 
      else                                x0 = NaN;  end
      return 
   elseif C >= XF  
      FF = HF(n,c,e1,e3,T2,V2,XF,ah,bn);
      if Fp*FF<0, x0 = [Cp; XF]; 
      else        x0 = 'Корня в напр XFar нет';  return,end
   end 
    
   F = HF(n,c,e1,e3,T2,V2,C,ah,bn); 
   if F <= 0 
      if     C < Cp,  x0 = [C; Cp];  return 
      elseif C < B,   x0 = [C; B];   return 
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
      h  = -k3*F*h/(F-Fp);
      Cp = C;  Fp=F;                          Pi = Pi+1;
   elseif F<Fp && h>0   % Метод касательных  ТСВ5-33
      Cp = C+d; 
      Fp = HF(n,c,e1,e3,T2,V2,Cp,ah,bn);      Pi = Pi+2;
      dF = Fp-F;     % нормально дб dF<0
      if Fp <= 0
         if Cp < B,  x0 = [Cp; B];  return
         else     % между C и Ck - Е-корень
            h = h+h; 
            while true
               C  = Cp+h;
               if HF(n,c,e1,e3,T2,V2,C,ah,bn) >= 0
                  x0 = [Cp; C];        return
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
      Fp = HF(n,c,e1,e3,T2,V2,Cp,ah,bn);      Pi = Pi+2;
      dF = Fp-F;     % нормально дб dF<0
          
      if    Fp<=0,  x0 = [Cp; C];  return
      else
         if dF> 0,  Cp=C; Fp=F;  end 
         h = k4*Fp*d/dF;
      end
   end   
   C = Cp+h; 
end