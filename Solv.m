% ______ Решение ху HF(x,L)=0 относительно х для L=L1:h:L9 __________
% первоначальный универсальный вариант
function X = Solv( KZ,  nT,  n,  c,   NNM,...
                   GXm,  m,   h,   L1, qL,  ...
                   DxHF, dva, Lot, Xz, EXT, io0, ioIZ)
% Xz = 2*1-вектор;   X zero, X нулевое, Х начальное                    
% EXT=1: UR0,  Xz - прибл; x0=Xz(i=1:2); поиск с i=1,     -//-
% EXT=2: DVAX, Xz - точные;              поиск с i=3,     -//-
% EXT=3: DVAX, Xz - точные;              поиск с i=3,     -//-
% DxHF - знак производной х.ф HF в НЕ-корне(истинном)
global  TSV TFL stat bJYIK % vhea

%_________________________1 Общие данные_______________________________ 
Di   = 1;
Ty   = TSV{nT};
EH   = 'EH';
KM   = numel(NNM);         % к-во мод
eps2 = eps + eps;
tX   = 1e-8;               % чувствительность по Х для х0
tf   = tX*10;              % чувствительность по Х для f = HF
X    = nan(qL,KM);       
Xot  = GXm(1); 
Xf   = GXm(2);

if     EXT == 1,  i_0 = 1;  vlevo = false; ILKA = @ILKAR;  
elseif EXT == 2,  i_0 = 3;  vlevo = true;  ILKA = @ILKAL;  h = -h; 
else              i_0 = 3;  vlevo = false; ILKA = @ILKAR; 
end               % ile - индекс XG, соотв лев концу и-ла в ILKR 
                  % vlevo - экстраполяция влево
                  
if nT == 5
   if m == 1,      Pist = 1; 
   elseif KM == 1     
      if NNM == 1, Pist  = -1;
      else         Pist  =  1;  end
   else            Pist2 = [-1 1];
   end      
end 

nm11   = n == 1 &&  m == 1;
dd     = 0.6;
XpEnew = false; 
a2     = sqrt(dva)/pi;

[VEP HF eT ahs bvs] = vheab( nT, 2);
bns = bJYIK{nT}( :, 1); 
io  = io0;
% So=0; Sf=0; Sr=0; ofr = zeros(3,3);

%_____________________2 Цикл: поиск корней____________________________
for k = 1:KM
 ah = ahs{io};  
 bv = bvs{io}; 
 bn = bns{io};
 RRK    = -1;   
 NNMk   = NNM(k);
 EHk    = EH(NNMk);
 FL     = 4;     
 SOS    = false;  
 firSOS = true;
 iXV    = 0;                              % счетчик X = V
 iXT    = 0;                              % счетчик X = T
 iPES   = 0;                              % счетчик перескоков
 AL=0; hL=0;  AR=0; hR=0; VR=0;           % счетчики способов выч х0
 
 if nT==5 && KM == 2 && m ~= 1
    Pist = Pist2(k);       % учет моды для 2-СВ(nT=5)
 end 
 q    = qL(k); 
 L1k  = L1(k);            % первое значение L
 L    = L1k + (i_0-2)*h;  % второе значение L
 L9   = L1k + (q-1) *h; 
 
 if EXT >= 2,  X(1:2,k) = Xz(:,k); end
 
 infC = sprintf('nT=%s  %s%d%d 2a=%g q=%d EXT=%d L=[%g : %g : %g]',...
        Ty, EHk, n, m, a2, q, EXT, L1k, h, L9); % inf is Const
 i    = i_0;
 %dX   = Xz(1)-Xz(2);
 
 while i <= q 
   if FL == 4 %FL < = 8 || FL >= 20 % при 1-м входе или переходе к след т.       
     Lp = L;           % предыдущее Lp = L(i-1)
     L  = L+h;         % текущее    L 
     
     [e1 e3 V_2] = VEP( KZ, L*L, dva);
     V    = sqrt(V_2);      % так сделано, чтобы 
     V_2  = V^2;            % V^2 было точно равно V_2
     dV   = V*eps2; 
     Veps = V-dV; 
     T2   = eT(e1,e3)*V_2;
     
     if i <= 2     % здесь i_0 = 1
        x0e = Xz(i,k); 
        if i == 1
           zhx = (x0e - Xz(2,k))*0.5;
           hx  = abs(zhx); 
           Xi1 = Xz(1,k) + zhx;
           if     vlevo,      x0  = [x0e-hx;  x0e+hx];
           elseif x0e > Veps, x0e = Veps;  x0 = [x0e-hx;  x0e]; 
           else               x0  = [x0e-hx;  min(x0e+hx,Veps)]; 
           end
        else
           hx  = abs(x0e - Xp)*0.5;    % мб не нужно ?
           Xi1 = X(1,k);
           if x0ep == Xp, AP = hx*0.1;             
           else           AP = 2*abs(x0ep-Xp); end  % АбсПог на пред шаге
           
           if     vlevo,    x0  = [x0e-AP; x0e+AP]; 
           elseif x0e>Veps, x0e = Veps;  x0 = [x0e-AP;  x0e]; VX = AP+AP;   
           else             x0  = [x0e-AP; min(x0e+AP,Veps)]; VX = V-x0e;
           end
        end
     else       % i >= 3
        Xi1 = X(i-1,k);
        Xi2 = X(i-2,k);
        if     Di==0,  x0e = extDDr  ( Xi2,  Xi1, Xf);
        elseif vlevo,  x0e = extDLfr ( Xi2, Xi1, Xf, Lp-h, Lp );
        elseif nm11,   x0e = extDLor1( Xi2,  Xi1 ); 
        else           x0e = extDLor ( Xi2, Xi1,Xot, Lp-h, Lp,  Lot ); 
        end
 
        if i == i_0      % возм, если i_0 = 3
           hx = abs(x0e - Xz(2,k))*0.5;
           if vlevo,  x0 = [x0e-hx;  x0e+hx];
           else       x0 = [x0e-hx;  min(x0e+hx, Veps)]; VX = V-x0e; end
        else
           hx = abs(x0e - Xp); 
           if x0ep == Xp
              AP = hx*0.1;  
              if     vlevo,    x0  = [x0e-AP; x0e+AP]; 
              elseif x0e>Veps, x0e = Veps;  x0 = [x0e-AP;  x0e];
              else             x0  = [x0e-AP; min(x0e+AP,Veps)];
              end  
           else
              %dXp = dX;
              dX  = Xp-x0ep;
              %if dXp*dX < 0, iXT = iXT+1; end
              AP  = abs(dX);             % АбсПог на пред шаге
              AP2 = 1.5*AP;  
              if ~vlevo                  % вправо   
                 VXp = VX;
                 VX  = Vp-Xp;            % расстояние до V на пред шаге                  
                 if AP < abs(VX-VXp)   % абс погр (выч через V)  
                    if dX > 0, x0 = [x0e; min(x0e+AP2,Veps)];
                    else       x0 = [x0e-AP2; x0e];   end
                    AR=AR+1;
                 else
                    %VXp = VX^2/VXp;   % расстояние экстраполируемое 
                    x0 = [V-(1+dd)*VX;  V-(1-dd)*VX];   VR = VR+1;  
                 end   
                 if x0(1) < Xot,  x0(1) = Xot;  end
              elseif AP < hx      % vlevo
                 if dX > 0, x0 = [x0e; x0e+AP2];
                 else       x0 = [x0e-AP2; x0e]; end     
                 AL = AL+1;  
              elseif dX > 0,  x0 = [x0e; x0e+hx];  hL = hL+1;
              else            x0 = [x0e-hx; x0e];  hL = hL+1;
              end
           end
        end
     end
      
     if ioIZ
        T = sqrt(T2);
        if x0e < T
           io = 1;            
           if x0(2) > T,  x0(2) = T-tX; end
        else
           io = 2;  
           if x0(1) < T,  x0(1) = T+tX; end
        end
        ah = ahs{io};  bn = bns{io};  bv = bvs{io};
     end
     
     if k == 2  &&   x0(1) <= X(i,1)
        if RRK ==-1, x0(1) =  X(i,1)+tX;
        else         x0(1) =  X(i,1)+RRK;  end
     end
  end
  % строка-отладка  
%figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V_2,x_,ah,bv);plot(x_,y_);title(sprintf('m=%d i=%d x0=%g %g',m,i,x0));grid
  f = HF( n, c, e1,e3, T2,V_2, x0, ah, bv);
  if f(1)*f(2) > 0
     if m==1  &&  SOS  &&  x0(2)==Veps         
        hh = (V-Veps)/2;
        xx = V-8*hh : hh : V;
        [fv imi] = min(abs(HF( n, c, e1,e3, T2, V_2, xx, ah, bv )));
        Xp  = xx(imi);  
        iXV = iXV+1;
        FL  = 0;
     else 
        [x0 FL t1] = ILKA( n, c, e1, e3, T2, ah, bn, ...
                           DxHF, HF, NNMk, RRK, x0, f, V);
        if     FL == 0, Xp = x0;  iXV = iXV+1;  
        elseif FL >= 6 
           if ioIZ
              if io == 1, io = 2;  Xp = T+tX;
              else        io = 1;  Xp = T-tX;
              end
              ah  = ahs{io};  bn = bns{io};  bv = bvs{io};
              iXT = iXT+1;
              FL  = 0;
           else
              if vlevo, XG = [Xi1; min(Xf,  Veps)];
              else      XG = [Xot; min(Xi1, Veps)]; 
              end
           
              [x0 FL DxHF io] = ILKR( sprintf( ...
                         'ILKA\n%s\n%s i=%d x0=[%g %g] io=%d',...
                         t1, infC, i,  x0, io),...
                         n, c, e1, e3, T2, V_2, ahs,bvs,...
                         DxHF, HF, XG, NNMk, RRK, ILKA,io);
              if FL == 0,   Xp = x0;  iXV = iXV+1;  end
           end
        end
     end        
  end
               
  if FL==4 || FL==5 || FL==6 || FL==7
     try   [Xp,fv,FL,out] = fzero(@(x) HF(n,c,e1,e3,T2,V_2,x,ah,bn),x0);
                                  % optimset('Display','off'));         
     catch ME, FL = 10;           % f имеет од знаки на концах x0
     end         
  end                   
    
  if FL == 1
     if Xp < Xi1 == vlevo || Xp > Xf       % переСКОК 
        if iPES > 10
           X = sprintf('К.перескоков = 10  i=%d\n%s',i,infC);
           return
        end
        iPES = iPES+1;
        if ~ioIZ,  T = sqrt(T2);  end
        io = 3-io;
        if io == 1,  x0 = [T-hx; T-tX];
        else         x0 = [T+tX; T+hx];  end
        ah = ahs{io}; 
        bn = bns{io};
        bv = bvs{io};
        FL = 7; 
        continue
     end                          
        
     SOS = (HF(n,c,e1,e3,T2,V_2,Xp+tf,ah,bn)-fv)*DxHF < 0;
        
     if nT == 5                % опр СОСКОКа для 2СВ
        if (POW( n, V_2, Xp)*Pist < 0) ~= SOS 
           t2 = sprintf('Несовпадение соскоков\n%s',infC);
           if vlevo,  XG = [Xi1; min(Xf,  Veps)]; 
           else       XG = [Xot; min(Xi1, Veps)];  end  
           
           [x0 FL DxHF io] = ILKR(sprintf('%s i=%d x0=[%g %g]',t2,i,x0),...
                          n, c, e1,e3, T2, V_2,  ahs,bvs,...
                          DxHF, HF, XG, NNMk, RRK, ILKA,io );  
           if     FL == 12, X = t2; return
           elseif FL == 5,  continue,end             
        end
     end
      
     if SOS
        if ioIZ && abs(x0e-T) < 2*tX
           if io == 1, io = 2;  Xp = T+tX;
           else        io = 1;  Xp = T-tX;
           end
           ah  = ahs{io};  bn = bns{io};  bv = bvs{io};
           iXT = iXT+1;
           FL  = 0;
        else
           XpE    = Xp;      % Xp сопряженной (обычно Е) моды
           XpEnew = true;    % Т.к найдено новое Хр, то RRK надо уточнить
           if m == 1
              t3 = sprintf('Cоскок при m=1\n%s',infC);
              if vlevo,  XG = [Xi1; min(Xf,  Veps)]; 
              else       XG = [Xot; min(Xi1, Veps)];  end
 
              [x0 FL DxHF io] = ILKR(sprintf('%s i=%d x0=[%g %g] V=%g',...
                          t3,i,x0,V),...
                          n, c, e1,e3, T2, V_2,   ahs,  bvs,...
                          DxHF, HF, XG, NNMk, RRK, ILKA, io); 
              if     FL == 12, X = t3; return
              elseif FL == 5,  continue,end             
           elseif firSOS
              firSOS = false;
              FL = 6;                                  % E-мода
              if NNMk == 1,    x0 = Xp - [hx; tX];
              else                                     % H-мода    
                 if ~vlevo
                    if x0(2) >= Veps                    
                       hh = (V-Veps)/2;
                       xx = (V-8*hh : hh : V)';
                       [fv imi] = min(abs(HF(n,c,e1,e3,T2,V_2,xx,ah,bv )));
                       Xp = xx(imi);
                       FL = 2;  
                    else  x0 = [x0(2); Veps];
                    end  
                 elseif RRK == -1, x0 = Xp + [tX;  (Xp-Xi1)*0.25]; 
                 else              x0 = Xp + [tX;  RRK+RRK ];      
                 end                       
              end
           else
              t4 = sprintf('2-й Cоскок! Не ДБ\n%s',infC);
              if vlevo,  XG = [Xi1; min(Xf,  Veps)]; 
              else       XG = [Xot; min(Xi1, Veps)];  end
  
              [x0 FL DxHF io] = ILKR(sprintf(...
                          '%s i=%d x0=[%g %g] V=%g',...
                          t4,i, x0, V ),...
                          n, c, e1,e3, T2, V_2,   ahs,  bvs,...
                          DxHF, HF, XG, NNMk, RRK, ILKA, io );
              if     FL == 12, X = t4; return
              elseif FL == 5,  continue,end             
           end
        end
     end 
 
  elseif FL < 0,  FL = 11;   % f=Cmp|NaN|Inf|Sing|Can't detect sign change
  end

  if FL <= 3                 % К след(i+1-му) корню    
     X(i,k) = Xp;     
     x0ep   = x0e;    
     Vp     = V;     
     firSOS = true;     
     SOS    = false;            
     FL     = 4; 
     if XpEnew,  XpEnew = false;  RRK = 0.5*(Xp-XpE);    
     end

     i = i+1;  
  elseif FL >= 10               % Выход   
     inf = sprintf(['Solv: Корень не найден\n%s\n%s\n' ...  
          'i=%d  V=%g\n'...
          'x0=[%3.17g  %3.17g]\n'...
          'f =[%3.17g, %3.17g]'],...
          TFL{FL}, infC, i,V, x0(1), x0(end), f(1), f(end));
      
     if     FL==10,  X = sprintf('%s\n%s\n', ME.message, inf); 
     elseif FL==11,  X = sprintf('%s\n%s\n', out.message,inf); 
     else            X = inf;
     end 
     return 
  end
 end % цикла по i
end  % цикла по k

if h < 0,  X = flipud(X);  end

stat(1) = stat(1)+AL;
stat(2) = stat(2)+AR;
stat(3) = stat(3)+hL;
stat(4) = stat(4)+hR;
stat(5) = stat(5)+VR;
stat(6) = stat(6)+iPES;
stat(7) = stat(7)+iXV;
stat(8) = stat(8)+iXT;  %fprintf('  q=%d   idX=%d\n',q,iXT)

%if q>5, ofr,Sorf,end
%if q > 5 && ~nm11
%   fprintf('m=%d q=%d EXT=%d\nie=%3d  Se=%4g  Sae=%4g\niE=%3d  SE=%4g  SaE=%4g\n%4.1f\n',...
%       m,q-i_0+1,EXT,ie,Se,Sae,iE,SE,SaE,100*iE/ie);
%end
