% ______ ������� �� HF(x,L)=0 ������������ � ��� L=L1:h:L9 �����
% ______ nm1 = 1
% ����������� ������ ��� io=2
function X = SolvL1(KZ,nT,n,c,dva,io,hL,L0, q,x1,x2,x0ep,LZ1,Xf)   

% x1 = XC(2) = X(L1+hL) = X(L0+2hL),  
% x2 = XC(1) = X(L1)    = X(L0+hL) 

global stat 
global eps100
global eVTs HFs ahis bJYIK
global qHF;  qK=0; qF=0; km=0; 

%_________________________1 ����� ������_______________________________ 
X   = nan(q,1); 
eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT}; 
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1);
ah  = ahi{io};  bv  = bvs{io};  bn  = bns{io};

[e1v e3v V2v T2v] = eVT( KZ, (L0:-hL:LZ1).^2, dva);

if nT==1 || io==2,  KIN = @KIN1;
else                KIN = @KIN1B; end

%_____________________ 2 ����: ����� ������ ____________________________   
i  = 1; 
Xp = x2;
Lp = L0+hL;

while i <= q 
  e1 = e1v(i);  e3 = e3v(i);   
  V2 = V2v(i);  T2 = T2v(i);
  %[e1 e3 V2 T2] = eVT( KZ, (Lp-hL)^2, dva);  % Lp-hL=L �������
   
  x0e = extDLfr ( x1,x2,Xf, Lp+hL,Lp );  
  %hx  = abs(x0e - Xp); 

  dX = Xp-x0ep;
  AP = abs(dX);             % ������ �� ���� ����
  if dX ~= 0,  x0 = [x0e; x0e+AP]; 
  else         x0 = [max(x0e-AP,eps100); x0e+AP]; 
  end      
     % AP2 = AP+AP;   
     % if dX > 0,   x0 = [x0e-AP/2; x0e+AP2];
     % else         x0 = [x0e-AP2;  x0e]; end;
  
                            % ������-�������  
  %figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f = HF( n, c, e1,e3, T2,V2, x0, ah, bv);
  
  qHFa = qHF;
  if f(1)*f(2)>0  % f1*f2>0 �������,�� �-����� ���
     x0 = KIN( n,c,e1,e3,T2,V2,x0,ah,bn,HF,Xf,f); 
     if ischar(x0)
        X=sprintf('Solv51 nT=%d io=%d i=%d/n%s',nT,io,i,x0); return
     end 
  end
  
  k = qHF-qHFa;       % �-�� ��������� � �-��� � KIN
  if k
     qK=qK+1; qF=qF+k;  if k>km, km=k;end    
  end
  
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);       
  catch ME, FL = -10;   end       % f ����� �� ����� �� ������ x0                         
  
  if FL == 1                 % � ����(i+1-��) �����    
     X(i) = Xp;  x1 = x2;  x2 = Xp;
     Lp   = Lp-hL;
     i    = i+1;
     x0ep = x0e;                          
  else                       % �����   
     X = sprintf(['SolvL1: ������ �� ������\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % ����� �� i

stat(1,1) = io;
if qK,   stat(2:5,1) = [qK; qF; round(qF/qK); km]; end