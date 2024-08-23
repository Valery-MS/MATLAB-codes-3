% СТАТИСТИКА в fZero __________________________________________________
function statFZ
global mm  stat qHF qL ETim

if ~isempty(stat) 
   su  = sum(stat([3 7 12 17 21 26],:));
   suf = sum(su);
   L1 = 'LT io=1';  L2 = 'LT io=2';  R1 = 'RT io=1';  R2 = 'RT io=2';
   N  = 'io   K   f   s   m'; 
   K  = 'qR    qHF    Sf     %';
   T  = [mm(1):mm(end); stat; su; 100*su./stat(30,:)];

   %tit = ' L  LT1   LT2     R RT1   RT2';
   f  = ['%02d%6d%4d%4d%4d%4d%8d%4d%4d%4d%8d%7d%4d%4d%4d%8d%7d' ...
         '%4d%4d%4d%8d%4d%4d%4d%8d%8d%4d%4d%4d %9d%8d%6d%7.0f\n'];
   s1 = sprintf(f,T(:,1));
   s2 = sprintf(f,T(:,2:end));   
   c  = clock;
   s  = sprintf(['%2.0f:%02.0f   %2.0f.%02.0f.%4.0f   Elapsed Time=%g\n\n' ...
   'qHF = %d         Sf = %d          Sf/qHF = %2.0f%%        qL = %d\n\n'...            
   '%20s%31s%25s%25s%27s%27s\n'... % L1 L2 R1 R2
   '%s' ...                        % s1
   ' m %22s%34s%36s%55s%54s\n' ... % N K
   '%s\n' ...                      % s2
'K - к-во обрашений к ФПК(ф-ции поиска КИН)     qHF - общее к-во обрашений к HF\n'...
'f  - к-во обрашений к х.ф HF во всех ФПК            Sf  - Сумма f по Solv для данного m\n' ...
's = f/K - средн к-во обрашений к HF в ФПК          io =1,x<T else 2, индекс области опр\n' ... 
'm - max количество обрашений к HF в ФПК         i   - количество точек до смены io\n'], ...
      c([4 5 3 2 1]), ETim, qHF,suf,100*suf/qHF,qL, 'L',L1,L2,'R',R1,R2,s1,...
      N,'i','io','i',K,s2);
     
   hf = figure('Name','СТАТИСТИКА', 'NumberTitle','off',  'MenuBar','none',...
          'Units','pixels', 'Position',[200 100 700 480]);
        
   uicontrol(hf,'String',s, 'Style','text', 'Units','pixels', 'FontSize',8,...
        'BackgroundColor',get(hf,'Color'),  'HorizontalAlignment','left',...
        'Position',[15 1 700 470]);
end