% ______________________выч 2а(DVA) & X ________________________________
function [dvaX dvaX1 AV] = DVAX( LZ, hL, KZ, nT, Lw, c,n, GX, mm, qX, RVD )              
%         Характеристики алгоритма
% fKI = (0)1  (не)найден Корневой Интервал для dva
%   nT =        1                2               3       4
% vhea = { @VEP_1           @VEP_2          @VEP_3  @VEP_4;...
%          @HF_1            @HF_2           @HF_3   @HF_4; ...
%          @eT_1            @eT_2           @eT_3   @eT_4; ...
%         {@ah1_1; @ah11}  {@ah_11; @ah11}  @ah1_1  @ah_11 }; 

% eVs  = { @eV_1           @eV_2          @eV_3   @eV_4};
% eVTs = { @eVT_1          @eVT_2         @eVT_3  @eVT_4};
% HFs  = { @HF_1           @HF_2          @HF_3   @HF_4};
% ahios= {{@ah1_1; @ah11} {@ah_11; @ah11} @ah1_1  @ah_11}; 

% numb  vect  matrix   -  типы сх1, сх2, х2, х3
% bJYIK = { { @JIKn @JIKv @JIKm;   ...   % nT=1  доп х2^2 < 0
%            @JJYn @JJYv @JJYm_1 } ...   %           х2^2 > 0
%            
%          { @IJYn @IJYv @IJYm;    ...   % nT=2  доп x1^2 < 0
%            @JJYn @JJYv @JJYm_2 } ...   %           х1^2 > 0

%          { @JIKn @JIKv @JIKm }   ...   % nT=3
         
%          { @IJYn @IJYv @IJYm }   ...   % nT=4
%            ''                   };     % nT=5

global iNAs TSV infC stat
global XC_ A_ B_ XA_ XB_ SA_ Lot2_  % для v_S1_Solv, samdva
global eVTs %HFs ahis bJYIK
global LURp LUR
global Em9
global io_
global Xe_  %Xe_2 
global DxHF DxHFn
global qL qHF;   qHF=0;

eVT = eVTs{nT};
%HF  = HFs{nT};
%ahi = ahis{nT};
%bns = bJYIK{nT}(:,1); 
%bvs = bJYIK{nT}(:,2); 
%bms = bJYIK{nT}(:,3); 

dvaX = [];   dvaX1 = [];   AV = 0;
Lw12c= Lw/(12*0.299792458e-3);      % 12 * 1e-12 * ск.света
hpb  = [];                          % header для Progress Bar PB_DVAX
m1   = mm(1);
m9   = mm(end);
dm   = m1-1;     % сдвиг в нумерации по m
mk9  = m9-dm;  
stat = zeros(30,mk9);

inma  = iNAs(1,nT);   
insr  = iNAs(2,nT);   
inmi  = iNAs(3,nT);   
qRS   = 5;                           % к-во точек в PC
X     = nan(qRS,1);
qC    = (qRS+1)/2;                   % к-во точек до центра РС
hL2   = (qC-1)*hL;                   % радиус РС
L1    = Lw-hL2;  L2 = Lw-hL;  L4 = Lw+hL;  L5 = Lw+hL2;
L0    = L1-hL;   L6 = L5+hL;
L     = [L1; L2; Lw; L4; L5]; 
L_2   = L.^2; 
L1_2  = L_2(1);
%L2_2  = L_2(2);
L5_2  = L_2(5);
L6_2  = L6*L6;
%L122  = [L1_2  L2_2]; % L122 дб строкой для прав выч Vm в XRS1 
LG2   = [L1_2; L5_2]; % LG2 мб столбцом или строкой
Lch   = Lw12c/(hL*hL);
nmax  = n_2kZ( KZ(:,inma), L_2);
Lwz2  = (Lw+hL/2^13)^2;              % =(Lw+hz)^2,  hz=hL/2^13=hзахвата

KZma  = KZ(:, inma);
KZsr  = KZ(:, insr);
KZmi  = KZ(:, inmi);

n2ma  = n_2kZ(KZma, L5_2);
n2mi  = n_2kZ(KZmi, L5_2);
NA2ma = n2ma - n2mi;        % в т. L5^2  NA2 - max

LZ1   = LZ(1);      LZ2  = LZ(2);
LZ12  = LZ1*LZ1;    
%LZ22 = LZ2*LZ2;
%NA2LZ = n_2kZ(KZma, LZ22)-n_2kZ(KZmi, LZ22);   % для выч X в LZ
%NAL2  = 0.9*NA2LZ/LZ22;
%n2sr  = n_2kZ(KZsr, L5_2);
%n2T   = n2ma - n2sr;        % мсп для прибл выч L: X=T

LNA2  = L5_2 / NA2ma;
%em5   = 1-1e-5;

nm1 = n == 1 && m1 == 1;
otl = RVD(2);
qa0 = RVD(3); 
k1  = 2;

if nm1
   infC = sprintf('m= 1 dm= 0 n=1 nT=%s nm1=%d',TSV{nT});   
   GXm  = GX(1,:);              
   Xot  = GXm(1);    Xot2 = Xot*Xot;
   Xfa  = GXm(2);    
   dvao = Xot2*LNA2;      %  dva в отсечке начальное
   dvaf0 = Xfa*Xfa*LNA2;   %  dva, соотв Xfa, конечное   
   hdva0= (dvaf0-dvao)/qa0;
   hdva = hdva0;
   dva  = dvao;
      % только для nm1 = 1  
      Xmi  = Inf;     Xma  = Inf;   
      Lot2 = Inf;     Lot  = Inf;
   
   dvaG0 = [dva+hdva dvaf0];     
   dvaG  = dvaG0;
   qa    = qa0;
   dvaf  = dvaf0;
   
   while true
      iX = 0;                     % нач знач счетчика найд-х Х       
      SA = NaN;  
      S1 = nan(qa,1); 
      while dva <= dvaf           % Выч S1(и S2, S3
         dva = dva+hdva;     
         fKI = 0;                 % Найден КИН для S1
         [e1 e3 V2 T2] = eVT( KZ, L_2', dva);  
         
         if Xma*Xma > V2(1)
            Ve1 = sqrt(V2(1))*Em9;
            if Xma == Inf,  Xe(3) = Ve1;  end
            Xma = Ve1;
         end
         
         if Xmi*Xmi > V2(2)            
            Xmi_ = 2*sqrt(V2(2))-Xma; 
            if Xmi == Inf,  Xe(1) = Xmi_; end
            Xmi = Xmi_;  
         end         
                             % ТСВ5-15-16                  
         if     nT > 2,          ioz= 1;  SR1 = @Solv51;
         elseif Xma^2 < T2(5),   ioz= 1;  SR1 = @Solv51;    
         elseif T2(1) < Xmi^2,   ioz= 2;  SR1 = @Solv51;
         elseif Xma^2 < T2(1),   ioz=-1;  SR1 = @Solv51T;  
         elseif (Xma-(Xma-Xmi)/4)^2<T2(2), ioz=-1;   SR1=@Solv51T; 
         elseif Xma^2<T2(1),               ioz=-2.5; SR1=@Solv51T; %ioz мб=-1.5 в XRS1
         else                              ioz=-2;   SR1=@Solv51;    
         end       
         % plot([L1 L5],[Xma Xmi],L,sqrt(T2)),grid
         X = XRS1( nT,n,c,SR1,ioz,L1,L2,qX,Xmi,Xma, e1,e3,V2,T2,otl,GXm);
         if ischar(X)
            AV = sprintf('%s\niX=%d', X,iX);
            return 
         end
      
         iX = iX+1;                 % счетчик найд-х Х                           
         LX2 = L_2.*X.*X; 
         S   = v_S1( Lch, LX2, dva, nmax);
         S1(iX) = S;
         % сечас выбиираем только правый корень у-я S=0
         % Раньше by RVD мб - любой.  Теперь RVD - для отладки в XRS
         %if RVD(2)               % выбор левого 2а
         %   if SA> 0 && S < 0,   fKI = 1;  break;
         %   else                 SA  = S;  XA = X; end               
         %else                    % выбор правого 2а (по умолч)
            if SA< 0 && S > 0,   fKI = 1;  break;
            else                 SA  = S;  XA = X; end 
         %end
         
         if RVD(1) && iX > 2  % Строить диапазоны Хmi, Xma для след 2а
            fig1 = figure;  
            plot([Xmi Xma],37,'.r', X,37,'.g',Xot,37,'ok',...
                 X([5 5]),[21 37],':', X([1 1]),[21 37],':') 
            title(sprintf('m=1 iX=%d Xfa=%5g',iX,Xfa))
            prib('Дальше')
            delete(fig1), clear fig1
         end
         
         if dva < dvaf 
            XX = [X(1); X(2); X(5)];
            if iX==1, Xe = 0.5*(extDD1( XX,Xfa,  dva,dva+hdva)+XX);
                      Xe_ = 0.5*(extDD1_2( XX,Xfa,  dva,dva+hdva)+XX);
                      %Xe = 0.5*(extDD1_p( XX,Xfa,  dva,dva+hdva,4)+XX);
            else
               Xe = extDD(Xp,XX,Xfa, dva-hdva,dva,dva+hdva)-0.6321*abs(Xep-XX);
               Xe_ = extDD_2(Xp,XX,Xfa, dva-hdva,dva,dva+hdva)-0.6321*abs(Xep-XX);
               %Xe = extDD_p(Xp,XX,Xfa, dva-hdva,dva,dva+hdva,4)-0.6321*abs(Xep-XX);
            end
            %if iX==1, fi1=figure; hold; end
            %plot([XX Xep])            
            
            d   = X(1)-X(2);
            Xma = Xe(1);%+d; 
            if nT==1,  Xmi = Xe(2);
            else       Xmi = Xe(3)-k1*d;  end  % ??
            Xep = Xe; 
            Xp  = XX;
         end 
      end   % конец выч S1(dva)
      %delete(fi1)
      
      if fKI  &&  RVD(1) == 0
         nexm = false;  break 
      else                    % Строить графики S1(2a)
         if ~exist('fig2','var'), fig2 = figure; hold on; end
         dvas = setK([dvaG iX]);
         plot(sqrt(dvas)/pi, S1);  
         titlab(sprintf('m=1 iX=%d fKI=%d',iX,fKI),{'2a' 'S1'});   
         me = menu('','Уменьш к.шагов в 2',...
                      'Уменьш к.шагов в 4',...
                      'Увел к.шагов в 2', ...
                      'Увел к.шагов в 4', ...
                      'Не изм к.шагов',...
                      'Перейти к след m',...
                      'Выход');
         if me == 7 
            delete(fig2), clear fig2
            AV = sprintf(['Работа программы завершена принудительно\n'...
                'X([1 5])=%g %g, S1(%d)=%g'],X([1 5]),iX,S1(iX));
            return
         elseif me == 6
            nexm = true; 
         else
            nexm = false;
            deg = [-1 -2 1 2 0];
            if ~fKI, prib('КИН не найд. Изм диапазон 2а');
            else     prib('Задать диапазон 2а');  end
            [x(1:2) y] = ginput(2);       
            if x(1) > x(2),  x(1:2) = x([2 1]); end
            dvaG = (x*pi).^2;             % dvaG измененное
            if dvaG(1) < 0,      dvaG(1) = 1; end
            if dvaG(2) > dvaf0,  dvaG(2) = dvaf0; end
            qa  = round(qa*2^deg(me));
            dvaf = dvaG(2);
            hdva= (dvaf-dvaG(1))/qa;
            dva = dvaG(1)-hdva;
            XG  = sqrt(dvaG/LNA2);
            Xmi = XG(1);
            Xma = XG(2);
         end
      end  
      if nexm,  break,end
   end  % while
   
   if ~nexm
                      % поиск корня dva:  S1(dva) = 0    
   A_ = dva-hdva;   B_   = dva;
   XA_= XA(1:2);    XB_  = X(1:2);                                      
   SA_= SA;         Lot2_= Lot2;                
        
   if nT < 3     % ТСВ5 - 18 
      T2 = vT2(KZma,KZsr,LG2,[A_ B_]); %-2*2-матрица=столбLG2*cтрока[A_ B_]
      TA5 = T2(2,1);
      if  XA(5)^2 < TA5  %ТСВ5-20
         if X(5)^2 < TA5,   Sf=@Solv51f; io=1;  SR=@SolvR1T; ioR=1; 
                            fT=8; SL=SolvL1;    ioL=2;
         else               fT=3; Sf=@Solv51fT; io=1; 
         end
      elseif XA(1)^2>T2(1,1)
         if X(1)^2<T2(1,2), fT=2; Sf=@Solv51fT; io=2;
         else               fT=1; Sf=@Solv51f;  io=2; SR=@SolvR1; ioR=2;end
      else
         Sf = @Solv51fT; io=1; 
         if X(5)^2>T2(2,2), fT=0;    SR=@SolvR1;  ioR=2;
         else               fT=2;    end
         if X(1)^2>T2(1,2), fT=7-fT; SL=SolvL1;   ioL=1;
         else               fT=6-fT; end
      end
   else  Sf = @Solv51f;   
   end     
        
   try [dva,~,FL1,ME] = fzero( @(a)  v_S1_51(...
                        KZ,nT,n,c,a,Sf,io,hL,L1, qRS,nmax,Lch,L_2), [A_ B_]);   
   catch ME, FL1 = -9;
   end
   
   if FL1~=1, AV = sprintf('DVAX: m=1 FL1=%d  iX=%d\n%s',FL1,iX,ME.message); return,end  
           
            % Выч X для найд dva: продолжение ХС влево и вправо по L  
   XC  = XC_; 
   XC1 = XC(1);
   XC2 = XC(2);
   Xw  = XC(3);
   XC4 = XC(4);
      %XLZ2 = (extDLo1( XC4,XC(5), L4,L5,LZ2))^2; дает > V2: плохое прибл
   if fT <= 6
      if fT ~= 5
         if XC1^2 < vT2(KZma,KZsr,L1_2,dva)
              SL = @SolvL1;  ioL = 1;
         elseif extDLf(XC1,Xw,Xfa,L1,Lw,LZ1)^2 < vT2(KZma,KZsr,LZ1,dva)
              SL = @SolvL1T; ioL = 2;
         else SL = @SolvL1;  ioL = 2;
         end
         
         if fT >= 2
            if io_== 2, SR = @SolvR1;  ioR = 2;
            else        SR = @SolvR1T; ioR = 1; end
         end
      elseif io_== 2, SR = @SolvR1;  ioR = 2;
      else            SR = @SolvR1T; ioR = 1; 
      end
   end
   
   x0ep = extDLor1( Xw, XC4);   
   qR = floor( (LZ2-L5)/hL + 1e-9);  % поиск Х вправо от Lw
   qHF1 = qHF;
   stat(29,1) = qR;
   XR = SR(KZ,nT,n,c,dva,ioR,hL,L6, qR,XC4,XC(5),x0ep,LZ2); 
   if ischar(XR),  AV = XR;  return,end  
     
   x0eL = extDLfr( Xw,XC2, Xfa, Lw,L2);
   %x0eL_= extDLor1(Xw,XC2);   % что ближе к ХС1?
   qL = floor( (L1-LZ1)/hL + 1e-9);         % поиск Х слева от Lw
   XL = SL(KZ,nT,n,c,dva,ioL,hL,L0, qL,XC2,XC1,x0eL,LZ1,Xfa); 
   stat(30,1) = qHF-qHF1;
   if ischar(XL),  AV = XL;  return,end
      
   dvaX1 = [1; L5+qR*hL; qR+qL+5; dva; Lot; flipud(XL); XC;XR];
   hpb = PB_DVAX( hpb, 1, 1, mk9);
   end
end

%________________________ nm1 = 2 ________________________________
iow = 0;                 % счетчик Lot < Lw
mk  = nm1;               % счётчик азимут. чисел m
m   = m1+nm1;
DxHFn = NaN;             % при 1-м входе в XRS2
qL = floor( (L0-LZ1)/hL + 1e-7) + 1;   % поиск Х слева от Lw

while m <= m9
   infC = sprintf('m=%2d dm=%2d n=%2d nT=%d nm1=0',m,dm,n,nT);   
   GXm  = GX(m,:);              
   Xot  = GXm(1);    Xot2 = Xot*Xot;
   Xfa  = GXm(2);    
   dvao = Xot2*LNA2;      %  dva в отсечке начальное
   dvaf = Xfa*Xfa*LNA2;   %  dva, соотв Xfa, конечное   
   hdva0= (dvaf-dvao)/qa0;
   hdva = hdva0;
   dva  = dvao;
      % только для nm1 = 0
      dvXf  = dvaf/Xot2;    
      if FLot2( KZma,KZmi, dvXf, dvXf*NA2ma) < Lwz2  % исключение мал.захвата
         AV = sprintf('На Lw=%5g мод выше %d порядка не сущ',Lw,m-1);
         return
      end
   Xmi   = Inf;     Xma  = Inf;
   
   dvaG0 = [dva+hdva dvaf];     
   dvaG  = dvaG0;
   qa    = qa0;
   %j=0;Xs=nan(qa,2); Rs=Xs; ds=setK([dvaG0 qa]); as=sqrt(ds)/pi;% временно
   %Y=0;D=0;
   while true
      iX = 0;                     % нач знач счетчика найд-х Х       
      SA = nan;  
      S1 = nan(qa,1);  
      while dva <= dvaf           % Выч S1(и S2, S3
         dva = dva+hdva; %j = j+1; 
            % только для nm1 = 0
            dv_X = dva/Xot2;      % начальное значение Lot^2
            Lot2 = FLot2( KZma,KZmi, dv_X, dv_X*NA2ma); 
            Lot  = sqrt(Lot2);
            
            if Lot2 <= L5_2, iow = iow+1; continue, end % искл МЗ, Lot<Lw    

            %{
            elseif Lot2 >= L5_2
               h    = hL;             
               L_2u = L_2;
               L1u  = L1;
               L2u  = L2; 
               Lch  = Lch0;
               nmax = nmax0;
               hum  = false;      % h не уменьш
            else
               rad = hL;
               while rad > Lot-Lw,  rad = 0.5*rad;  end
               h    = rad*0.5;
               L2u  = Lw-h;
               L1u  = L2u-h;
               L4u  = Lw+h;
               L5u  = L4u+h;
               Lu   = [L1u; L2u; Lw; L4u; L5u];
               L_2u = Lu.^2;
               Lch  = Lw12c/(h*h);
               nmax = n_2kZ( KZ(:,inma), L_2u); 
               hum  = true;       % h  уменьшилось 
            end
            %}     
         fKI = 0;         
         [e1 e3 V2 T2] = eVT( KZ, L_2', dva); 
         
         if Xma*Xma > V2(1)
            Ve1 = sqrt(V2(1))*Em9;
            if Xma == Inf,  Xe(3) = Ve1;  end
            Xma = Ve1;
         end
         
         if Xmi*Xmi > V2(2)            
            Xmi_ = 2*sqrt(V2(2))-Xma; 
            if Xmi == Inf,  Xe(1) = Xmi_; end
            Xmi = Xmi_;  
         end 
 
         if     nT > 2,          ioz= 1;  SR2 = @Solv52;
         elseif Xma^2 < T2(5),   ioz= 1;  SR2 = @Solv52;    
         elseif T2(1) < Xmi^2,   ioz= 2;  SR2 = @Solv52;
         elseif (Xma-(Xma-Xmi)/4)^2<T2(2),  ioz=-1;    SR2 = @Solv52T;
         elseif  Xma^2<T2(1),               ioz=-2.5;  SR2 = @Solv52T; 
         else                               ioz=-2;    SR2 = @Solv52; 
         end         
         % plot([L1 L5],[Xma Xmi],L,sqrt(T2)),grid
         [X io] = XRS2(nT,n,c,SR2,ioz,L1,L2,qX,Xmi,Xma,e1,e3,V2,T2,Xot,Lot,otl);
         if ischar(X)
            AV = sprintf('%s\nm=%d iX=%d', m,X,iX);
            return 
         end
         
         if     LURp>0 && LUR>0,  LUR = (LURp+LUR)/2;
         elseif LURp>0,           LUR =  LURp;    end
%{
         hfi = figure;
         plot(L12, X(1:2)','r', L12,sqrt(T2),'b');
         prib('io = %d %d',io(1),io(end))
         delete(hfi), clear hfi
%}         
         iX = iX+1;                 % счетчик найд-х Х         
         if m == m1 && iX == 1
            if ~isnan(DxHF) && DxHF*DxHFn < 0
               AV = sprintf('DVAX. m=%d. DxHF=%g ~= DxHF=%g',m,DxHF,DxHFn);
               return
            end
         end     
         
         LX2 = L_2.*X.*X;
         S   = v_S1( Lch, LX2, dva, nmax);
         S1(iX) = S;  % figure,plot(dvao+hdva:hdva:dva,S1(1:iX)),grid
         % сечас выбиираем только правый корень у-я S=0
         % Раньше by RVD мб - любой.  Теперь RVD - для отладки в XRS
         
         %if RVD(2)              % выбор левого 2а
         %   if SA> 0 && S < 0,  fKI = 1;          break;
         %   else                SA  = S;  XA = X; end               
         %else                   % выбор правого 2а (по умолч)
            if SA< 0 && S > 0,   fKI = 1;  break;
            %elseif abs(SA) < abs(S)   % |S| стал возрастать
            %   hdva = 0.5*hdva; 
            %   dva  = dva-hdva;  
            %   Xmi  = (Xmip+Xmi)*0.5;
            %   Xma  = (Xmap+Xma)*0.5;
            %   continue
            else                 SA = S;  XA = X; 
            end 
         %end
         
         if RVD(1) && iX > 2  % Строить диапазоны Хmi, Xma для след 2а
            fig1 = figure;  
            plot([Xmi Xma],37,'.r', X,37,'.g',Xot,37,'ok',...
                 X([5 5]),[21 37],':', X([1 1]),[21 37],':') 
            title(sprintf('m=%d iX=%d Xfa=%5g',m,iX,Xfa))
            prib('Дальше')
            delete(fig1), clear fig1
         end
  
         %Xs(j,:) = X(1:2)';
         %Rs(j)   = X(1)-X(2);         
         if dva < dvaf 
                      % dva-экстраполяция
            XX = [X(1); X(2); X(5)]; 
            if iX==1, Xe = 0.5*(extDD(  Xot,XX,Xfa, dvao,dva,dva+hdva)+XX);
                    %Xe_= 0.5*(extDD_2(Xot,XX,Xfa, dvao,dva,dva+hdva)+XX);
                    %Xe = 0.5*(extDD_p(Xot,XX,Xfa, dvao,dva,dva+hdva,4)+XX);                
            else
               Xe = extDD(Xp,XX,Xfa, dva-hdva,dva,dva+hdva)-0.6321*abs(Xep-XX);
             %Xe_2 = extDD_2(Xp,XX,Xfa, dva-hdva,dva,dva+hdva)-0.6321*abs(Xep-XX);
             %Xe_4 = extDD_p(Xp,XX,Xfa, dva-hdva,dva,dva+hdva,4)-0.6321*abs(Xep-XX);
            end
            %fi=figure;Y(iX)=X(1); D(iX)=dva;plot(D,Y);
            %delete(fi)
            %if iX==1, fi2=figure; hold; end
            %plot([XX Xep])            
            %d   = X(1)-X(2);
            Xma = Xe(1);%+d; 
            Xmi = Xe(2);%-d; 
            Xep = Xe;
            Xp  = XX;
         end 
      end   % конец выч S1(dva)
      %delete(fi2)
      
      if fKI  &&  RVD(1) == 0,  break 
      else                         % Строить графики S1(2a)
         if ~exist('fig2','var'), fig2 = figure; hold on; end
         dvas = setK([dvaG qa]);
         plot(sqrt(dvas)/pi, S1);  
         titlab(sprintf('m=%d iX=%d fKI=%d',m,iX,fKI),{'2a' 'S1'});   
         me = menu('','Уменьш к.шагов в 2',...
                      'Уменьш к.шагов в 4',...
                      'Увел к.шагов в 2', ...
                      'Увел к.шагов в 4', ...
                      'Не изм к.шагов',...
                      'Выход');
         if me == 6 
            delete(fig2), clear fig2
            AV = sprintf(['Работа программы завершена принудительно\n'...
                'X([1 5])=%g %g, S1(%d)=%g'],X([1 5]),iX,S1(iX));
            return
         else
            deg = [-1 -2 1 2 0 0];
            if ~fKI, prib('КИН не найд. Изм диапазон 2а');
            else     prib('Задать диапазон 2а');  end
            [x(1:2) y] = ginput(2);       
            if x(1) > x(2),  x(1:2) = x([2 1]); end
            dvaG = (x*pi).^2;             % dvaG измененное
            if dvaG(1) < dvaG0(1),   dvaG(1) = dvaG0(1); end
            if dvaG(2) > dvaG0(2),   dvaG(2) = dvaG0(2); end
            qa  = round(qa*2^deg(me));
            XG  = sqrt(dvaG/LNA2);
            Xmi = XG(1);
            Xma = XG(2);
         end
      end   
   end  % while
                      % поиск корня dva:  S1(dva) = 0
   A_ = dva-hdva;    B_   = dva;
   XA_= XA(1:2);     XB_  = X(1:2);                                  
   SA_= SA;          Lot2_= Lot2;                 
          
   if nT < 3          % ТСВ5-18 
      T2 = vT2(KZma,KZsr,LG2,[A_ B_]); %-2*2-матрица=столбLG2*cтрока[A_ B_]
      TA5 = T2(2,1);
      if Lot2 >= L6_2  
         if XA(5)^2 < TA5  %ТСВ5-20
            if X(5)^2 < TA5,   Sf=@Solv52f;  io=1;  SR=@SolvR2T; ioR=1; 
                               fT=8; SL=SolvL2;    ioL=2; 
            else               fT=3; Sf=@Solv52fT; io=1;  
            end
         elseif XA(1)^2>T2(1,1)
            if X(1)^2<T2(1,2), fT=2; Sf=@Solv52fT; io=2; 
            else               fT=1; Sf=@Solv52f;  io=2; SR=@SolvR2; ioR=2;end
         else 
            Sf=@Solv52fT; io=1; 
            if X(5)^2>T2(2,2), fT=0; SR=@SolvR2;  ioR=2; 
            else               fT=2; end
            if X(1)^2>T2(1,2), fT=7-fT; SL=SolvL2;   ioL=1; 
            else               fT=6-fT; end
         end 
      else     % Lot2 < L6_2  
         if XA(5)^2 < TA5  %ТСВ5-20
            if X(5)^2 < TA5,   fT=8; Sf=@Solv52f;  io=1; SL=SolvL2; ioL=2;
            else               fT=3; Sf=@Solv52fT; io=1;
            end
         elseif XA(1)^2>T2(1,1)
            if X(1)^2<T2(1,2), fT=2; Sf=@Solv52fT; io=2;
            else               fT=1; Sf=@Solv52f;  io=2; end
         else 
            Sf=@Solv52fT; io=1; 
            if X(1)^2>T2(1,2), fT=5; SL=SolvL2;   ioL=1;
            else               fT=4; end
         end           
      end
   else  Sf = @Solv52f;   
   end      
      
   try [dva,~,FL1,out] = fzero( @(a)  v_S1_52( ...
                         KZ,nT,n,c, a, Sf,io,hL,L1, ...
                         qRS,nmax,Lch,L_2,Xot,Xot2),...
                         [A_  B_]);           
       if FL1 ~= 1,  AV = ['DVAX\n' out.message]; return,end   
   catch ME
      AV = sprintf('m=%d  S1[%g  %g] = [%g  %g]\n%s\n',...
                    m, sqrt([A_ B_])/pi, SA,S, ME.message);
      return
   end
             % Выч X для найд dva: продолжение ХС влево и вправо по L      
   dv_X = dva/Xot2;       %только для nm1=2: перевыч Lot,т.к. изм dva
   Lot2 = FLot2( KZma,KZmi, dv_X, dv_X*NA2ma);
   Lot  = sqrt(Lot2);  
   
   XC  = XC_;  
   Xw  = XC(3);
   XC1 = XC(1);
   XC2 = XC(2);
   XC4 = XC(4);
   XC5 = XC(5);
   % опр LT  ТСВ5-13
   %LTp2 = dva*n2T/(Xfa*Xfa);  % прибл LT: A/L=Xfa
   %LT2 = fzero(@(L2)  vT2(KZma,KZsr,L2,dva) - ...
   %      extDLf(XC5,XC1,Xfa,L5_2,L1_2,L2)^2, [LTp2; L1_2]);
                    % после удаления SolvLr
   qHF2 = qHF;  
   mdm  = m-dm;
   if Lot2 >= L6_2  
      if fT <= 6  % не надот выч SR, ioR
         if fT ~= 5
            if XC1^2 < vT2(KZma,KZsr,L1_2,dva)
                 SL = @SolvL2;  ioL = 1;
            elseif extDLf(XC1,Xw,Xfa,L1,Lw,LZ1)^2 < vT2(KZma,KZsr,LZ12,dva)
                 SL = @SolvL2T; ioL = 2;
            else SL = @SolvL2;  ioL = 2;
            end 
            
            if fT >= 2
               if io_== 2, SR = @SolvR2;  ioR = 2;
               else        SR = @SolvR2T; ioR = 1; end
            end
         elseif io_== 2, SR = @SolvR2;  ioR = 2;
         else            SR = @SolvR2T; ioR = 1; 
         end 
      end  
      
      x0ep = extDLor( Xw,XC4,Xot, Lw,L4,Lot); % прибл для X5
      L9 = min(Lot, LZ(2));
      qR = floor( (L9-L5)/hL + 1e-9); % поиск Х вправо от Lw 
      stat(29,mdm) = qR;
      XR = SR(KZ,nT,n,c,dva,ioR,hL,L6, qR,XC4,XC5,x0ep,L9,Xot,Lot); 
      if ischar(XR), AV = sprintf('m=%d\n%s',m,XR);  return,end  
      qd = qR+5;
   elseif fT <= 4   % Lot2 < L6_2 
      if XC1^2 < vT2(KZma,KZsr,L1_2,dva)
         SL = @SolvL2;  ioL = 2;
      elseif extDLf(XC1,Xw,Xfa,L1,Lw,LZ1)^2 < vT2(KZma,KZsr,LZ12,dva)
         SL = @SolvL2T; ioL = 2;
      end  
   end 

   x0eL = extDLfr( Xw,XC2, Xfa, Lw,L2);
   XL = SL(KZ,nT,n,c,dva,ioL,hL,L0, qL,XC2,XC1,x0eL,LZ1,Xfa);   
   stat(30,mdm) = qHF-qHF2;
   if ischar(XL),  AV = sprintf('m=%d\n%s',m,XL);  return,end
   q = qL+qd; 
   t = [m; L5+qR*hL; q; dva; Lot; flipud(XL); XC; XR];
   
   %{
   hE = (XC(4)-XC5)*0.1;
   %T2C_= vT2( KZma, KZsr, L_2, dva);     
   [e1C e3C V2C T2C] = eVT( KZ, L_2, dva);  
   bns = bJYIK{nT}(:,1); 
   XEC = nan(5,1);
   for k = 1:5
     C = XC(k)*(1-1e-9);
     while C > XC(k)-1;
        Cp = C;
        C  = C-hE;
        if HF(n,c,e1C(k),e3C(k),T2C(k),V2C(k),C,ahi{io},bns{io}) >= 0
           try
           XEC(k)=fzero(@(x) HF(n,c,e1C(k),e3C(k),T2C(k),V2C(k),x,ahi{io},bns{io}),[Cp; C]);
           break
           catch ME
           prib(['DVAX\n' ME.message])
           end
        else
         hE = hE+hE;
        end
     end  
   end
     
   LUNC = XC-XEC;
   LU   = [flipud(LUNL); LUNC; LUNR];
   LUma = LU(1)*1.01;
   l = LZ1:hL:t(2);
   figure;  plot(l,LU,[LTE LTE],[0 LUma],':b',[LTH LTH],[0 LUma],':r'); 
   title(sprintf('m=%d  a2=%4g',m,sqrt(dva)/pi));
   %}
   
   q5 = 5+q;
   if mk == nm1,  dvaX = nan( q5, mk9);
      if nm1,     dvaX(:, 1) = dvaX1( 1:q5 ); 
                  dvaX([2 3 5],1) = t( [2 3 5] );
      end
   end
   mk = mk+1;
   dvaX(1:q5,mk) = t;
   
   hpb = PB_DVAX( hpb, m, mk, mk9);
   m   = m+1;   
end  %  m
 
delete( hpb )
if iow, prib('Было %d расположений Lot < Lw',iow); end

% выч m*n-матрицы Т2 для всех nT. Z1=KZma, Z2=KZsr - к-ты слоя с макс/ср n
% L2 - столбец(m*1), dva - строка(1*n)
function T2 = vT2( Z1,Z2, L2, dva)  
T2 = ((n_2kZ(Z1,L2)-n_2kZ(Z2,L2))./L2)*dva;

% ____________Выч дисп S1 = v_S1( Solv( X0)) для FZERO, 
% где Х0-интерполяция для 2а: А<2а<B при известных Х(А) и Х(В)_______
% nm1 = true.   Xot2, iNA - не исп
function SC = v_S1_51(KZ,nT,n,c,dva, Sf,io,hL,L1,qRS,nmax,Lch,L2) 
global XC_  A_  B_  XA_  XB_  SA_ 
 
XC0 = ((B_-dva)*XA_+(dva-A_)*XB_)/(B_-A_);
XC_ = Sf(KZ,nT,n,c,dva,io,hL,L1, qRS,XC0(1),XC0(2));
%XC=Solv51f_(KZ,nT,n,c,dva,io,hL,L1, qRS,XC0(1),XC0(2));
%XC_=XC;
SC = v_S1( Lch, L2.*XC_.^2, dva, nmax); 

if SA_*SC < 0
   if  A_~= dva,  B_= dva;  XB_= XC_(1:2);  end
elseif B_~= dva,  A_= dva;  XA_= XC_(1:2);  SA_= SC; 
end

% ____________Выч дисп S1 = v_S1( Solv( X0)) для FZERO, 
% где Х0-интерполяция для 2а: А<2а<B при известных Х(А) и Х(В)_______
% nm1 = false
function SC = v_S1_52(KZ,nT,n,c,dva, Sf,io,h,L1,qRS,nmax,Lch,L2, Xot,Xot2) 
global iNAs
global XC_  A_  B_  XA_  XB_  SA_  Lot2_

Lot2_= FLot2( KZ(:,iNAs(1,nT)), KZ(:,iNAs(3,nT)), dva/Xot2,Lot2_); % только для nm1=2
XC0  = ((B_-dva)*XA_+(dva-A_)*XB_)/(B_-A_);

XC_= Sf(KZ,nT,n,c,dva,io,h,L1, qRS,XC0(1),XC0(2), Xot, sqrt(Lot2_));

SC = v_S1( Lch, L2.*XC_.^2, dva, nmax); 
if SA_*SC < 0
   if  A_~= dva,  B_= dva;  XB_= XC_(1:2);  end
elseif B_~= dva,  A_= dva;  XA_= XC_(1:2);  SA_= SC; 
end

% _________ Ф-ция вычисления Lot (побыстрее FLot) _____________________
function Lot2 = FLot2( KZma,KZmi, dv_X, L20)
% dv_X = (2*a*pi/Xot)^2
Lot2 = fzero(@(L2) L2-dv_X*(n_2kZ(KZma,L2)-n_2kZ(KZmi,L2)), L20);

% ____________Выч дисперсии S1 по 5 равноотстоящим точкам Х___________
function S1 = v_S1( Lch, LX2, dva, nmax) % только для X длины 5
% Lch = L(3)/(12*hL^2*c)
% LX2 = L^2.*X^2,  nmax - столбцы        
S1 = -Lch*([-1  16 -30  16 -1]*sqrt(nmax-LX2/dva));

%________нахожд реш Х на РС __________
function X = XRS1(nT,n,c,SR1,ioz,L1,L2,qX,Xmi,Xma,e1,e3,V2,T2,otl,GXm)                              
% Lw - Lambda of working(рабочая длина волны)
% io - индекс области особенности
% Выход   42 HF=char
%         44 Авост в Solv  
%         45-48 НеМБ

global infC Em9 Ep9
global HFs ahis bJYIK
global Xe_2 Xe_4

HF  = HFs{ nT};
ahi = ahis{nT};

if        ioz > 0,  X1 = setK([Xmi Xma qX]);              io = ioz;
else  
   t1 = sqrt(T2(1));
   t2 = sqrt(T2(2));    
   if     ioz==-1,  X1 = setK([Xmi t1*Em9 qX]);  io = 1;
   elseif ioz==-2,  X1 = setK([t2*Ep9 Xma qX]);  io = 2;
   elseif 2*Xma-(Xma-Xmi)/4 > t1+t2,    % x1+x2>T1+T2,  x2=Xma-(Xma-Xmi)/4
        X1 = setK([t2*Ep9 t1+Xma-Xmi qX]);       io = 2;  % ioz = -2.5;
   else X1 = setK([[sqrt(T2(5)) t1]*Em9 qX]);    io = 1;    ioz = -1.5;    
   end 
end

%tic

Xm  = X1( :,[1 1]); 
edX = ones( numel(X1),1); 
bms = bJYIK{nT}(:,3);  
e1m = e1( edX,1:2);
e3m = e3( edX,1:2);
V2m = V2( edX,1:2);  
T2m = T2( edX,1:2);
Z = HF( n, c, e1m, e3m, T2m, V2m, Xm, ahi{io}, bms{io});
%plot(X1,Z),title(sprintf('io=%d T_2=%g',io,sqrt(T2(2)))),grid

if ioz==-2
   X2 = X1;
   I1 = X1 > t1;                X1 = X1(I1);  Z1 = Z(I1,1);
   if V2(1)-Xma^2 < V2(1)-V2(2)
      I2 = X2<sqrt(V2(2));      X2 = X2(I2);  Z2 = Z(I2,2);
   else                                       Z2 = Z(:, 2);
   end  
else
   Z1 = Z(:,1);    
   if ioz == 2
      if V2(1)-Xma^2 < V2(1)-V2(2)
         I2 = X1 < sqrt(V2(2));    X2 = X1(I2);  Z2 = Z(I2,2);
      else                         X2 = X1;      Z2 = Z(:,2);
      end    
   elseif ioz==1,                  X2 = X1;      Z2 = Z(:,2);
   else              I2 = X1<t2;   X2 = X1(I2);  Z2 = Z(I2,2);
   end
end  
 
%{
   %tic
   bvs = bJYIK{nT}(:,2); 
   if ioz==-1,   X1 = setK([min(Xmi,sqrt(T2(5))) sqrt(T2(1))*Em9 qX]); 
                 X2 = X1( X1< sqrt(T2(2))); 
   else          X1 = setK(Xmi Xma qX]);      X2 = X1;

   Z1 = HF(n,c,e1(1),e3(1),T2(1),V2(1),X1,ahi{io},bvs{io});
   Z2 = 
   %toc
%}
%toc

if nT==1 
   if     ioz==1
      [xH1 fH1] = KINs1_1(X1,Z1,T2(1),nT);           % fH = {0; -1}
      [xH2 fH2] = KINs1_1(X2,Z2,T2(2),nT);
   elseif  ioz==-1 || ioz==-1.5     
      [xH1 fH1] = KINs1_A( X1,Z1);
      [xH2 fH2] = KINs1_A( X2,Z2);
      if     fH1 == 2,  SR1 = @Solv51; io = 2;   
      elseif fH2 == 2,  SR1 = @Solv51C;   end     % L1: io=1   L2: io=2      
   else
      if ioz==2
         [xH1 fH1] = KINs1_2(X1,Z1,T2(1),V2(1));  % fH = {0; -1; 1(см)}
         [xH2 fH2] = KINs1_2(X2,Z2,T2(2),V2(2));  % не мб fH={0;1}
      else  % ioz ==-2 | -2.5  
         [xH2 fH2] = KINs1_B( X2,Z2,t2,V2(2)); 
         [xH1 fH1] = KINs1_B( X1,Z1,t1,V2(1));    % fH = {0; -1; 1(см)}
      end
     if     fH2==1,   SR1 = @Solv51T;  io = 1;   
     elseif fH1==1,   SR1 = @Solv51C;   end       % L1:io=1 L2:io=2        
   end
elseif ioz == 1   % nT=2 
   [xH1 fH1] = KINs1_1(X1,-Z1,T2(1),nT);
   [xH2 fH2] = KINs1_1(X2,-Z2,T2(2),nT);
elseif  ioz==-1 || ioz==-1.5     
   [xH1 fH1] = KINs1_A( X1,-Z1);
   [xH2 fH2] = KINs1_A( X2,-Z2);
   if     fH1 == 2,  SR1 = @Solv51;  io = 2;   
   elseif fH2 == 2,  SR1 = @Solv51C;   end        % L1: io=1   L2: io=2      
else
   if ioz==2
      [xH1 fH1] = KINs1_2(X1,Z1,T2(1),V2(1));     % fH = {0; -1; 1(см)} 
      [xH2 fH2] = KINs1_2(X2,Z2,T2(2),V2(2)); 
   else % ioz ==-2 | -2.5    
      [xH2 fH2] = KINs1_B( X2,Z2,t2,V2(2));    
      [xH1 fH1] = KINs1_B( X1,Z1,t1,V2(1));       % fH = {0; -1; 1(см)} 
   end
   if     fH2==1,  SR1 = @Solv51T;  io = 1;
   elseif fH1==1,  SR1 = @Solv51C;    end         % L1:io=1  L2:io=2          
end
%bvs=bJYIK{nT}(:,2);e=1e-5;t=sqrt(T2(1));v=sqrt(V2(1));
%xL=setK([0.1 t-e qX]);FL=HF(n,c,e1(1),e3(1),T2(1),V2(1),xL,ahi{1},bvs{1});
%xR=setK([t+e v   qX]);FR=HF(n,c,e1(1),e3(1),T2(1),V2(1),xR,ahi{2},bvs{2});
%figure,plotyy(xL,FL,xR,FR),hold, plot(GXm(1),0,'.k',GXm(2),0,'.r')
%title(sprintf('t=%g v=%g Xot=%g Xfa=%g',t,v,GXm)),grid

clr = false;
if clr, clr_XRS1(nT,n,X1,T2,V2,L1,L2,Xm,Z);  end
if otl, otl_XRS1(X1,Z1,X2,Z2,T2,V2,xH1,xH2); end

X = SR1( nT,n,c,io,L2-L1,L1, 5,xH1,fH1,xH2,fH2,e1,e3,V2,T2);
if ischar(X), X = sprintf('XRS1\n%s io=%d\n%s',infC,io,X); end

%________ нахожд реш Х на РС ________________________________________
function [X io] = XRS2(nT,n,c,SR2,ioz,L1,L2,qX,Xmi,Xma,e1,e3,V2,T2,Xot,Lot,otl)
% Lw - Lambda of working(рабочая частота)
% io - индекс области особенности
% Выход  42  HF=char
%        44  Авост в Solv  
%        45-48  НеМБ

global infC Em9 Ep9
global HFs ahis bJYIK
global LUR
global DxHFn

LUR = 0;

HF  = HFs{ nT};
ahi = ahis{nT};

if        ioz > 0,  X1 = setK([Xmi Xma qX]);     io = ioz;
else  
   t1 = sqrt(T2(1));
   t2 = sqrt(T2(2));    
   if     ioz==-1,  X1 = setK([Xmi t1*Em9 qX]);  io = 1;
   elseif ioz==-2,  X1 = setK([t2*Ep9 Xma qX]);  io = 2;
   elseif 2*Xma-(Xma-Xmi)/4 > t1+t2,    % x1+x2>T1+T2,  x2=Xma-(Xma-Xmi)/4
        X1 = setK([t2*Ep9 t1+Xma-Xmi qX]);       io = 2;  % ioz = -2.5;
   else X1 = setK([[sqrt(T2(5)) t1]*Em9 qX]);    io = 1;    ioz = -1.5;
   end  
end
%tic
   
Xm  = X1( :,[1 1]); 
edX = ones( numel(X1),1); 
bms = bJYIK{nT}(:,3);  
e1m = e1( edX,1:2);
e3m = e3( edX,1:2);
V2m = V2( edX,1:2);  
T2m = T2( edX,1:2);
Z = HF( n, c, e1m, e3m, T2m, V2m, Xm, ahi{io}, bms{io});
%plot(X1,Z),title(sprintf('io=%d T=[%g %g]',io,sqrt(T2([2 1])))),grid

if ioz <= -2
   X2 = X1;
   I1 = X1 > t1;                X1 = X1(I1);  Z1 = Z(I1,1);
   if V2(1)-Xma^2 < V2(1)-V2(2)
      I2 = X2<sqrt(V2(2));      X2 = X2(I2);  Z2 = Z(I2,2);
   else                                       Z2 = Z(:, 2);
   end  
else
   Z1 = Z(:,1);    
   if ioz == 2
      if V2(1)-Xma^2 < V2(1)-V2(2)
         I2 = X1 < sqrt(V2(2));    X2 = X1(I2);  Z2 = Z(I2,2);
      else                         X2 = X1;      Z2 = Z(:,2);
      end    
   elseif ioz==1,                  X2 = X1;      Z2 = Z(:,2);
   else              I2 = X1<t2;   X2 = X1(I2);  Z2 = Z(I2,2);
   end
end  
 
%{
   %tic
   bvs = bJYIK{nT}(:,2); 
   if ioz==-1,   X1 = setK([min(Xmi,sqrt(T2(5))) sqrt(T2(1))*Em9 qX]); 
                 X2 = X1( X1< sqrt(T2(2))); 
   else          X1 = setK(Xmi Xma qX]);      X2 = X1;
   end

   Z1 = HF(n,c,e1(1),e3(1),T2(1),V2(1),X1,ahi{io},bvs{io});
   Z2 = HF(n,c,e1(2),e3(2),T2(2),V2(2),X2,ahi{io},bvs{io});
   %toc
%}
%toc
%}
%plot(X1,Z1,X2,Z2),title(sprintf('io=%d T=[%g %g]',io,sqrt(T2([2 1])))),grid

if ioz == 1
   [xE1 xH1 fH1] = KINs2_1( X1,Z1, T2(1) );       % fH = {0; -1}
   [xE2 xH2 fH2] = KINs2_1( X2,Z2, T2(2) );
elseif ioz == -1 || ioz == -1.5
   [xE1 xH1 fH1] = KINs2_A( X1,Z1);               % fH = {0; -1; 2}
   [xE2 xH2 fH2] = KINs2_A( X2,Z2);
   if     fH1 == 2,  SR2 = @Solv52;  io = 2; 
   elseif fH2 == 2,  SR2 = @Solv52C;    end       % L1: io=1   L2: io=2      
else         
   if ioz == 2
      [xE1 xH1 fH1] = KINs2_2(X1,Z1,T2(1),V2(1)); % fH = {0; -1; 1} 
      [xE2 xH2 fH2] = KINs2_2(X2,Z2,T2(2),V2(2)); 
   else  % ioz == -2 | -2.5    
      [xE2 xH2 fH2] = KINs2_B(X2,Z2,t2,V2(2));
      [xE1 xH1 fH1] = KINs2_B(X1,Z1,t1,V2(1));    % fH = {0; -1; 1}
   end
   if     fH2==1,  SR2 = @Solv52T;  io = 1;   
   elseif fH1==1,  SR2 = @Solv52C;    end         % L1:io=1  L2:io=2    
end
% figure, plot(X1,Z1,X2,Z2),grid 
%bvs=bJYIK{nT}(:,2);e=1e-5;t1=sqrt(T2(1));t2=sqrt(T2(2));t1L=t1+e;t1R=t1-e;t2L=t2+e;t2R=t2-e;v1=sqrt(V2(1));v2=sqrt(V2(2));
%x1=setK([t1R (t1R+v1)/2 qX]);F1=HF(n,c,e1(1),e3(1),T2(1),V2(1),x1,ahi{2},bvs{2});
%y1=setK([t1R/2 t1L qX]);G1=HF(n,c,e1(1),e3(1),T2(1),V2(1),y1,ahi{1},bvs{1});
%figure,plot(x1,F1,y1,G1,t1,0,'.r'),title(sprintf('io=2 t1=%g v1=%g',t1,v1)),grid
%x2=setK([t2R (t2R+v2)/2 qX]);F2=HF(n,c,e1(2),e3(2),T2(2),V2(2),x2,ahi{2},bvs{2});   
%y2=setK([t2R/2 t2L qX]);G2=HF(n,c,e1(2),e3(2),T2(2),V2(2),y2,ahi{1},bvs{1});   
%figure,plot(x2,F2,y2,G2,t2,0,'.b'),title(sprintf('io=1 t2=%g v2=%g',t2,v2)),grid

clr = false;
if clr, clr_XRS2(nT,n,X1,T2,V2,L1,L2,Xm,Z);  end
if otl, otl_XRS2(X1,Z1,X2,Z2,T2,V2,xH1,xH2); end
                  
X = SR2( nT,n,c,io,L2-L1,L1, 5,xH1,fH1,xH2,fH2, xE1,xE2,Xot,Lot, e1,e3,V2,T2);

if isnan(DxHFn)
   bn = bJYIK{nT}(:,1);
   hx = X1(2)-X1(1);
   if X(1)>X1(1), DxHFn=-HF(n,c,e1(2),e3(2),T2(2),V2(2),X(1)-hx,ahi{io},bn{io});
   else           DxHFn= HF(n,c,e1(2),e3(2),T2(2),V2(2),X(1)+hx,ahi{io},bn{io});
   end
end   

if ischar(X), X = sprintf('XRS2\n%s io=%d\n%s',infC,io,X); end

%________________ Интервалы локализации  корней Е и Н для nm1=1
% ТСВ4-c68-71
% Для nm1=1 FH дб монотонна
% Для io=2 d(FH)/dx > 0. - Этим условиям удовл только случаи  4, 5, 6
% Для io=1 d(FH)/dx < 0. - Этим условиям удовл только случаи 14,15,16
% nT==1  ||   io==2
function [xH fH] = KINs1( X,Z, V2,T2 )
global  Em9 Ep9
nZ = numel(Z);  Z1 = Z(1);    Zn = Z(nZ);   
if Z1 > 0              % 4)  
   X1 = X(1); 
   D  = Z1*(X(2)-X1)/(Z(2)-Z1);
   A  = X1-D-D;        % при m=1 лунки нет => шаг мб шире: 2D,а не 1.1*D
   if T2 < A*A,  xH = [A; X1];
   else          xH = [sqrt(T2)*Ep9; X1]; end
   fH = -1;                                            
elseif Zn>0         % 5) 
   k  = find(Z>0, 1);
   xH = [X(k-1); X(k)];  
   fH = 0;         
else                   % 6) для nm1=1 это вполне возможно
   Xn = X(nZ);  
   if Zn <= Z1
       xH = [Xn; sqrt(V2)*Em9]; % это мб только для nT=2,io=2 - проверить!
   else
      B = Xn+Zn*(X(nZ-1)-Xn)/(Zn-Z(nZ-1)); 
      if B*B < V2,   xH = [Xn; B]; 
      else           xH = [Xn; sqrt(V2)*Em9]; end
   end 
   fH = 0;             % fB>0 тк f выпукла
end

%______________ nm1=1 ioz = -1  ТСВ5-48с __________________________
function [xH fH] = KINs1_1( X,Z,T2,nT )
% figure,plot(X,Z),grid

nZ = numel(Z); Zn = Z(nZ);   
Z1 = Z(1);     

if Z1 > 0              % 1) ++    
   X1 = X(1);  
   xH = [X1-2*Z1*(X(2)-X1)/(Z(2)-Z1); X1];  % при m=1 лунки нет => шаг мб шире D
   fH = -1;                                            
elseif Zn > 0          % 2) -+
   k  = find(Z>0, 1);
   xH = [X(k-1); X(k)];  
   fH = 0;         
else                   % 3) -- 
   Xn = X(nZ); 
   [xH fH] = xH_35_1( Xn-Zn*(X(2)-X(1))/(Zn-Z(nZ-1)), Xn,T2,nT);
end

%________________nm1=1 ioz = -1  ТСВ5-48с ________________________________
function [xH fH] = KINs1_A( X,Z) 
% nT==2  &&   io==1
% Для аналоги с KINs1 перед входом в эту пр-му сделана замена Z=-Z
% Здесь Хn=sqrt(T2)

nZ = numel(Z); Zn = Z(nZ);
Z1 = Z(1);     X1 = X(1);  
h  = X(2)-X1;

if Z1 > 0               % 1) ++    
   X1 = X(1);  
   H  = Z1*h/(Z(2)-Z1);
   B  = X1-H;
   xH = [B-H/2; B]; % лунки нет => шаг мб шире: 1.5D,а не 1.1*D
   fH = -1;                                            
elseif Zn >= 0          % 2) -+
   k  = find(Z>0, 1);
   xH = [X(k-1); X(k)];  
   fH = 0;         
else                    % 3) --  тк Хn=T, то - смена io:1->2
   H  = -Zn*h/(Zn-Z(nZ-1)); 
   B  = X(nZ)+H;
   d  = H/2;
   xH = [B-d; B+d];
   fH = 2;          
end

%______________nm1=1 ioz=2 ТСВ5-49с ___________________________________
function [xH fH] = KINs1_2( X,Z,T2,V2 )
% Смены io в программе нет, но вообще она мб
% figure,plot(X,Z),grid
global  Em9 

nZ = numel(Z); Zn = Z(nZ);
Z1 = Z(1);     X1 = X(1);  
h  = X(2)-X1;

if Z1 > 0              % 1) ++ 
   X1 = X(1);
   H  = Z1*h/(Z(2)-Z1);
   B  = X1-H;
   if T2<=B*B, xH = [max((sqrt(T2)+B)/2,B-H/2); B];  fH =-1;
   else        xH = [B-H/2; B];                      fH = 1; end %cмена io
elseif Zn>0            % 2) -+
   k  = find(Z>0, 1);
   xH = [X(k-1); X(k)];  
   fH = 0;         
else                   % 3) -- 
   Xn = X(nZ);  
   if Zn <= Z1
      xH = [Xn; sqrt(V2)*Em9]; % это мб только для nT=2,io=2 ТСВ5-41с
   else
      B = Xn-1.5*Zn*h/(Zn-Z(nZ-1)); 
      if B*B < V2,   xH = [Xn; B]; 
      else           xH = [Xn; sqrt(V2)*Em9]; end
   end 
   fH = 0;          
end

%______________nm1=1 ioz=-2 _________________________________________
function [xH fH] = KINs1_B( X,Z,t,V2 )
% figure,plot(X,Z),grid
global  Em9

nZ = numel(Z); Zn = Z(nZ);
Z1 = Z(1);     X1 = X(1);  
h  = X(2)-X1;
  
if Z1 > 0              % 1) ++ 
   H  = Z1*h/(Z(2)-Z1);
   B  = X1-H;
   C  = min(B,t);
   d  = max(h, H/2);
   xH = [C-d;  C-d/2]; 
   fH = 1;
elseif Zn>0            % 2) -+
   k  = find(Z>0, 1);
   xH = [X(k-1); X(k)];  
   fH = 0;         
else                   % 3) --
   Xn = X(nZ);  
   if Zn <= Z1         % 3a)
      xH = [Xn; sqrt(V2)*Em9]; % это мб только для nT=2,io=2 - ТСВ5-41с
   else                % 3b)
      B = Xn-1.5*Zn*h/(Zn-Z(nZ-1)); 
      if B*B < V2,   xH = [Xn; B]; 
      else           xH = [Xn; sqrt(V2)*Em9]; end
   end 
   fH = 0;          
end

%____________nm1=2 ioz=1 _________________________________________________
function [xE xH fH] = KINs2_1( X,Z,T2)  
% При смене io: fH=2=io_new
X1 = X(1);   Z1 = Z(1);   D1 = Z(2)-Z1;
h  = X(2)-X1;
nZ = numel(Z);
Xn = X(nZ);  Zn = Z(nZ);  Dn = Zn-Z(nZ-1);   % знак производной в т. nZ 

if Dn > 0   % ТСВ4-с69 
   if D1 > 0                % Z1Zn  D1Dn
      xE = -1; 
      if Z1 > 0 %=> Zn>Z1>0  1) ++  ++ 
         xH = [X1-1.1*Z1*h/D1; X1];
         fH = -1;              % f(X1-H)>0 тк f выпукла вниз: ТСВ4-69  
      elseif Zn > 0         %2) -+  ++    
         k  = find(Z>0, 1);
         xH = [X(k-1); X(k)];  
         fH = 0;         
      else                  %3) --  ++  Возм смена io:1->2. Z в лунке
         [xH fH] = xH_35_1( Xn-Zn*h/Dn, Xn,T2,nT);
      end
   else
      xE = X1-Z1*h/D1;  
      if Zn > 0             %4) ++/-+  -+ 
         j  = find(Z<0, 1,'last');  
         xH = [X(j); X(j+1)]; 
         fH = 0;       
      else                  %5) +-/--  -+   Возм смена io:1->2
         [xH fH] = xH_35_1( Xn-Zn*h/Dn, Xn,T2,nT); 
      end 
   end
else                        % Dn < 0  => D1<0   ТСВ5-42с  
   if Zn > 0 % => Z1>Zn>0    6) ++  --    ТСВ5-67-47c
      H  = -Zn*h/Dn;
      A  = Xn+H; 
      r1 = h;
      xE = A+r1;             
      r2 = 2*h;              % регулятор оценки дальности А от Хn
      if A*A < T2,  xH = [xE; (xE+sqrt(T2))/2];  fH =-1;    
      else          xH = [xE; xE+max(r2,H/2)];   fH = 2; end; % смена io 
   else
      if Z1 > 0             %7) +-  --
         H  = Zn*h/Dn+h;      % h добавл, тк HF выпукла
         xE = Xn-H;
         B  = Xn+H;
         d  = H;
      else                  %8) --  --   Вся кривая Z -в лунке
         H  = Z1*h/D1-h;    % h вычит тк HF выпукла
         xE = X1-H;  
         d  = Xn-X1+H;
         B  = Xn+d;
      end
      
      if B*B < T2,   xH = [B-d/2; B];  fH = -1;      
      else           xH = [B; B+d/2];  fH = 2;  end   % смена io
   end
end  

%____________ ioz=-1 Xn=T ______________________________________________
function [xE xH fH] = KINs2_A( X,Z)   
% fH = {0; -1; 2}
% При смене io: fH=2=io_new
X1 = X(1);   Z1 = Z(1);   D1 = Z(2)-Z1;
h  = X(2)-X1;
nZ = numel(Z);
Xn = X(nZ);  Zn = Z(nZ);  Dn = Zn-Z(nZ-1);   % знак производной в т. nZ 

if Dn > 0       % ТСВ5-44c
   if D1 > 0                % Z1Zn  D1Dn
      xE = -1; 
      if Z1 > 0  %=> Zn>Z1>0  1) ++  ++ 
         xH = [X1-1.1*Z1*h/D1; X1];
         fH = -1;         
      elseif Zn > 0          %2) -+  ++    
         k  = find(Z>0, 1);
         xH = [X(k-1); X(k)];   
         fH = 0;         
      else                   %3) --  ++  Точно смена io:1->2. Z в лунке
         H  = -Zn*h/Dn;
         B  = Xn+H;
         d  = H/2;
         xH = [B-d; B+d];
         fH = 2;
      end
   else
      xE = X1-Z1*h/D1;  
      if Zn>0                %4) ++/-+  -+ 
         j  = find(Z<0, 1,'last'); 
         xH = [X(j); X(j+1)]; 
         fH = 0;
      else                   %5) +-/--  -+  Cмена io:1->2
         H  = -Zn*h/Dn;
         B  = Xn+H;
         d  = H/2;
         xH = [B+d; B-d];
         fH = 2;
      end                                            
   end
else            % Dn < 0  => D1<0   ТСВ5-42с
   if Zn > 0 % => Z1>Zn>0    6) ++  --    ТСВ5-62-42с ТСВ4-83 
      H  = -Zn*h/Dn;
      xE = Xn+H;
      B  = xE+h;
   elseif Z1 > 0            %7) +-  --
      H  = Zn*h/Dn+h; 
      xE = Xn-H;
      B  = Xn+H;
      d  = H;
   else                     %8) --  --   Вся кривая Z -в лунке!
      H  = Z1*h/D1-h;        % h вычит тк HF выпукла 
      xE = X1-H;           
      d  = Xn-X1+H;     
      B  = Xn+d;
   end
   xH = [B; B+d/2];             
   fH = 2;        % смена io:1->2 
end  

%__________ ioz=2 ТСВ5-62-43с ______________________________________
function [xE xH fH] = KINs2_2( X,Z,T2,V2)  
%  fH = {0; -1; 1}
global  Em10
X1 = X(1);   Z1 = Z(1);   D1 = Z(2)-Z1;
h  = X(2)-X1;
nZ = numel(Z);
Xn = X(nZ);  Zn = Z(nZ);  Dn = Zn-Z(nZ-1); % знак производной в т. nZ    

if Dn > 0                     %ТСВ5-43с   ТСВ4-с69
   if D1 > 0                  % Z1Zn  D1Dn
      xE = -1; 
      if Z1 > 0               %1) ++  ++  
         H = Z1*h/D1; 
         B = X1-H;
         d = max(h, H/2);
         if T2<=B*B, xH = [max((sqrt(T2)+B)/2,B-d); B];  fH =-1;
         else        xH = [B-d; B-d/2];                  fH = 1; end %cм
      elseif Zn > 0           %2) -+  ++
         k  = find(Z>0, 1);
         xH = [X(k-1); X(k)];
         fH = 0;         
      else                    %3) --  ++       Вся Z в лунке
         xH = xH_35_2( Xn-Zn*h/Dn, Xn,V2);
         fH = 0; % fB>0 тк f выпукла
      end
   else       % D1 <= 0
      xE = X1-Z1*h/D1;   
      if Zn > 0               %4) ++/-+  -+
         j  = find(Z<0, 1,'last');  
         xH = [X(j); X(j+1)]; 
      else                    %5) +-/-+  -+
         xH = xH_35_2( Xn-Zn*h/Dn, Xn,V2); % Z в лунке
      end
      fH = 0; 
   end
else % Dn < 0    % ТСВ5-42
   Ve = sqrt(V2)*Em10;
   if Zn > 0                  %6) ++  --  Уник вар-т   ТСВ4-83
      H  = -Zn*h/Dn;
      xE = Xn+H;
      A  = xE;  B = xE+2*H;
   elseif Z1 > 0              %7) +-  --
      H  = Zn*h/Dn; 
      xE = Xn-H;
      A  = Xn;  B = A+H;
   else                       %8) --  --   Вся кривая Z -в лунке!
      H  = Z1*h/D1;    
      xE = X1-H;    
      A  = Xn;   B = A+Xn-X1;
   end
   BV = min(B,Ve);
   xH = [(A+BV)/2; BV];             
   fH = -1;  
end  

%__________ ioz=2 ТСВ5-62-46с ______________________________________
function [xE xH fH] = KINs2_B( X,Z,t,V2)  
global  Em10
X1 = X(1);   Z1 = Z(1);   D1 = Z(2)-Z1;
h  = X(2)-X1;
nZ = numel(Z);
Xn = X(nZ);  Zn = Z(nZ);  Dn = Zn-Z(nZ-1); % знак производной в т. nZ    

if Dn > 0                     %ТСВ5-43с   ТСВ4-с69
   if D1 > 0                  % Z1Zn  D1Dn
      xE = -1; 
      if Z1 > 0               %1) ++  ++  
         H  = Z1*h/D1; 
         B  = X1-H;
         C  = min(B,t);
         d  = max(h, H/2);
         xH = [C-d; C-d/2]; 
         fH = 1;              % cмена io->1        
      elseif Zn > 0           %2) -+  ++
         k  = find(Z>0, 1);
         xH = [X(k-1); X(k)];
         fH = 0;         
      else                    %3) --  ++       Вся Z в лунке
         xH = xH_35_2( Xn-Zn*h/Dn, Xn,V2);
         fH = 0; % fB>0 тк f выпукла
      end
   else
      xE = X1-Z1*h/D1;   
      if Zn > 0               %4) ++/-+  -+
         j  = find(Z<0, 1,'last');  
         xH = [X(j); X(j+1)]; 
      else                    %5) +-/-+  -+
         xH = xH_35_2( Xn-Zn*h/Dn, Xn,V2); % Z в лунке
      end
      fH = 0; 
   end
else % Dn < 0    % ТСВ5-42
   Ve = sqrt(V2)*Em10;
   if Zn > 0                  %6) ++  --  Уник вар-т   ТСВ4-83
      H  = -Zn*h/Dn;
      xE = Xn+H;
      A  = xE;  B = xE+2*H;
   elseif Z1 > 0              %7) +-  --
      H  = Zn*h/Dn; 
      xE = Xn-H;
      A  = Xn;  B = A+H;
   else                       %8) --  --   Вся кривая Z -в лунке!
      H  = Z1*h/D1;    
      xE = X1-H;    
      A  = Xn;   B = A+Xn-X1;
   end
   BV = min(B,Ve);
   xH = [(A+BV)/2; BV];             
   fH = -1;  
end  

%________________ Интервалы локализации корней Е и Н для nm1>=2
% ТСВ4-c68-71
% Значения вых арг-тов ТСВ4-83
% Если КИН определен, то его концы не заходят за допуст гр-цы T и Ve

function [xE xH fH] = KINs2( X,Z,V2)  % ~ is T2
global Em10 

nZ = numel(Z);  Xn = X(nZ);   Zn = Z(nZ); 
Dn = Zn-Z(nZ-1);         % знак производной в т. nZ    

if Dn < 0
   Ve = sqrt(V2)*Em10;
   if Zn > 0             % 1) Z1,Zn>0  Dn<0  Уник вар-т   ТСВ4-83
      D  = Zn*(X(nZ-1)-Xn)/Dn;
      xE = Xn+D;
      A  = Xn+1.1*D;
      B  = xE+D;
      if     A > Ve,  B = Ve; A = (xE+B)*0.5;
      elseif B > Ve,  B = Ve;          end                
      xH = [A; B]; 
   elseif Z(1) > 0     % 2) Z1>0  Zn<0   Dn<0   
      xE = xE_278(Z,X);
      xH = [Xn; min(Xn+Xn-xE,Ve)];             
   else  % 3) Z1,Zn < 0   Вся кривая Z -в лунке!
      X1 = X(1);
      Z1 = Z(1);
      D  = Z1*(X(2)-X1)/(Z(2)-Z1);    
      xE = X1-D;    
      xH = [Xn; min(Xn+D+Xn-X1,Ve)]; 
   end
   fH = -1;      
else       % Dn > 0   ТСВ4-с69
   X1 = X(1);
   Z1 = Z(1);
   D1 = Z(2)-Z1;
   if D1 > 0  
      xE = -1; 
      if Z1 > 0            % 4)  Z1,Zn>0  Dn>0   
         xH = [X1-1.1*Z1*(X(2)-X1)/D1; X1];
         fH = -1;       % f(X1-D) >0 тк f выпукла вниз: ТСВ4-69  
      elseif Z(nZ) > 0         % 5) Z1<0  Zn>0 
         k  = find(Z>0, 1);
         xH = [X(k-1); X(k)];
         fH = 0;         
      else              % 6) Z1<0 Zn<0  Вся Z в лунке!(удалить?) 
         xH = xH_6810( Xn+Zn*(X(nZ-1)-Xn)/Dn, Xn,V2);
         fH = 0; % fB>0 тк f выпукла
      end
   elseif Z1 > 0        % 7-8)   D1=Z2-Z1<0 
      [xE k] = xE_278(Z,X); 
      if Zn>0,  j  = find(Z(k+1:nZ)>0, 1)+k;  % 7) Z1,Zn > 0
                xH = [X(j-1); X(j)]; 
      else      xH = xH_6810( Xn+Zn*(X(nZ-1)-Xn)/Dn, Xn,V2); %8)Zn<0        
      end
      fH = 0; % fB>0 тк f выпукла    
   else                % 9-10) Z1<0
      xE = X1-Z1*(X(2)-X1)/(Z(2)-Z1); 
      
      if Zn>0, j  = find(Z>0, 1);   % 9)   
               xH = [X(j-1); X(j)]; 
      else     xH = xH_6810( Xn+Zn*(X(nZ-1)-Xn)/Dn, Xn,V2); %10)Zn<0 
      end                                                % Z в лунке!?
      fH = 0;  
   end
end  

%______Выч прибл Е-корня для пп 2, 7, 8
function [xE k] = xE_278(Z,X)
k  = find(Z < 0, 1); 
xE = X(k-1) + Z(k-1)*(X(k)-X(k-1))/(Z(k-1)-Z(k)); 

%______Выч КИН для пп 3,5 KINs1_1 KINs1_2
% Если произошла смена io, то fH=2=io_new
function  [xH fH] = xH_35_1(B,Xn,T2,nT)
if     B*B > T2,  xH = [Xn; (Xn+sqrt(T2))/2];  fH =-1;   
elseif nT == 1,   xH = [Xn; B];                fH = 0;
else              xH = [Xn; (B+sqrt(T2))/2];   fH =-1; 
end

%______Выч прибл H-корня или КИН для пп 6,8,10 io=2
function  xH = xH_35_2(B,Xn,V2)
global Em10
if B*B < V2,  xH = [Xn; B]; 
else          xH = [Xn; sqrt(V2)*Em10];  end

% _____________ ProgressBar for DVAX ____________________________________
function hF = PB_DVAX( hF, m, i, i9)
persistent t 
if isempty(hF)
   X  = 400;  Y = 500;  W = 396;   H = 21; 
   hF = figure( 'NumberTitle','off', 'MenuBar','none',...
            'Position',[X Y W H]);

   t = uicontrol( hF, 'Style','text', 'Units','pixels', ...
       'BackgroundColor', [1 1 1], ...
       'Position', [5 5 388 14]);
end

ii = i/i9;
set( hF, 'Name', sprintf( ...
    ' m = %d            %d / %d = %4.0f %%', m, i, i9, round(100*ii)));

set( t, 'String', char( ones( 1, round(48*ii))), ...
    'HorizontalAlignment', 'left', ...
    'ForegroundColor', [0 0 1] )
figure(hF)

%________ Отладка для XRS1 ________________________________________
function otl_XRS1(X1,Z1,X2,Z2,T2,V2,xH1,xH2)
  T = sqrt(T2);  
  if io==2
     if  T < 10*(2*X1(1)-X1(2)),       t1 = NaN;  t2 = NaN;
     else                              t1 = T(1); t2 = T(2); end 
  elseif T > 10*(2*X1(end)-X1(end-1)), t1 = NaN;  t2 = NaN;
  else                                 t1 = T(1); t2 = T(2); 
  end

  V = sqrt(V2);
  if  V(1)-X1(end) > (X1(end)-X1(1))*0.5, v1 = NaN;  
  else                                    v1 = V(1);  end  
  if  V(2)-X2(end) > (X2(end)-X2(1))*0.5, v2 = NaN;  
  else                                    v2 = V(2);  end  


 % только для nm1==true
  f = figure;
  subplot(2,1,1);
  plot(X1,Z1,t1,0,'.r',v1,0,'.c');   hold on
  h1 = gca;
  
  YLi = get(h1,'YLim');
  YTi = get(h1,'YTick');  hY = (YTi(2)-YTi(1))/4;
  
  text(v1,hY,'V1','FontSize',8);
  if isscalar(xH1),  plot(xH1,0,'.k');    text(xH1,hY,'xH=V','FontSize',8);
  else               plot(xH1,[0 0],'.b',xH1,[0 0],'b');
                     text((xH1(1)+xH1(2))/2,hY,'xH','FontSize',8);
  end      
  XLi = get(h1,'XLim');
  
  subplot(2,1,2)
  h2 = gca; 
  set(h2,'XLim',XLi,'YLim',YLi);                          hold on
  plot(X2,Z2,t2,0,'.r',v2,0,'.c'); 
  
  text(v2,hY,'V2','FontSize',8);
  if isscalar(xH2), plot(xH2,0,'.k');      text(xH2,hY,'xH=V','FontSize',8);
  else              plot(xH2,[0 0],'.b',xH2,[0 0],'b');
                    text((xH2(1)+xH2(2))/2,hY,'xH','FontSize',8);
  end

  f1 = sprintf('%g ',fH1);   f2 = sprintf('%g ',fH2);
  title(h1,sprintf('fH1=%s T_1=%g V_1=%g io=%d',f1,T(1),V(1),io)); grid(h1)
  title(h2,sprintf('fH2=%s T_2=%g V_2=%g',f2,T(2),V(2)));          grid(h2)
  delete(f)

  %________Посмотреть в цвете области io и Z в XRS1 в 3D _________________________
  function clr_XRS1(nT,n,X1,T2,V2,L1,L2,Xm,Z)
   T    = sqrt(T2);      
   tit1 = sprintf('nT=%d, n=%d',nT,n); 
   txt  = {'1 yel  Хг<T Xд^2=Xг^2-T^2<0 => In,Kn' ...
           '2 cyan Хг>T Xд^2>0          => Jn,Yn' ...
           '3 red  Хг>V => Х.ф-ция  не определена'};
   Gfig = gcf;
   fig1 = figure('Name',tit1);              
   SX1  = X1(1);      SX9 = X1(end); 
   V    = sqrt(V2);
    
   fill( [L1 L2 L2 L1], [SX1 SX1 SX9 SX9], 'w')
   hold       
   T9 = T(end);
   V1 = V(1);
   fill( [L1 L2 L1],    [T T9],    'y')
   fill( [L1 L2 L2 L1], [T V1 V1], 'c');
   fill( [L1 L2 L2],    [V V1],    'r');
   if SX1 > T9, fill( [L1 L1 L2 L2], [SX1 T9  T9  SX1],'w'); end
   if SX9 < V1, fill( [L1 L1 L2 L2], [V1  SX9 SX9 V1 ],'w'); end
   plot( [L1 L2],[T V]) 
   titlab( txt,{'\lambda' 'T,V'})
   prib( 'Далее' ) 
   T1  = T(1);
   Lob = [1.1*L1  1.2*L1];
   Xob = [1.2*SX1  0.9*T1];
         
   figure(fig1)
   text( Lob(io), Xob(io), num2str(io),'FontSize',14,'color','k')  
   tit2 = sprintf('%s cетка %dx2', tit1, psX(3));
   while true
      me = menu('Выбрать график',...
           'Поверхность','0-Уровни','Каркас1','Каркас2',...
           'контуры','Уровни+марк','Выход');
      figure(Gfig)  
      Lm = [L1(edX,1) L2(edX,1)];
      if     me==1, surfc   ( Lm, Xm, Z)
      elseif me==2, contour ( Lm, Xm, Z, [0 0] )
      elseif me==3, meshc   ( Lm, Xm, Z)  
      elseif me==4, meshz   ( Lm, Xm, Z)
      elseif me==5, contour3( Lm, Xm, Z)
      elseif me==6, [cHF,hHF] = contour( Lm,Xm,Z);  clabel(cHF,hHF);
      else   break
      end
      titlab(tit2, {'L','X'});
   end
   delete(fig1);

 %_______ Отладка для XRS2 __________________________
 function otl_XRS2(X1,Z1,X2,Z2,T2,V2,xH1,xH2)
  T = sqrt(T2);
  if io==2
     if  T < 10*(2*X1(1)-X1(2)),       t1 = NaN;  t2 = NaN;
     else                              t1 = T(1); t2 = T(2); end 
  elseif T > 10*(2*X1(end)-X1(end-1)), t1 = NaN;  t2 = NaN;
  else                                 t1 = T(1); t2 = T(2); 
  end
  
  V = sqrt(V2);
  if  V(1)-X1(end) > (X1(end)-X1(1))*0.5, v1 = NaN;  
  else                                    v1 = V(1);  end
  
  if  V(2)-X2(end) > (X2(end)-X2(1))*0.5, v2 = NaN;  
  else                                    v2 = V(2);  end  

  % nm1==false
  f = figure;
  subplot(2,1,1); 
  plot(X1,Z1,t1,0,'.r',v1,0,'.k');  hold on
  
  h1  = gca; 
  YLi = get(h1,'YLim');  
  YTi = get(h1,'YTick');  hY = (YTi(2)-YTi(1))*0.25; 
  
  text(v1,hY,'V1','FontSize',8);
  if     ischar(xE1),   xlabel(['xE ' xE1]);
  elseif isscalar(xE1), plot(xE1,0,'.k');     text(xE1,hY,'xE','FontSize',8);
  else   plot(xE1,[0 0],'.k', xE1,[0 0],'k'); text(xE1(1),hY,'xE','FontSize',8);
  end
  
  if isscalar(xH1),   plot(xH1,0,'.k');    text(xH1,hY,'xH=V','FontSize',8);
  else plot(xH1,[0 0],'.b',xH1,[0 0],'b'); text(xH1(1),hY,'xH','FontSize',8);
  end      
  XLi = get(h1,'XLim');
  
  subplot(2,1,2); 
  h2 = gca;  
  set(h2,'XLim',XLi,'YLim',YLi);         hold on             
  plot(X2,Z2,t2,0,'.r',v2,0,'.k');        
  
  text(v2,hY,'V2','FontSize',8);
  if     ischar(xE2),   xlabel(['xE ' xE2]);
  elseif isscalar(xE2), plot(xE2,0,'.k');    text(xE2,hY,'xE','FontSize',8);
  else   plot(xE2,[0 0],'.k',xE2,[0 0],'k'); text(xE2(1),hY,'xE','FontSize',8);
  end
  
  if isscalar(xH2), plot(xH2,0,'.k');      text(xH2,hY,'xH=V','FontSize',8);
  else plot(xH2,[0 0],'.b',xH2,[0 0],'b'); text(xH2(1),hY,'xH','FontSize',8);
  end  
   
  f1 = sprintf('%g ',fH1);   f2 = sprintf('%g ',fH2);
  title(h1,sprintf('fH1=%s T_1=%g V_1=%g io=%d',f1,T(1),V(1),io)); grid(h1)
  title(h2,sprintf('fH2=%s T_2=%g V_2=%g',f2,T(2),V(2)));          grid(h2)
  delete(f)
 
 %_______ Посмотреть в цвете области io и Z в XRS2 в 3D __________________
 function clr_XRS2(nT,n,X1,T2,V2,L1,L2,Xm,Z)
   T   = sqrt(T2);   
   tit1 = sprintf('nT=%d, n=%d,  2a=%g',nT, n, sqrt(dva)/pi); 
   txt  = {'1 yel  Хг<T Xд^2=Xг^2-T^2<0 => In,Kn' ...
           '2 cyan Хг>T Xд^2>0          => Jn,Yn' ...
           '3 red  Хг>V => Х.ф-ция  не определена'};
   Gfig = gcf;
   fig1 = figure('Name',tit1);              
   SX1  = X1(1);      SX9 = X1(end); 
   V    = sqrt(V2);
    
   fill( [L1 L2 L2 L1], [SX1 SX1 SX9 SX9], 'w')
   hold       
   T9 = T(end);
   V1 = V(1);
   fill( [L1 L2 L1],    [T T9],    'y')
   fill( [L1 L2 L2 L1], [T V1 V1], 'c');
   fill( [L1 L2 L2],    [V V1],    'r');
   if SX1 > T9, fill( [L1 L1 L2 L2], [SX1 T9  T9  SX1],'w'); end
   if SX9 < V1, fill( [L1 L1 L2 L2], [V1  SX9 SX9 V1 ],'w'); end
   plot( [L1 L2],[T V]) 
   titlab( txt,{'\lambda' 'T,V'})
   prib( 'Далее' ) 
   T1  = T(1);
   Lob = [1.1*L1  1.2*L1];
   Xob = [1.2*SX1  0.9*T1];
         
   figure(fig1)
   text( Lob(io), Xob(io), num2str(io),'FontSize',14,'color','k')  
   tit2 = sprintf('%s cетка %dx2', tit1, psX(3));
   while true
      me = menu('Выбрать график',...
           'Поверхность','0-Уровни','Каркас1','Каркас2',...
           'контуры','Уровни+марк','Выход');
      figure(Gfig)
      Lm = [L1(edX,1) L2(edX,1)];    % qX*2 - м-ца
      if     me==1, surfc   ( Lm, Xm, Z)
      elseif me==2, contour ( Lm, Xm, Z, [0 0] )
      elseif me==3, meshc   ( Lm, Xm, Z)  
      elseif me==4, meshz   ( Lm, Xm, Z)
      elseif me==5, contour3( Lm, Xm, Z)
      elseif me==6, [cHF,hHF] = contour( Lm,Xm,Z);  clabel(cHF,hHF);
      else   break
      end
      titlab(tit2, {'L','X'});
   end
   delete(fig1);
