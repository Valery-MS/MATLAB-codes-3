% ______ ������� �� HF(x,L)=0 ������������ � �� ������� L1:h:L5 
% ______ ������� �� L1 ������ nm1 = 1
function X = Solv51T(nT,n,c,io,hL,L1, q,x01,f1,x02,f2,e1v,e3v,V2v,T2v)
               
% io = io2=1, �� �������� - ������ � L2 ������(>) L1
%global TFL  infC   %stat1 vhea
global HFs ahis bJYIK  %eVTs
global Em100
%________________________ 1 ����� ������ _______________________________ 
X   = nan(q,1);   
%eVT = eVTs{nT};
HF  = HFs{ nT};
ahi = ahis{nT};
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1); 

%h2 = hL+hL;
%L3 = L1+h2;
%Lv = [L1 L1+hL L3 L3+hL L3+h2]; 
%[e1v e3v V2v T2v] = eVT( KZ, Lv.*Lv, dva);
Vev = sqrt(V2v)*Em100;      % ������ ���� V2 = V^2, ����� V^2=V2 �����     

e11=e1v(1);  e31=e3v(1);  V21=V2v(1);  Ve1=Vev(1);  T21=T2v(1);
e12=e1v(2);  e32=e3v(2);  V22=V2v(2);  Ve2=Vev(2);  T22=T2v(2);

io_1 = true;  ah1 = ahi{io};   bv1 = bvs{io};   bn1 = bns{io};  

if nT==1,  KIN = @KIN1;
else       KIN = @KIN1B; end

if f1(1) ~= 0
   f1 = HF(n,c,e11,e31,T21,V21,x01,ah1,bv1);
   if f1(1)*f1(2) > 0 % io==1;    
      x01 = KIN( n,c,e11,e31,T21,V21,x01,ah1,bn1,HF,Ve1,f1); 
      if ischar(x01)
         io  = 2;   ah1 = ahi{2};   bv1 = bvs{2};   bn1 = bns{2};
         KIN = @KIN1;
         x01 = 2*sqrt(T21)-x01([2 1]); % ��������� ����� �1
         f1  = HF(n,c,e11,e31,T21,V21,x01,ah1,bv1);
         if f1(1)*f1(2) > 0 % io==2, => ��� ������ ����� � KIN1
            x01 = KIN(n,c,e11,e31,T21,V21,x01,ah1,bn1,HF,Ve1,f1);
            if ischar(x01), X = ['Solv51T x01=' x01];  return,end   
         end   
      end       
   end
end
x1 = fzero(@(x) HF(n,c,e11,e31,T21,V21,x,ah1,bn1),x01);     

ah = ahi{io};   bv = bvs{io};   bn = bns{io};
if f2(1) ~= 0   
   f2 = HF(n,c,e12,e32,T22,V22,x02,ah,bv);
   if f2(1)*f2(2) > 0
      x02 = KIN( n,c,e12,e32,T22,V22,x02,ah,bn,HF,Ve2,f2);   
      if ischar(x02)
         if io==2,  X = ['Solv51T io=2 x02=' x02];  return
         else
            io  = 2;    ah = ahi{2};   bv = bvs{2};   bn = bns{2};
            KIN = @KIN1;
            x02 = 2*sqrt(T22)-x02([2 1]); % ��������� ����� �2
            f2  = HF(n,c,e12,e32,T22,V22,x02,ah,bv);
            if f2(1)*f2(2) > 0 % io==2, => ��� ������ ����� � KIN1
               x02 = KIN(n,c,e12,e32,T22,V22,x02,ah,bn,HF,Ve2,f2);
               if ischar(x02), X = ['Solv51T x02=' x02];  return,end
            end   
         end 
      end
   end
end
x2 = fzero(@(x) HF(n,c,e12,e32,T22,V22,x,ah,bn),x02);   

X(1) = x1;  X(2) = x2; 

%_____________________ 2 ����: ����� ������ ____________________________    
i  = 3;
Xp = x2;
x0ep = x1*L1/(L1+hL);  % ��� � ������� ������� �� ����� �����, Xot=0,���4-86

while i <= q 
  e1 = e1v(i);  e3 = e3v(i);
  V2 = V2v(i);  T2 = T2v(i);  
  Ve = Vev(i); 
     
  x0e = extDLor1(x1,x2);  % % ������� �� Solv25
  %hx  = abs(Xp-x0e); % ���� �� �� ����.���� - �������.��. �� �����.����
     
  if Xp == x0ep,  x0 = [x0e-AP;  x0e+AP];   %min(x0e+AP,Ve)]; 
  else
     dX = Xp-x0ep;
     AP = abs(dX);         % ������ �� ���� ����
     AP2 = AP+AP;   
     if dX > 0,  x0 = [x0e; min(x0e+AP2,Ve)];
     else        x0 = [x0e-AP2; x0e];   end 
  end
     
  if io_1  &&  x0e*x0e > T2
     if x0(1)^2 < T2,  x0(1) = x0e; end 
     io_1 = false; 
     io = 2;   
     ah = ahi{2};  bn = bns{2};  bv = bvs{2};
  end   
                            %������-�������  
  %figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f = HF( n, c, e1,e3, T2,V2, x0, ah, bv);
  if f(1)*f(2) > 0
     x0 = KIN( n,c,e1,e3,T2,V2,x0,ah,bn,HF,Ve,f); 
     if ischar(x0)
        X=sprintf('Solv51T nT=%d io=%d/n%s',nT,io,x0); return
     end   
  end
  
  try   [Xp,~,FL,ME] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);         
  catch ME, FL = -10;    end       % f ����� �� ����� �� ������ x0         

  if FL == 1           % � ����(i+1-��) �����  
     X(i) = Xp;  x1 = x2;  x2 = Xp;
     i    = i+1;
     x0ep = x0e;                    
  else                 % �����   
     X = sprintf(['Solv51T: ������ �� ������\nio=%d i=%d\n' ...  
         'x0=[%3.17g  %3.17g]\nf =[%3.17g, %3.17g\nFL=%d %s]'],...
         io,i,x0(1),x0(end),f(1),f(end),FL,ME.message);
     return 
  end
end % ����� �� i