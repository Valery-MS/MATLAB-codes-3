% Вместо этой пр-мы усоверш пр-ма - KIL22

%________ опр КИ-ла при движ вЛево (для nm1=2 методом маятника)
% Здесь io==2. Если корень не найден, тк не то io, то х0=NaN
function x0 = KIL2T(n,c,e1,e3,T2,V2,xv,ah,bn,HF,Xf,fv,x1,x2)  
% x1,x2 - предыд корни
%global Ep9 Ep8
                           % ТСВ5-36
xv2 = xv(2);
Cp = xv2;
d  = 1e-8*Cp;   % шаг для м.касательных
h0 =-1e-3/Cp;   % шаг для м.секущих  h<0
h  = h0;
Fp = fv(2); 
C  = Cp+h;     
F  = HF(n,c,e1,e3,T2,V2, C, ah,bn);  
dF = F-Fp;
k1 = 1.3;   k2 = 1.4;
k3 = 2;     k4 = 2;
i=0; 
isT = false;

if dF<0   % h<0
   if F<0,  x0 = [C; xv2];     return
   else     h  = -k1*F *h/dF;  Cp = C; Fp = F; end 
   
   if Cp+h < xv(1) % Cp+h левее левого конца => касательная в т. xv1
      Cp = xv(1);
      Fp = fv(1); 
      C  = Cp+h0;  
      
      if C^2 < T2
         T  = sqrt(T2);
         Tp = T+d;
         if HF(n,c,e1,e3,T2,V2,Tp,ah,bn)<=0, x0 = [Tp; Cp]; 
         else                                x0 = NaN;  end  % здесь смена io->1
         return 
      end 
      
      F  = HF(n,c,e1,e3,T2,V2, C, ah,bn);  
      dF = F-Fp;
      if dF<=0   
         if F<0,  x0 = [C; Cp];  return,end
         isT = true;  T = sqrt(T2);   
      end 
      h = -k1*F *h0/dF;  Cp = C; Fp = F;      
   end 
else     % h>0 Cp+h правее правого конца => касательная в т. Сp+h
   Cp = Cp-k2*Fp*h/dF;
   h  = -h0;
   C  = Cp+h0;
   F  = HF(n,c,e1,e3,T2,V2,C, ah,bn);
   if F<=0
      h = h+h;
      while true
         Cp = C; 
         C  = Cp+h;
         if HF(n,c,e1,e3,T2,V2,C,ah,bn) >= 0
            x0 = [Cp; C];   return
         end
         h = h+h;
      end 
   end
   
   Fp = HF(n,c,e1,e3,T2,V2,Cp,ah,bn);
   dF = F-Fp;
   h  = -k1*F *h/dF;  Cp = C; Fp = F;
end                     
C = Cp+h;     

while true
   i=i+1;
   if isT  &&  C <= T
      Tp = T+d;
      if HF(n,c,e1,e3,T2,V2,Tp,ah,bn)<=0, x0 = [Tp; Cp]; 
      else                                x0 =  ;  end  % здесь смена io->1
      return 
   end 
    
   F = HF(n,c,e1,e3,T2,V2,C,ah,bn); 
   if F <= 0 
      if     C < Cp,   x0 = [C; Cp];  return 
      elseif C < xv2,  x0 = [C; xv2]; return 
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
         if Cp < xv2,  x0 = [Cp; xv2];  return
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
   if     h<0 && C<x2,  x0 = sprintf('KIL2T: %g=C < x2=%g',C,x2); return
   elseif h>0 && C>min(Xf,x2+3*(x2-x1)),  x0 = 'KIL2T: C > Cmax'; return
   end   
end

%{
                           % ТСВ5-32
Cp = x0(1);   FA = f(1);
B  = x0(2); 
d  = 1e-8*Cp;   % шаг для м.касательных.
e  = 1e-3/Cp;   % шаг для м.секущих
C  = Cp+e;
Fp = HF(n,c,e1,e3,T2,V2, C, ah,bn);
dF = Fp-FA;
k1 = 1.4;   k2 = k1;
k3 = 2;     k4 = 2;
i=0; 
if dF > 0   % h<0
   isT = true;     T = sqrt(T2);  
   h = -k1*FA*e/dF;
   C = Cp+h; 
   if C <= T  &&  Cp > T,  x0 = NaN;  return,end
   Fp = FA;  
elseif Fp < 0
   if C < B,   x0 = [C; B];  return
   else
      h = e;
      while true
         Cp = C; 
         C  = C+h;
         if HF(n,c,e1,e3,T2,V2, C, ah,bn) >= 0
            x0 = [Cp; C];        return
         end
         h = h+h;
      end   
   end   
else
   isT = false;
   FB  = f(2); 
   Cp  = B-e;     
   FCB = HF(n,c,e1,e3,T2,V2, Cp, ah,bn);  
   dFB = FB-FCB;
   if dFB > 0
      if FCB < 0,   x0 = [Cp; B]; return
      else
         ChA = C  -Fp*e/dF;      % >0
         ChB = Cp-FCB*e/dFB;    % <0
         Cp  = (ChA+ChB)/2;
         Fp  = HF(n,c,e1,e3,T2,V2, Cp, ah,bn); 
         if Fp < 0,  x0 = [Cp; ChB];  return
         else        h  = (ChB-Cp)/2;  C = Cp+h;  end
      end
   else    % dFB < 0  аналогично  dF > 0
      h = -k2*FB*e/dFB;   % >0
      C = Cp+h;
      Fp = FCB;
   end
end 

while true
   i=i+1;
   if isT  &&  C <= T
      Tp = T+d;
      if HF(n,c,e1,e3,T2,V2,Tp,ah,bn)<=0, x0 = [Tp; Cp]; 
      else                                x0 = NaN;  end
      return 
   elseif C >= Xf  
      FF = HF(n,c,e1,e3,T2,V2,Xf,ah,bn);
      if Fp*FF<0, x0 = [Cp; Xf]; 
      else        x0 = 'Корня в напр Xfar нет';  return,end
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
      Cp = C;  Fp=F;                         
   elseif F<Fp && h>0   % Метод касательных  ТСВ5-33
      Cp = C+d; 
      Fp = HF(n,c,e1,e3,T2,V2,Cp,ah,bn);    
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
      Fp = HF(n,c,e1,e3,T2,V2,Cp,ah,bn);    
      dF = Fp-F;     % нормально дб dF<0
          
      if    Fp<=0,  x0 = [Cp; C];  return
      else
         if dF> 0,  Cp=C; Fp=F;  end 
         h = k4*Fp*d/dF;
      end
   end   
   C = Cp+h; 
end
%}

%{
              %  Метод маятника( ТСВ5-31)
%nap = 0;     % счетчик шагов в одном направлении без изм длины шага
%mi = 0;  ma = 0;      
   else
   if F > Fp %  поворот маятника при перепрыгивании лунки
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
      elseif ~mi || C+h>=mi,     Cp  = C;   % нет поворота
      else                                  % поворот
         if F<Fmi,  ma = Cp;  Fma = Fp;
         else       ma = C;   Fma = F;  end
         h = 0.6*(C-mi);
         Cp = mi;  F = Fmi;
      end
      C = Cp+h;                             % м.маятника
   end
   %}   