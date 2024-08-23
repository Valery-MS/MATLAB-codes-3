%________Показ Профилей Базовых________________________________________
function showProfBas( pvB, LZ, NN )
% pv(п-ры и веса) имеет смысл только для базы B203, поэтому введен п-р pvB
% ост базы: 1-я Si2O3 и 2-я GeO3 опр-ны однозначно,=> pv нет
% NN - №№ столобцов к-тов Зельмаера
% k=1,   1-я строка eKZ: SiO2,   pvB не исп
% k=2,   2-я строка eKZ: GeO2,   pvB не исп
% k=3,   3-я строка eKZ: B2O3
global eKZ 
SL = [LZ 100];
SL = inpN('Границы L', SL,...
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
      pv = sprintf(' строки: %s, веса: %s\n',pvB{1}, pvB{2});
      t1 = sprintf('К.Зельм для базы  %s %s%2s',   leg{k}, pv);
   else   
      t1 = sprintf('К.Зельм для базы  %s \n%2s%12s%15s%16s%17s%17s\n',...
           leg{k},'A1','A2','A3','L1','L2','L3');     
   end

  t2 = sprintf('%11.7f', eKZ(3:end,k));
  title(sprintf([t1 t2]),'FontSize',8);
  ylabel('n'); xlabel('\lambda'); grid on
end
subplot(2,2,2);    plot([],[])
