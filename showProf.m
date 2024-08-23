%_______ Профили ПП + профили состава ____________________________
function showProf( QS, KZ, LZ, pvZ, PGB, sost, KRUP ) 
% Показ ПП без состава( sost=0 ) в последней версии не исп.
% => всегда sost=1
global YLimP1 
SL = [LZ 100];
SL = inpN('Задать сетку L и размер графика', SL,...
     {'\lambda_L' '\lambda_R' 'к-во' }, [5 3 5],...
     [LZ; LZ; 5 1000], 3, 'I(1)<=I(2)', NaN);

L = setK(SL(1:3)); 
YLimP1 = []; 
for i = 1:QS
   % if i == 3, prib('Переход к 3 слою'); end
   showProfsl( QS, KZ, L, pvZ, PGB, sost, '', i, KRUP );
end

%______________________________________________________________________
function showProfsl( QS, KZ, L, pvZ, PGB, sost, T, sl, KRUP )
global YLimP1 YLimP2 YTickP1 YTickP2
global ScreenSize
global eKZ
% sl <= QS
% sost = (0)1 - (не) показ состав
% KZ-матр к-тов Зельм
% pvZ-№№ пар строк из eKZ, на к-х основана KZ

if all( KZ(:, sl ) == 0)
   prie('Профиль не задан в слое %g',sl);  return
end

% sls     = [1 2 1];
% modsl   = sls(sl);
[ps vs] = pvZ{:,sl};
L2 = L.^2;
nsl     = sqrt(n_2kZ(KZ(:,sl), L2));
tit = [sprintf('n%g. Ge=%g%%, B=%g%%.  ',sl,PGB(:,sl))...
   'Cтроки: ' ps '; веса: ' vs ...
   sprintf('\n%5s%13s%13s%13s%13s%13s\n','A1','A2','A3','L1','L2','L3')...
   sprintf('%9.5f',KZ(:,sl)) ];

YLimE = isempty(YLimP1);
if sost == 0
   if KRUP, subplot( 1, 1, 1 );
   else     subplot( 1,QS,sl ); end
   
   plot(L,nsl,'r');
   if YLimE, YLimP1  = get(gca,'YLim');
             YTickP1 = get(gca,'YTick');
   else      set(gca,'YLim',YLimP1,'YTick',YTickP1);
   end
   
   title(tit,'FontSize',8);
   xlabel(['\lambda ' T]);   grid on 
else
   p    = str2num(ps);      
   rp   = size(p,1);             %v=0.01*str2num(vs);
   spGB = 0.01*PGB(:,sl); 
   pG   = spGB(1);  
   pB   = spGB(2);
   nQu  = sqrt(n_2kZ(eKZ(3:end,1), L2));
   np   = zeros(length(L),rp);   %np(lL,k)=пок прел (на L) k-й пары строк
   dp   = np; 
   
   for k = 1:rp
      Tk = p(k,1);
      if Tk == p(k,2),   np(:,k) = sqrt(n_2kZ(eKZ(3:end,Tk), L2));
      else
         Tk = p(k,:);    
         GB = 0.01*eKZ(1:2,Tk);
         f  = eKZ(3:end,Tk)-eKZ(3:end,1)*(1-sum(GB));
         np(:,k) = sqrt(n_2kZ((1-pG-pB)*eKZ(3:end,1)+(f/GB)*spGB, L2));
      end
   end
     
   for k = 1:rp, dp(:,k) = nQu-np(:,k);  end 
   
   if KRUP, fig = figure('Position', ScreenSize, 'MenuBar','none',...
                  'Name',sprintf('%d-й слой: Профили ПП и состава',sl));
            subplot(2,1,1);  
   else     subplot(2,QS,sl);
   end

   [AX,H1,H2] = plotyy( L, [nQu nsl np],  L, [nQu-nsl dp]);
   if YLimE, YLimP1  = get(gca,'YLim');
             YTickP1 = get(gca,'YTick');
   else      set(gca,'YLim',YLimP1,'YTick',YTickP1); 
   end
      
   if     KRUP,     set([get(AX(1),'Ylab') get(AX(2),'Ylab') ],{'Str'},...
                       {'Кварц, слой, пары';'Кварц-слой, Кварц-пары'})
   elseif sl == 1,  set( get(AX(1),'Ylab'),'Str','ПП слоя и пар') 
   elseif sl == QS, set( get(AX(2),'Ylab'),'Str','Кварц-слой, Кварц-пара')
   end
   
   title(tit,'FontSize',8);
   xlabel(['\lambda ' T]); grid on
  
   v    = str2num(vs);           
   pss  = num2str(p);
   Snsl = ['n' num2str(sl)];    
   Le2(1,:) = sprintf('Qu-%6s',Snsl);
  
   for k = 1:rp
     pp(k,:)    = sprintf('%6s, %3s', pss(k,:), num2str(v(k)));
     Le2(k+1,:) = sprintf('Qu-%6s',pss(k,:));
   end

   Le1 = char('Qu',Snsl,pp);
   legend(H1,Le1,3); legend(H2,Le2,4);
   set(H2 ,'LineStyle',':');
  
   no  = reshape(p',2*rp,1); 
   nos = num2str(no);
   ii  = 0;
   for k = 1:2*rp
      if k == 1 || all(no(1:k-1) ~= no(k))
         ii = ii+1;
         nZ(:,ii)  = sqrt( n_2kZ(eKZ(3:end,no(k)), L2) );
         dZ(:,ii)  = nQu-nZ(:,ii);
         Le3(ii,:) = sprintf('%2s',nos(k,:));
         Le4(ii,:) = ['Qu-' Le3(ii,:)];
      end
   end
  
   if exist('nZ','var')
      if KRUP, subplot(2,1,2);
      else     subplot(2,QS,sl+QS); end  

      [AX,H3,H4] = plotyy(L,[nQu nZ],L,dZ);
      if YLimE, YLimP2  = get(gca,'YLim');
                YTickP2 = get(gca,'YTick');
      else      set(gca,'YLim',YLimP2,'YTick',YTickP2); 
      end
    
      if   KRUP,      set([get(AX(1),'Ylab') get(AX(2),'Ylab')],...
                      {'Str'}, {'Кварц, эл-ты пары';'Кварц-эл-ты пары'})
      elseif sl == 1, set( get(AX(1),'Ylab'), 'Str', 'Кварц, эл-ты пары')
      elseif sl ==QS, set( get(AX(2),'Ylab'), 'Str', 'Кварц-эл-ты пары')
      end
      legend(H3,char('Qu',Le3),3);  
      legend(H4,Le4,4);
      set(H4 ,'LineStyle',':');
      xlabel(['\lambda ' T]); grid on     
   end
   if KRUP && menu('График','Оставить','Убрать') == 2, delete(fig); end
end 

