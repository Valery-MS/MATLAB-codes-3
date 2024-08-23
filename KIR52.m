%________ ��� ��-�� ��� ���� ������(��� nm1=2 ������� ��������)
function x0 = KIR52(n,c,e1,e3,T2,V2,x0,ah,bn,HF,Ve,f)
global  Em9 
% ���5-8
% f(1),f(2) > 0
% LUR = xH-xE - �������� (������) ������
LUR =0;

A  = x0(1);   F = f(1);
Ae = A*Em9;
h  = F*(A-Ae)/(HF(n,c,e1,e3,T2,V2, Ae, ah,bn)-F);
if h < 0,  Cp = A; C = Cp+2*h;
else
   B  = x0(2); FB = f(2);
   Be = B*Em9; 
   hB = FB*(B-Be)/(HF(n,c, e1,e3, T2,V2, Be, ah,bn)-FB);
   Cp = B+hB;
   if hB < 0,   h = (A+h-Cp)*0.25;  C = Cp+h+h;  
   else         h = hB;             C = Cp+h;   end 
end 

nap  = 0;     % ������� ����� � ����� ����������� ��� ��� ����� ����
firV = true;
while true
   if C >= Ve             
      if firV  && Cp == Ve  %if fV ���(firV=0), �� ��� ��� �� ����: fC*fV>0 
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
         if LUR,  x0 = [C; C+LUR];  return,end 
         
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
   
   if F > Fp     % ������� ��� �������������� �����
      nap = 0;
      if h > 0,  h  = -0.7*max(LUR,h);
      else       h  =  0.7*max(LUR,-h);  end
   elseif nap == 3, nap = 0;   h = h+h;  % ��� h: �� 3 ���� ��� �� ����
   else             nap = nap+1;
   end 
   Cp = C;
   C  = Cp+h;   
end 