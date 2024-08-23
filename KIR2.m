%________ ��� ��-�� ��� ���� ����� (��� nm1=2 ������� ��������)
% ����� io ���, io - �����
% f(x) > 0, x - 2-������
function x0 = KIR2(n,c,e1,e3,T2,V2,x,ah,bn,HF,Ve,f,x1,x2)   
% x1,x2 - ������ �����
%global Ep9 Ep8

xA = x(1);  fA = f(1);
xB = x(2);  fB = f(2);
d  = 1e-8*xB;    % ��� �.�����������
D  = 1e-3/xB;    % ��� �.�������  

fAB= fA<fB;
h =-D;
if fAB,   Cp = xA;  Fp = fA;
else      Cp = xB;  Fp = fB;  end

C  = Cp+h;     
F  = HF(n,c,e1,e3,T2,V2, C, ah,bn);  
dF = F-Fp;
k1 = 1.4;   k2 = 1.4;
k3 = 2;     k4 = 2;
i=0;

% a_=x1;b_=x2;h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,@bePMv);plot(x_,y_);title(sprintf('x1=%g %g',x1));grid
if dF<0   
   if F <= 0
      if fAB,  x0 = [C; xB];    return
      else
         h = h+h;
         while true
            Cp = C;  C = Cp+h;
            if HF(n,c,e1,e3,T2,V2,C,ah,bn)>=0,  x0 = [Cp; C]; return,end
            h = h+h;
         end 
      end
   else    h = -k1*F *h/dF;  Cp = C;  Fp = F;
   end 
else   h = -k2*Fp*h/dF;  i = 3; % ������ ������ ��=>�������� � �.���. Cp �� ���
end                     
C  = Cp+h;     

while true
   i=i+1; 
   F = HF(n,c,e1,e3,T2,V2,C,ah,bn); 
   if F <= 0 
      if     C < Cp,  x0 = [C; Cp];  return 
      elseif C < xB, x0 = [C; xB]; return 
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
   elseif i < 3             % ����� �������
      dF = F-Fp;
      if dF < 0,  h = -k3*F *h/dF;   Cp=C;  Fp=F;   
      else        h = -k3*Fp*h/dF;   end
   elseif F<Fp && h>0   % ����� �����������  ���5-33
      Cp = C+d; 
      Fp = HF(n,c,e1,e3,T2,V2,Cp,ah,bn);    
      dF = Fp-F;     % ��������� �� dF<0
      if Fp <= 0
         if Cp < xB,  x0 = [Cp; xB]; return
         else     % ����� C � Ck - �-������
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
      dF = Fp-F;     % ��������� �� dF<0
          
      if    Fp<=0,  x0 = [Cp; C];  return
      else
         if dF> 0,  Cp=C; Fp=F;  end 
         h = k4*Fp*d/dF;
      end
   end   
   C = Cp+h; 
   % ���� �0==char, �� - ��������
   if     h<0 && C>x2,  x0 = sprintf('KIR2: %g=C > x2=%g',C,x2); return
   elseif h>0 && C<(Ve+2*x2-x1)/2,  x0 = 'KIR2: C < (Ve+x)/2'; return
   end
end