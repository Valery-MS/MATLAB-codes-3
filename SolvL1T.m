% ______ ������� �� HF(x,L)=0 ������������ � ��� L=L1:h:L9 �����
% ______ nm1 = 1. ���� ������� ����� �: io:2->1
% �� ����������� ������! �.�. ����� io ���.
function X = SolvL1T(KZ,nT,n,c,dva,io,hL,L1, q,x1,x2,x0ep,LZ1,Xf)    

% x1 = X(L1), x2 = X(L1-hL)                    

global stat 
global eVTs HFs ahis bJYIK
global qHF;  qK1=0; qF1=0; km1=0;  qK2=0; qF2=0; km2=0;  sm=0;

%_________________________1 ����� ������_______________________________ 
X   = nan(q,1);  
eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT}; 
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1);

io_2 = true; ah  = ahi{io};  bv  = bvs{io};  bn  = bns{io};

[e1v e3v V2v T2v] = eVT( KZ, (L1:-hL:LZ1).^2, dva);
KIN = @KIN1;

%_____________________ 2 ����: ����� ������ ____________________________  
i  = 1; 
Xp = x2;
Lp = L1+hL;

while i <= q 
  e1 = e1v(i);  e3 = e3v(i);   
  V2 = V2v(i);  T2 = T2v(i);
  %[e1 e3 V2 T2] = eVT( KZ, (Lp-hL)^2, dva);  % Lp-hL=L �������
     
  x0e = extDLfr ( x1,x2,Xf, Lp+hL,Lp );  
  %hx  = abs(x0e - Xp); 
     
  if Xp == x0ep,  x0 = [max(x0e-AP,eps100); x0e+AP]; 
  else
     dX = Xp-x0ep;
     AP = abs(dX);             % ������ �� ���� ����
     x0 = [x0e; x0e+AP]; 
     % AP2 = AP+AP;   
     % if dX > 0,   x0 = [x0e; x0e+AP2];
     % else         x0 = [x0e-AP2; x0e]; end; 
  end
      
  if io_2 && x0e*x0e < T2
     io = 1;   
     sm = i;
     if x0(2)^2 > T2,  x0 = [x0e-AP;  x0e]; end
     ah = ahi{io};  bn = bns{io};  bv = bvs{io};
     if nT==2,  KIN = KIN1B;  end
  end
                            % ������-�������  
  %figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f = HF(n,c,e1,e3,T2,V2,x0,ah,bv);
  
  qHFa = qHF;
  if f(1)*f(2)>0  % f1*f2>0 �������,�� �-����� ���
     x0 = KIN( n,c,e1,e3,T2,V2,x0,ah,bn,HF,Xf,f); 
     if ischar(x0)
        X = sprintf('Solv51 nT=%d io=%d i=%d/n%s',nT,io,i,x0); return
     end 
  end
  
  k = qHF-qHFa;        % �-�� ��������� � �-��� � KIN
  if k
     if io==1, qK1=qK1+1; qF1=qF1+k;  if k>km1, km1=k;end    
     else      qK2=qK2+1; qF2=qF2+k;  if k>km2, km2=k;end,end  
  end
               
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);       
  catch ME, FL = -10;   end  % f ����� �� ����� �� ������ x0                          
  
  if FL == 1                 % � ����(i+1-��) �����    
     X(i) = Xp;  x1 = x2;  x2 = Xp;
     Lp   = Lp-hL;
     i    = i+1;
     x0ep = x0e;                           
  else                       % �����   
     X = sprintf(['SolvL1T: ������ �� ������\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % ����� �� i

stat(6:14) = [qK1; qF1; round(qF1/qK1); km1; sm; qK2; qF2; round(qF2/qK2); km2]; 