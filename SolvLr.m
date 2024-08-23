% ______ Решение ху HF(x,L)=0 относительно х для L=L1:h:L9 влево
% Пр-ма исп для разгона h->hL. Выч HF в одной точке: x2+hr
% nm1 = 2 

function x2 = SolvLr( KZ,nT,n,c,dva,ioIZ,io0,hL,L1,x1,x2,x0ep,Xf,hr,DxHF)
% x1 =X(L1), x2+ X(L1-hr)                    
% DxHF - знак производной х.ф HF в НЕ-корне(истинном)
global TFL eVTs HFs ahis bJYIK infC %stat TSV vhea
global eps100
%_________________________1 Общие данные_______________________________ 
eVT = eVTs{nT};
HF  = HFs{nT};
ahi = ahis{nT};
bvs = bJYIK{nT}( :, 2); 
bns = bJYIK{nT}( :, 1); 
io  = io0;
ah  = ahi{io};  
bv  = bvs{io}; 
bn  = bns{io};

Xp  = x2;
tX  = x1*eps100;               % чувствительность по Х для х0

%_____________________ 2 Цикл: поиск корней ____________________________
while abs(hr-hL) > 1e-12
 FL = 4;      
 Lp = L1-hr;           % предыдущее Lp = L(i-1)
 L  = Lp-hr;           % текущее    L 
      
 [e1 e3 V2 T2] = eVT( KZ, L*L, dva);

 i   = 1;
 while i <= 1
  if FL == 4 
     x0e = extDLfr ( x1,x2,Xf, Lp+hr,Lp );
     %hx  = abs(Xp-x0e); 
     dX  = Xp-x0ep; 
     dX  = dX+dX;   
     if dX > 0,  x0 = [x0e; x0e+dX];  
     else        x0 = [x0e+dX; x0e];  end; iA=iA+1;   
  
     if ioIZ && io == 2
        if x0e*x0e < T2
           T = sqrt(T2); 
           io = 1;            
           if x0(2) > T,  x0(2) = T-tX; end
           ah = ahi{io};  bn = bns{io};  bv = bvs{io};
        end 
     end
  end
  % строка-отладка  
%figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('i=%d x0=%g %g',i,x0));grid
  f = HF( n, c, e1,e3, T2,V2, x0, ah, bv);
  if f(1)*f(2) > 0
     x0 = KIL2(n,c,e1,e3,T2,V2,ah,bn,HF,Xf,  x0,f,DxHF);
     if ischar(x0), x2 = ['SolvLr ' x0];  return,end   
  end
               
  if FL==4 || FL==5 %|| FL==6 || FL==7
     try   [Xp,fv,FL,out] = fzero(@(x) HF(n,c,e1,e3,T2,V2,x,ah,bn),x0);
     catch ME, FL = -10;          % f(x0(1))*f(x0(2))>0
     end         
  end                   
  %{ 
  if FL == 1
     if Xp < x2 || Xp > (Xf + x1+2*(x1-x2))*0.5       % переСКОК 
        if iPES > 10
           x2 = sprintf('К.перескоков = 10  i=%d\n%s',i,infC);
           return
        end
        iPES = iPES+1;
        if ~ioIZ,  T = sqrt(T2);  end
        io = 3-io;
        if io == 1,  x0 = [T-hx; T-tX];
        else         x0 = [T+tX; T+hx];  end
        ah = ahi{io}; 
        bn = bns{io};
        bv = bvs{io};
        FL = 7; 
        continue
     end                          
        
     SOS = (HF(n,c,e1,e3,T2,V2,Xp+tX,ah,bn)-fv)*DxHF < 0;
      
     if SOS,  iSOS=iSOS+1;
        if ioIZ && abs(x0e-T) < 2*tX
           if io == 1, io = 2;  Xp = T+tX;
           else        io = 1;  Xp = T-tX;
           end
           ah  = ahi{io};  bn = bns{io};  bv = bvs{io};
           iXT = iXT+1;
           FL  = 0;
        elseif firSOS
              firSOS = false;
              FL = 6;                                 
              x0 = Xp + [tX; (Xp-x2)*0.25];   
        else
              t4 = sprintf('НеДБ 2й Cоск\n%s\ni=%d x0=[%g %g]',infC,i,x0);
              XG = [x2; x0e+x2-x1]; 
              [x0 FL DxHF io] = KIND2( @KIL2, t4,...
                                n,c, e1,e3, T2,V2, ahi,bvs,HF,Xf,...
                                XG, io, DxHF);
              if     FL == 12,  x2 = t4; return
              elseif FL == 5,   continue, end             
        end
     end 
  elseif FL < 0,  FL = 11;   % f=Cmp|NaN|Inf|Sing|Can't detect sign change
  end
  %}
  if FL == 1,  x2 = Xp;   i = i+1;
  else                              % Выход   
     inf = sprintf(['SolvLr\n%s\n%s\ni=%d  ioIZ=%d\n'...
           'x0=[%3.17g  %3.17g]\n'...
           'f =[%3.17g, %3.17g]'],...
           TFL{FL}, infC, i,ioIZ, x0(1), x0(end), f(1),f(end));
      
     if FL==-10,  x2 = sprintf('%s\n%s\n', ME.message, inf); 
     else         x2 = sprintf('%s\n%s\n', out.message,inf); end 
     return
  end     
 end
 hr   = hr+hr;
 x0ep = x0e;
end
      