%________����� �������� �������________________________________________
function showProfBas( pvB, LZ, NN )
% pv(�-�� � ����) ����� ����� ������ ��� ���� B203, ������� ������ �-� pvB
% ��� ����: 1-� Si2O3 � 2-� GeO3 ���-�� ����������,=> pv ���
% NN - �� ��������� �-��� ���������
% k=1,   1-� ������ eKZ: SiO2,   pvB �� ���
% k=2,   2-� ������ eKZ: GeO2,   pvB �� ���
% k=3,   3-� ������ eKZ: B2O3
global eKZ 
SL = [LZ 100];
SL = inpN('������� L', SL,...
        {'\lambda_A' '\lambda_B' 'K'}, [5 3 5],...
        [LZ; LZ; 5 1000], 3, 'I(1)<=I(2)', NaN);
L  = setK(SL);
L2 = L.^2;                     lenL = length(L); 
n2 = ones(length(NN),lenL);    leg  = {'SiO2','GeO2','B2O3'};
i  = 0;

for k = NN
   i = i+1;  
   n2(i,:) = n_2kZ( L2, eKZ(3:end,k) );
   subplot(2,2,k);   
   plot(L, sqrt(n2(i,:)));
  
   if k == 3
      pv = sprintf(' ������: %s, ����: %s\n',pvB{1}, pvB{2});
      t1 = sprintf('�.����� ��� ����  %s %s%2s',   leg{k}, pv);
   else   
      t1 = sprintf('�.����� ��� ����  %s \n%2s%12s%15s%16s%17s%17s\n',...
           leg{k},'A1','A2','A3','L1','L2','L3');     
   end

  t2 = sprintf('%11.7f', eKZ(3:end,k));
  title(sprintf([t1 t2]),'FontSize',8);
  ylabel('n'); xlabel('\lambda'); grid on
end
subplot(2,2,2);    plot([],[])
