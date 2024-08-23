% ___________ % ��� KZ ��� �������� ���� ����� eKZ__________________
function [pvZ KZ nT] = KoZLiC( QS,KZ,LZ, pvZ, PGB)
switch menu('���������� �-��� ���������',...
    '����� �� ���� ����� �� ������ ���.��������: 100% GeO2 � B2O3',...
    '�������� �� ������ ���.���� ����.�����', ...
    '�����')
case 1
   [pvZ KZ] = KZ100( QS, PGB ); %��� �-��� �����  ���������
   nT = nTSV1( QS, KZ, LZ );
   if ischar(nT),  pvZ = ''; return,end
   if MEN('','�������� �������'), showProf( QS,KZ,LZ, pvZ, PGB, 1,0); end

case 2 
    poF = '�� ��������';  
    poK = '�� �������';
    nns = 1:QS;   
    Us  = sprintf('length(I)<=%g', QS);        
    T2  = ['����� ������� �������� �� ���� �����\n'...
           '������� ����� �������������� ���������'];
    fir = true; 
    while true
       if fir,  fir = false;
          T = '���.����.���������\n1-� ��� - ��� ���� �����';
          D = '(�� ��)';                     
       else
          T = '���.�.�����\n��������� �� �����';
          D = '';                  
          nns = inpRI('������ ���������� ����',nns,'nn',[1 QS],Us);
          if isempty(nns), break,end
       end
          
       for sl = nns
          T1 = [T '\n' sprintf('%g-����', sl)];
          pvZsl = pvZ(:,sl); 
          PGBsl = PGB(:,sl);
          switch MEN( T1, [poF D], poK)
          case 0
             if ~isempty(D)
                 [Z pv] = inpKZ( QS,sl, pvZsl, PGBsl, poF, 4,7,9);
                 poFK   = poF; 
             end                    
          case 1
              [Z pv] = inpKZ( QS, sl, pvZsl, PGBsl, poF, 4,7,9);    
              poFK   = poF;                      
          case 2
              [Z pv] = inpKZ( QS, sl, pvZsl, PGBsl, poK, 10, 14, 17);
              poFK   = poK;  
          end
                  
          if ischar(Z),  prie(Z);
          else
             KZ (:,sl) = Z;
             pvZ(:,sl) = pv;
             L = setK([LZ 100]);  
             showProfsl( QS,KZ,L, pvZ, PGB, 1, poFK, sl, 1);
          end
       end  

       if ~MEN( T2, '��������������')
          nT = nTSV1( QS, KZ, LZ );
          if ischar(nT),   return,end
       end
    end
    
case 3, nT = '����� �� ��� �-��� ���������';  
end

% ________%��� �-��� ����� KZ �� ������ 100% Ge � �_______________
function [pvZ KZ] = KZ100( QS, PGB) 
global  eKZ 
pvZ = cell(2,QS); 
for i = 1:QS,   pvZ(:,i) = {'2 3';'100'}; end
KZ = 0.01*( eKZ(3:8,1)*(100.0-PGB(1,:)-PGB(2,:)) +eKZ(3:8,2:3)*PGB);

% ____________% ���� �����. ��������� __________________________________
function [Zsl pvZsl] = inpKZ( QS, sl, pvZsl, PGBsl, t, N1,N2,N3) 
global  eKZ          
if sl <= QS  &&  all(PGBsl) == 0
   Zsl = eKZ(3:end,1); return,end

pv0 = pvZsl;
               %�-�� eKZ, ����-� ��������
bZ = {{sprintf('%s\n\n������ �����:  ',eKZ_t)},...
      {'������ ����: if pass, p1=...=pN, else p1+...+pN=100'}};
  
d0  = sprintf('%d %d;...',N1,N2,N1,N3,N2,N3,N3-1,N3);  
d0(end-3:end) = [];
if isempty(pv0{1}),  pv0 = {d0;''};  end

if sl <= QS,  tit = sprintf('%d ����. �-�� �����-%s',sl,t);
else          tit = '������� �-��� ����. ��� 100%B'; end

pv = cellfun( @str2num, pv0, 'UniformOutput', false);
if isempty(pv)
   Zsl = 'inpKZ: ������ ������ pv(����,����) �� ���������';
   return
end

while true
   pv = inpU( tit, pv, bZ, {50 50}, {[1 17];[0 100]});
   if ischar(pv), Zsl = ['inpKZ: ' pv]; return,end
   
   [p,v]   = pv{:}; % - p-���� �������, v-���� ����� � �� p ������� eKZ
   [rp,cp] = size(p);
   mi      = min(min(p));
   if cp~=2 || 3<mi && mi<N1 || max(max(p))>N3,  prie(...
      ['   �.����:\n1) �� �������� ������, ����������� ������ ";"\n'...
      '   ����., �-�� �� ���� ���� ��� ����� 1, 4 � 5, 8 - 1 4;5 8\n'...
      '   �� ���� k-� ��� - k k (�����, ���� %Ge=eKZ(1,k) � %B=eKZ(2,k)'...
      '\n2) %d<=�������<=%d'],N1,N3);  
      continue
   end

   if rp~=1 && (~isempty(v) && (sum(v)~=100 || rp~=length(v)))
      prie(['�/����:\n1) �-�� �����=�-�� ���\n'...
      '2) ���� ���� ������, �� �� �����=100']); 
      continue
   end
   break
end

if isempty(v) || rp==1,   v = 100.0*ones(1,rp)/rp; end
pvZsl = {matstr(p);  matstr(v)};    
Zsl = KZsl( QS, sl, pvZsl, PGBsl);

%________������. �-�� ����� � ����. ������ �����, ���� ';'_______
function s = matstr(m)
if isempty(m), s = '';
else  r = size(m,1);     s = num2str(m(1,:));
  if  r>1, for i = 2:r,  s = [s ';' num2str(m(i,:))]; end,end
end

%____________% ��� �-�� ����� ��� ���� sl ____________________________
function Zsl = KZsl( QS, sl, pvZsl, PGBsl) 
% if sl = QS+1, Z ��� ��� ���� �2�3
global eKZ 
Zsl  = zeros(6,1);
[pG,pB,ns,v,rp] = infProf( QS, sl, pvZsl, PGBsl);
  
for k = 1:rp
   T = ns(k,1);    % Two strings
   if T ~= ns(k,2), T = ns(k,1:2); end
   GB   = 0.01*eKZ(1:2,T);
   f    = eKZ(3:8,T)-eKZ(3:8,1)*(1-sum(GB));
   isZk = false;
  
   if length(T) == 1,  isZk = true;
      if sl <= QS
         if pG==GB(1) && pB==GB(2),  Zk = eKZ(3:8,T);
         elseif pG==0 && GB(1)==0,   Zk = (1-pB)*eKZ(3:8,1)+pB*f/GB(2);
         elseif pB==0 && GB(2)==0,   Zk = (1-pG)*eKZ(3:8,1)+pG*f/GB(1); 
         else Zsl = sprintf('���� %d\n������ %g) %g, %g �� ����� G=%g B=%g',...
                    sl,T,GB,pG,pB);  return
         end
           
      else        % sl=QS+1 - ����� �-�� ��� 100% B2O3
         if GB(1) == 0,  Zk = f/GB(2);
         else  Zsl = sprintf('���� %d\n������ %g) %g %g �� ����� 100%%B',...
                   sl,T,GB);  return
         end
      end
   elseif det(GB) == 0
      Zsl = sprintf('���� %d\n������ %g %g\n������.�-��=\n%g %g\n%g %g',...
          sl,T,GB');     return
   else Z100 = f/GB;
   end
  
   if ~isZk
      if sl <= QS,  Zk = (1-pG-pB)*eKZ(3:8,1)+Z100*[pG;pB];
      else          Zk = Z100(:,2); end
   end
   Zsl = Zsl+v(k)*Zk; 
end

%_________ ���������� � ������� _____________________________________
function [pG, pB, ns, v, rp] = infProf( QS, sl, pvZsl, PGBsl)
% pG=%Ge,pB=%Bor, ns-���� � ����� eKZ, v-�� ����, rp=rows q-ty of ns
if sl <= QS
   spGB = 0.01*PGBsl;            %PGB(:,sl);
   pG = spGB(1);  pB = spGB(2);
else
   pG = NaN;      pB = NaN;
end

[ps,vs] = pvZsl{:};
ns = str2num(ps);   v = 0.01*str2num(vs);   rp = size(ns,1);

% ______ ��� �� � ���� __________________________________________
function nT = nTSV1( QS, KZ, LZ )
% nT      = � ���� �������
% TSV =  {'1. n1 >  n2 >  n3',    '3. n1 >  n3 >= n2',
%         '2. n2 >= n1 >  n3',    '4. n2 >= n3 >= n1'}
K    = 40; 
L    = setK([LZ K]);
L_2  = L.^2; 
n1_2 = n_2kZ( KZ(:,1), L_2 );  % n^2 � 1 ���� 
n2_2 = n_2kZ( KZ(:,2), L_2 );

if QS == 2                         % nT = 5, �-�� iNA(nT)=[1 2]
   if n1_2(K) > n2_2(K),  nT = 5;  % � vhea{:,nT}=�-���� ��� 2-��
   else                   nT = 'n1_2 < n2_2';   end 
else 
   n3_2 = n_2kZ( KZ(:,3), L_2 ); 
   if n1_2(K) > n2_2(K)
      if n2_2(K) > n3_2(K)      
         if   any(    n1_2 > n2_2 & n2_2 > n3_2),  nT = 1;
         else nT ='1. n1_2 > n2_2 > n3_2'; end
      else  % n2_2 <= n3_2
         if   any(    n1_2 > n3_2 & n3_2 > n2_2),  nT = 3;
         else nT ='3. n1_2 > n3_2 = n2_2'; end
      end
   else     % n1_2 <= n2_2
      if n1_2(K) > n3_2(K)
         if   any(    n2_2 > n1_2 & n1_2 > n3_2),  nT = 2; 
         else nT ='2. n2_2 > n1_2 > n3_2'; end
      else  % n1_2 <= n3_2
         if   any(    n2_2 > n3_2 & n3_2 > n1_2),  nT = 4;  
         else nT ='4. n2_2 > n3_2 > n1_2'; end
      end
   end
end
 
% ______ ��� �� ��� ���� ___________________________
function [nT NA2] = nTSV0( pn2_2, ee)
% NA - Number of Aperture �� ����� L 
% pn2_2 = pn2^2 - ������� �� �� 2-� ����
% ee =  e1     ��� 2-��
% ee = [e1 e3] ��� 3-��
% TSV =  {'1. n1 >  n2 >  n3',    '3. n1 >  n3 >= n2,
%         '2. n2 >= n1 >  n3',    '4. n2 >= n3 >= n1'}
pn1_2 = pn2_2*ee(1);    
if size(ee,2) == 1   % 2-��
   if nargout == 2
      if pn1_2 > pn2_2,  nT = 1; else  nT = 2; end
   end
   NA2 = abs(pn1_2-pn2_2);
else                 % 3-��
   pn3_2 = pn2_2*ee(2); 
   if pn1_2 > pn2_2
      if pn2_2 > pn3_2
         NA2 = pn1_2-pn3_2;  
         if nargout == 2, nT = 1; end              
      else
         NA2 = pn1_2-pn2_2;
         if nargout == 2, nT = 3; end
      end  % pn2 <= pn3       
   else                                              % pn1 <= pn2        
      if pn1_2 > pn3_2
         NA2 = pn2_2-pn3_2;  
         if nargout == 2, nT = 2; end     
      else
         NA2 = pn2_2-pn1_2;                          % pn1 <= pn3
         if nargout == 2, nT = 4; end
      end
   end
end 
