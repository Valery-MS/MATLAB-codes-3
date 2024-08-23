
function varargout = SvetoVod(varargin)
% Last Modified by GUIDE v2.5 23-Nov-2010 14:31:49
%                 Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SvetoVod_OpeningFcn,...
                   'gui_OutputFcn',  @SvetoVod_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
   [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
   gui_mainfcn(gui_State, varargin{:});
end

%                 End initialization code - DO NOT EDIT
%_________________Executes just before SvetoVod is made visible________
function SvetoVod_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SvetoVod (see VARARGIN)
handles.output = hObject;%Choose default command line output for SvetoVod
guidata(hObject, handles);% Update handles structure
% UIWAIT makes SvetoVod wait for user response (see UIRESUME)
% uiwait(handles.SvetoV);
global CALC ...   % массив указателей на кнопки вычислений
       RVDh  RVNh  RVSh  RVbh  RVth  ...   
       RVh   RVon     % массив указателей на объекты панели RV 
global clr1 clr2 clr3 ScreenSize

CALC = [handles.zagr ...    % 1
        handles.B2O3 ...    % 2
        handles.KZ   ...    % 3        handles.e1e3 ...    % 4
        handles.vGX  ...    % 4
        handles.TDG  ...    % 5
        handles.DVAX ...    % 6
        handles.GDH  ...    % 7
        handles.SUI ];      % 8
    
RVDh = [handles.GrS1 ...     % 1
        handles.ProvT ...    % 2
        handles.NUGr  ...    % 3
        handles.Otl2a ...    % 4
        handles.Lev2a ...    % 5
        handles.q2a ];       % 6

RVNh = [handles.MZ    ...  % 7
        handles.GLU ]; ... % 8
             
RVSh = [handles.ILK   ... % 8
        handles.OtlS ];   % 9
          
RVbh = [handles.OK    ...  % 11  
        handles.Canc ];    % 12 
         
RVth = [handles.textq2a ... % 13  
        handles.textGLU ];  % 14  

RVh = [RVDh  RVNh  RVSh  RVbh RVth];
RVon = [];    
clr1 = [ 1    0.8  0.8 ];   % light red
clr2 = [ 0.8  1    0.8 ];   % light green
clr3 = [ 0.8  0.8  1   ];   % light blue

ScreenSize = get(0,'ScreenSize');

%Units = get( hObject, 'Units');
%%P = get( hObject, 'Pos');
%set(hObject, 'Position',P0);  % было [0,32,-30,-80] 
%set(hObject,'Units',Units);

h_on = findobj( 'Enable', 'on' );
set( hObject, 'UserData', h_on );
set( h_on, 'Enable', 'off' );
set( handles.zagr, 'Enable', 'on', 'BackgroundColor', clr2);

%____________Outputs from this function are returned to the command line
function varargout = SvetoVod_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;

%_______________Executes when user attempts to close SvetoV______________
function SvetoV_CloseRequestFcn(hObject, ~, ~)
% hObject        handle to SvetoV (see GCBO)
Exit(hObject)  % Hint: delete(hObject) closes the figure

% ______ Executes on selection change in zagr.
function zagr_Callback(hObject, ~, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns zagr contents as cell array
%        contents{get(hObject,'Value')} returns selected item from zagr
global CALC QS
global clr2 teKZ tKZ tGX eew

zag  = {@zagSV1 @zagSV1 @zagSV0};
Last = [1 0 0];
pop  = get( hObject, 'Value');

%hh = findobj( 'Enable', 'on', '-or', 'Enable', 'off');
h_on = [get( handles.SvetoV,'UserData'); hObject];
set( h_on, 'Enable', 'off');

AV = zag{pop}( Last(pop), handles );

set( h_on,    'Enable', 'on');  
if ischar(AV),  prie(AV);  return,end

if QS == 2
   set( [ handles.textc;     handles.c; ...
          handles.textXnXkK; handles.XnXkK; ...
          handles.textHgru;  handles.Hgru; ...
          handles.textc_s;   handles.c_s ], 'Enable', 'off');
end

set( CALC, 'Enable', 'on',  'BackgroundColor', clr2)
     % ф-ции перевода данных в текст
teKZ = eKZ_t;
tKZ  = KZ_t;
tGX  = GX_t;
eew  = v_eew;

% ______ Executes during object creation, after setting all properties.
function zagr_CreateFcn(hObject, ~, ~)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% _______________________________________________________________________
function AV = zagSV1( Last , handles)
% Di=1/0 - расчет характеристик с/без учета учета дисперсии
% QS     - к-во слоев
% pvB    - {Пары №№ строк таблицы eKZ, Веса этих пар} при задании для 
%          100% B203-слоя к-тов Зельмаера лиейной комбинацией пар строк, 
%          содержащих B2O3 
% pvBS   - последний Составной pvB(на основе лин.комб к.Зельмаера)
% pvZ    - Пары №№ строк и Веса этих пар для каждого слоя СВ
% KZBU   - к-ты Зельмаера для 100% B203-слоя по умолчанию
% KZB    - к-ты Зельмаера для 100% B203-слоя текущие
% PGB    - проценты Ge и Bor в слоях СВ
% LZ     - граничные значения L для представления Зельмаера
% hL     - шаг по L
% KZ     - к-ты Зельмаера для выбранных PGB, выч-ся по pvZ
% nT     - № типа СВ
% n      - порядок моды n
% Lw     - Lambda work, рабочая длина волны (1.55, 1.06)
% c      = a/b 
% NNM    - номера мод
% c_s    = [cGR suz]
%    cGR - сГРаничное: 0.1-0.5; для ooHF3,ooHFot,ooHFfa
%          исп: if c >= cGR, B = G; else B = stup(...);  end 
%    suz - к-т сужения ин-ла 0-особенности: 0.01-1: 
%          Сужаются узкие(0-особенности) области по х: 
%          было сx1 < Ieq1n, cтало cx1 < Iepsn = suz*Ieq1n
%          Аналогично: suz*(Ieq1n,Yeq1n,Keq1n)
% vGX     - границы х.числа Х в волноведущем слое(с макс пп)
% mm     - границы азимутальных чисел m
% qX     - к-во значений Х в сетке SX в DVAX\UR0
% DxHF   - производная х.ф. HF в НЕ-нуле 
% n_290  - qL*2-м-ца:  пп n^2 для 2 слоев: c max и min пп
% dvaX   - вых м-ца DVAX. В кажд ст-це: m,L9,q,Lot,dva, x1,...,xq
% dvaX1  - вых c-ц  DVAX% 
% XnXkK  - [Xn Xk K] - п-ры К-сетки для Х
% Hgru   - шаг Нгрубое для построения графика на всем ин-ле(не поиск корня) 
% RV     - вектор Режим вычислений
%                  в DVAX
%  RVD(1) = 1: строить графики S1(2a) независимо
%  RVD(2) = 1: если выбрано RVD(1)=1, то проверять точность графика S1(2a)
%  RVD(3) = 1: если выбрано RVD(1)=0 и 2а не найдено, то не удалять графики
%  RVD(4) = 1: отлад 2а-реж: если Х(5*1) не найден, то
%             менять п-ры сеток, не переходя к след 2а
%  RVD(5) = левое 2а из двух, при к-х S1(2a)=0 (только для m=1)
%  RVD(6) = qdva   - к-во значений 2а
%                  в NP0
%  RVN(1) = 3(умолч) - глубина сеточной матрешки
%  RVN(2) = 1: при малом захвате длины Lw не искать Х(5*1) для данного 2а,
%             а перейти к поиску Х(5*1) для след 2а
%                  в Solv
%  RVS(1) = 1: в fzero нач.пр х0=числу;  RVS(1)=0: х0=ИЛК(ин-л лок корня)
%  RVS(2) = 1: вкл отлад сообщ в Solv

global eKZ  TSV   UsPath stat
global QS   pvB   pvBS pvZ   KZB   PGB ...
       LZ   hL    KZ   nT    n     Lw c NNM ...
       c_s  GX    mm   qX    RVD RVN RVS  ...
       DxHF n_290 dvaX dvaX1 XnXkK Hgru 
global RVDn RVNn RVSn  RVh m_max mm_max

AV = 0; 
UsPath = 'D:\MyDoc\MATLAB\';
stat   = zeros(7,1);
daSVL = [UsPath 'daSV\Last'];
if Last        %  З А Г Р У З К А  рез-тов  последней сессии
   try   load( daSVL);        
   catch ME, AV = ME.message; end
else           %  З А Г Р У З К А  рез-тов  из базы
   CurFold = chdir; 
   chdir([UsPath 'daSV']) 
   while true            
      try   fn = uigetfile('*.mat');                           
      catch ME, prib(ME.message);  continue,end
         
      if fn == 0
         AV = 'Выход без выбора файла';  break
      else               
         clear QS 
         try load (fn, '-mat');
             if exist('QS','var'),   break
             else  prie('Загружен не тот файл'); end
         catch ME, AV = ME.message;
             break
         end           
      end     
   end 
   chdir(CurFold)
end

if ischar(AV),   return,end

if isempty(eKZ)
   try,  usTab;
   catch ME,  prib(ME.message); return,end
end

set( handles.PGB,  'Data',   num2cell(PGB') );
set( handles.LZh,  'String', sprintf('%g   %g   %g',LZ, hL) );
set( handles.Tip,  'String', TSV{nT})
set( handles.c,    'String', num2str(c) );

set( handles.Lw,   'String', num2str(Lw) );
set( handles.n,    'Value',  n );
set( handles.Moda, 'Value',  sum(NNM) );

set( handles.XnXkK,'String', sprintf('%g   %g   %g',XnXkK) );
set( handles.Hgru, 'String', num2str(Hgru) );
set( handles.c_s,  'String', num2str(c_s) );
set( handles.m_max,'Value',  m_max);

set( handles.m1,   {'String' 'Value'}, { mm_max(1:m_max) mm(1)} );
set( handles.m9,   {'String' 'Value'}, { mm_max(1:m_max) mm(2)} );
set( handles.qX,   'String', num2str(qX) );

iniRV( RVD, RVN, RVS )
RVDn = RVD; RVNn = RVD;  RVSn = RVS;

rm = dvaX(1,:);                 % рейндж аз чисел m
UTO = S123( QS, ...
            LZ,   hL,       KZ,   nT,  n, c, NNM,...
            c_s,  GX(rm,:), mm,    ...
            DxHF, n_290,    dvaX, dvaX1, RVS );  
if prich(UTO),  return,end
if UTO
    % вставить уточнения
end

% _________________________________________________________________
function statFZ
global   stat 
if ~isempty(stat) 
   pribz('',['            Статистика fzero\n',...
          'Для уточн x0 используются\n'...
          '                      EXT=1|3    EXT=2\n' ... 
          'абс.пог. APe  %8d      %8d\n'...
          'разность  hx  %8d      %8d\n'...
          'расст   V-х0е  %8d\n'...
          '                      ILK=0        ILK=1\n'...
          'к.корней     %8d      %8d\n'], stat); 
end

% _______________% Установка постоянных таблиц __________________________________________________
function usTab  
global  eKZ   KZBU  KZB  TFL  TSV  tabNOS
global  xRPI  xRPK  RPK  xPZ  iNAs
global  Ieq1  Yeq1 Keq1 nuliJ0 nuliJ1    % загрузка в след строках
global  mm_max  NePoks

load('Zeq1');   % содержит Ieq1 Yeq1 Keq1
load('nuliJ01');

mm_max = {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' '13' ...
         '14' '15' '16' '17' '18' '19' '20' '21' '22' '23' '24' '25'};  
NePoks = zeros(1,2);
iNAs = [1 3;  2 3;  1 2;  2 1];  % индексы апертуры для разных nT
TSV={'1) e1 > 1 > e3','2) 1 > e1 > e3','3) e1 > e3 > 1','4) 1 > e3 > e1'};
eKZ_tr = [...% 1с.-SiO2; 2c.-GeO2; 3c.-B2O3;
%Ge  Bor   A1         A2         A3         л1          л2          л3 
0    0   0.6961663  0.4079426  0.8974794  0.0684043   0.1162414  9.896161;...
100  0   0.80686642 0.71815848 0.85416831 0.068972606 0.15396605 11.841931;...
0    100 0.61       0.32       1.26       0.09        0.16       9.89;...
          % Флеминг: 4-9 стр
4.1  0   0.68671749 0.43481505 0.89656582 0.072675189 0.11514351 10.002398;...
7    0   0.68698290 0.44479505 0.79073512 0.078087582 0.11551840 10.436628;...
13.5 0   0.73454395 0.42710828 0.82103399 0.086976930 0.11195191 10.846540;...

0.1  5.4 0.69681388 0.40865177 0.89374039 0.070555513 0.11765660 9.8754801;...
4.03 9.7 0.70420420 0.41289413 0.95238253 0.067974973 0.12147738 9.6436219;...
9.1  7.7 0.72393884 0.41129541 0.79292034 0.085826532 0.10705260 9.3772959;...
          % Кобаяши: 10-17 строки
3.1  0   0.7028554  0.4146307  0.8974540  0.0727723   0.1143085  9.896161;...
3.5  0   0.7042038  0.4160032  0.9074049  0.0514415   0.1291600  9.896156;...
5.8  0   0.7088876  0.4206803  0.8956551  0.0609053   0.1254514  9.896162;...
7.9  0   0.7136824  0.4254807  0.8964226  0.0617167   0.1270814  9.896161;...

0    3   0.6935408  0.4052977  0.9111432  0.0717021   0.1256396  9.896154;...
0    3.5 0.6929642  0.4047468  0.9154064  0.0604843   0.1239609  9.896152;...
2.2  3.3 0.6993390  0.4111269  0.9035275  0.0617482   0.1242404  9.896158;...
3.3  9.2 0.6958807  0.4076588  0.9401093  0.0665654   0.1211422  9.896140];

eKZ  = eKZ_tr';      % Экспериментальные эталонные KZ

KZBU = eKZ(3:end,3); % задание к-тов Зельм. для 100% B2O3 по умолч
eKZ(3:end,3) = KZB;  % задание к-тов Зельм. для 100% B2O3 для последн вар-та

TFL = {...           % сообщения для Solv
'1. Реш найдено fzero',            '2. Найден КИН',...
'3. Резерв',                       '4. Корень д.б',...
'5. Решeние найдено SigI\f1=0',    '6. Решeние найдено SigI\f2=0',...
'7. Решeние найдено f1=0',         '8. Решeние найдено f2=0',...         
'9. Испр x0:перескок через корень','10. Испр x0: ',...
'11. Испр x0: CompF: f=Cmp',      '12. Испр x0: SigI:f1*f2>0:f1~f2',...
'13. Испр x0:SigI:f1*f2>0:f1<f2', '14. Испр x0:SigI:f1*f2>0:f1>=f2',...
'15. Испр x0: m=1',               '16. Испр x0: m>1',...
'17. Испр ILK: f=Cmp',            '18. Испр ILK: найд кор с др ветви',...
'19. Испр ILK: f=Nan,Inf,Singul', '20. НеНайдРеш: др ветвь',...
'21. НеНайдРеш: Соскок на EH',    '22. НеНайдРеш: f=Cmp',...
'23. НеНайдРеш: f=Nan,Inf,Singul','24. Не cработ fzero',...
'25. SigI: НеНайдРеш: f1*f2>0',   '26. Резерв',...
'27. SigIA:НеНайдРеш: f1*f2>0'    '28. НеНайдРеш: f=Cmp',...
'29. Повтор Соскока, EXT = 2'};

% Если x > xRPI, то полагаем Результ.Произведение In'/In = -1 для всех n
xRPI = 700.921793694445966593;
% Если x > xRPK(n), то полагаем Результ.Произведение Kn'/Kn = RPK(n) 
xRPK = [...
697.8733872133284 697.8741026498899 697.8762489493187 697.8798260808491 ...
697.8848339932074 697.8912726146153 697.8991418527960 697.9084415949798 ...
697.9191717079129 697.9313320378677 697.9449224106526 697.9599426316257 ...
697.9763924857089 697.9942717374029 698.0135801308051 698.0343173896276 ...
698.0564832172174 698.0800772965784 698.1050992903938 698.1315488410506 ];

RPK = [                -1.000717231216139067  -1.0007203059725837362 ...
-1.0007254295138855178 -1.0007326017078518943 -1.0007418223593625713 ...
-1.0007530912103874069 -1.0007664079400103893 -1.0007817721644596613 ...
-1.0007991834371435831 -1.0008186412486928252 -1.0008401450270084891 ...
-1.0008636941373162375 -1.0008892878822264299 -1.0009169255018002501 ...
-1.0009466061736218095 -1.0009783290128762161 -1.001012093072433591  ...
-1.001047897342939015  -1.0010857407529083909 -1.0011256221688301994 ];

tabNOS = [1 1;  -1 1;  0 1;  1 0;  -1 0;  0 0;  1 -1;  -1 -1;  0 -1];

% границы Потери Значимости для бесс ф-ций
% расч по ф-ле   xPZ(n) = n/2*(n!*1e-300)^(1/n)  см. ТСВ2, лист 39
% если х < xPZ(n), то  Jn(x) = 0,  Kn(x) = Inf
xPZ = [                 2.500000000000000e-301  1.000000000000000e-150 ...
2.163374355461140e-100  3.722419436408399e-075  5.669832888165093e-060 ...
8.001504826020036e-050  1.488810935826484e-042  4.366377770382750e-037 ...
8.020156654069166e-033  2.112726637866066e-029  1.352954556807377e-026 ...
2.995206924485201e-024  2.925770821381441e-022  1.501350898896931e-020 ...
4.600014893008183e-019  9.264336835424282e-018  1.320072130110231e-016 ...
1.409230424563003e-015  1.179293061900797e-014  8.021484175205879e-014 ];

%____________________________________________________________
function iniRV( RVD, RVN, RVS )
global RVDh RVNh  RVSh
set( RVDh(1), 'Value',  RVD(1) );
set( RVDh(2), 'Value',  RVD(2) );
set( RVDh(3), 'Value',  RVD(3) );
set( RVDh(4), 'Value',  RVD(4) );
set( RVDh(5), 'Value',  RVD(5) );
set( RVDh(6), 'String', num2str( RVD(6) ));

set( RVNh(1), 'Value',  RVN(1) );
set( RVNh(2), 'Value',  RVN(2)-2 );   % т.к. GLU = Value+2

set( RVSh(1), 'Value',  RVS(1) );
set( RVSh(2), 'Value',  RVS(2) );

%____________________________________________________________
function AV = zagSV0( ~, ~ )
% ~ = Last, handles - не исп
prib('Программа не написана')
AV = 0;

%___________ Задание структуры абстр слоя В2О3  _______________________
function B2O3_Callback(~, ~, ~)
global CALC eKZ   QS  KZBU  LZ    % read only
global pvB  pvBS KZB teKZ       % edit
global clr1 
h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

me = menu('Способ задания',...
          'По умолчанию',  ...
          'Вручную',  ...
          'На основе слоев с В2О3'); 
if me <= 1             % По умолчанию
   pvB = {'Default'; 'К.Зельм заданы по умолч'}; 
   Z = KZBU;
elseif me == 2         % Вручную
   Z = eKZ( 3:end, 3 );
   Z = inpN('Задать к.Зельм д/абстр слоя из 100% B2O3', Z, ...
       {'A1' 'A2' 'A3' 'L1' 'L2' 'L3'}, [4 5 6 6 6 6],...
       [0.3 0.9; 0.2 0.8; 0.5 1.3; 0.03 0.1; 0.05 0.3; 8 15],...
       'I(2)<I(1) && I(1)<I(3) && I(4)<I(5)');   
   if isnumeric(Z),   pvB = {'Handly'; 'К.Зельм заданы вручную'}; end    
else                   % На основе слоев с В2О3
   % msgbox(eKZ_t,'Коэффициенты Зельмаера'); 
   NePok('Пояснение к заданию базы В2О3', 4,...
     sprintf(['       В табл к-тов Зельмаера ' ...
     '7-я строка имеет  0.1%% Ge и 5.4%% B2O3,  ' ...
     '8-я строка - 4.03%% Ge и 9.7%% B2O3.\n' ...
     '    Задать базовый слой В2О3 на основе, например, строк '...
     '7 и 8 значит - вычислить к-ты Зельмаера некоего слоя такие, '...
     'что линейная комбинация двух базовых строк: 2-й (GeО2) и '...
     'вычисленной (В2О3) с процентами  0.1 и 5.4 дает 7-ю строку,'...
     'с процентами 4.03 и 9.7 - 8-ю.\n' ...
     '    Тогда лин. комбинация с процентами, не сильно ' ...
     'выходящими за диапазоны 0.1 - 4.03  и  5.4 - 9.7 даст ' ...
     'к.Зельмаера в районе линейной оболочки 7 и 8-й строк.']),...
     [600 400 300 280]);
          
   [Z pvB] = inpKZ( QS, QS+1, pvBS, [], '', 4,7,17);   
   if isnumeric(Z),  pvBS = pvB; end        
end


if ischar(Z)
   set( h_on, 'Enable', 'on'); 
   prie(Z);  return
end

if any( Z ~= KZB )
   KZB = Z; 
   eKZ(3:end,3) = Z;
   teKZ = eKZ_t;  
   showProfBas( pvB, LZ, 3); 
end
set( h_on, 'Enable', 'on');
set( CALC(4:8), 'Enable', 'off', 'BackgroundColor', clr1); 

% __________Коэф-ты Зельмаера -> txt _____________________________
function s = eKZ_t
global eKZ
f  = '    %7.3f %7.3f %7.3f %7.3f %7.3f  %7.3f';
f1 = ['\n %2.0f)  %6.0f    %6.0f' f];
f2 = ['\n %2.0f)  %6.2f    %6.2f' f];
f3 = ['\n%2.0f)  %6.2f    %6.2f' f];
f0 = ['    %GeO2  %B2O3     A1        A2       A3        '...
     'L1        L2         L3'];
s = [f0 sprintf('\n%60s','Базы: 1 - SiO2;  2 - GeO2;  3 - B2O3')];
s = [s sprintf(f1,[1:3; eKZ(:,1:3)])];
s = [s sprintf('\n%50s','Флеминг') sprintf(f2, [4: 9; eKZ(:,4:9)])];
s = [s sprintf('\n%50s','Кобаяши') sprintf(f3,[10:17; eKZ(:,10:17)])];

% ______ Executes when entered data in editable cell(s) in PGB ______
function PGB_CellEditCallback(hObject, eventD, ~)
%    eventdata  structure with the following fields (see UITABLE)
% : row and column indices of the cell(s) edited
% PreviousData: previous data for the cell(s) edited
% EditData: string(s) entered by the user
% NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
% Error: error string when failed to convert EditData to appropriate value for Data

global CALC QS clr1    % read only
global PGB  DxHF       % editable

CONT = get(hObject,'Data');   % КОНТЕЙНЕР, содержимое
PGBn = cell2mat( CONT )';
          
if    ~isempty( eventD.Error ),  ER = eventD.Error;  
elseif isnan( eventD.NewData ),  ER = 'Введено не число';                       i = 2;
elseif QS == 3 && all( PGBn(:,1) == PGBn(:,2) ) || ...
                  all( PGBn(:,1) == PGBn(:,3) ) || ...
                  all( PGBn(:,2) == PGBn(:,3) )
                                 ER = 'Два слоя одинаковы, т.е 2-сл СВ'; 
elseif any( sum(PGBn) > 100 ),   ER = 'Сумма %% превышает 100';
else                             ER = NaN;
end

if ischar(ER)
   I = eventD.Indices;
   CONT{ I(1), I(2)} = eventD.PreviousData;   
   prie(ER)
   set( hObject, 'Data', CONT );
   return
end

if any(any( PGB ~= PGBn ))
   PGB  = PGBn;
   DxHF = NaN;
   % отключаем все выч-кнопки после следующей
   set( CALC(4:8), 'Enable', 'off', 'BackgroundC', clr1); 
end

% _______ Executes when selected cell(s) is changed in PGB __________
function PGB_CellSelectionCallback(~, eventdata, ~)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% I = eventdata.Indices;

function LZh_Callback(hObject, ~, ~)
% Hints: get(hObject,'String') returns contents of LZh as text
%    str2double(get(hObject,'String')) returns contents of LZh as a double
global CALC  clr1  % read only
global LZ    hL    % edit

LZh = [LZ hL];
LZhn = str2num(get(hObject,'String'));
if  ProV3( hObject, LZh, LZhn, [0.5 4], [eps 1]), return,end

if any( LZh ~= LZhn )
   LZ = LZhn(1:2);  hL = LZhn(3);
   set( CALC(4:8), 'Enable', 'off', 'BackgroundColor', clr1);
end

% ______ Executes during object creation, after setting all properties.
function LZh_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ____________ Executes on button press in KZ.
function KZ_Callback( ~, ~, ~ )
global CALC QS  PGB LZ hL  iNAs    % read only
global pvZ  KZ  nT  n_290  tKZ  eew  % edit
global clr1 clr2 
h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

[pvZn KZn nTn] = KoZLiC( QS, pvZ, PGB, LZ, KZ );
set( h_on,    'Enable', 'on');

if ischar(nTn),  prie(nTn); return, end
pvZ = pvZn;  KZ = KZn;  nT = nTn;  

tKZ = KZ_t;
if QS == 3,  iNA = iNAs(nT,:); 
else         iNA = [1 2];  end

L_2   = setH( [LZ hL] )'.^2;
n_290 = n_2_2( L_2, KZ( 1:6, iNA));

[NA_2ma ima] = max(n_290(:,1)-n_290(:,2)); % max квадрата апертуры

n_2       = [NaN NaN NaN];
n_2(iNA)  = n_290(ima,:);
iost      = 6-iNA(1)-iNA(2);
n_2(iost) = n_2kZ( L_2(ima), KZ(1:6,iost));
 
eew = n_2([1 3]) / n_2(2); % e1, e3 в точках max апертуры

set( CALC(4),   'Enable', 'on', 'BackgroundColor',  clr2);
set( CALC(5:8), 'Enable', 'off','BackgroundColor',  clr1); 

% ________квадраты пп n^2 для 2 слоев с к-тами Z(:,1) и Z(:,2)____________
function  n_2s = n_2_2( L_2, Z)
n_2s = [ n_2kZ( L_2, Z(:,1))   n_2kZ( L_2, Z(:,2)) ];

%_______Number of Aperture(числовая апертура)^2  на сетке L
function na_2 = NA_2( L_2, Z)
% Z - 2 столбца к-тов Зельм из матрицы KZ, дающих max разность пп
na_2 = n_2kZ( L_2, Z(:,1)) - n_2kZ( L_2, Z(:,2));

% _______пп n^2 по к.Зельм ______________________________________________
% L_2 = L^2;       Z  - строка из 6 к-тов Зельм
function n_2 = n_2kZ( L_2, Z)
n_2=1+L_2.*(Z(1)./(L_2-Z(4)^2) + Z(2)./(L_2-Z(5)^2) + Z(3)./(L_2-Z(6)^2));

% ______  к-ты Зельмаера световода -> text _________________________
function tKZ = KZ_t
global QS KZ
sl  = 1:QS; %
tKZ=[sprintf('А/Ч %8s%13s%13s   /   %5s%12s%12s','A1','A2','A3','L1','L2','L3')...
     sprintf('\n%d сл: %7.5g  %7.5g  %7.5g  %7.5g  %7.5g  %7.5g',[sl; KZ])];

% ______ Печать таблицы к-тов Зельмаера _________________________
function KZ_ButtonDownFcn(hObject, eventdata, handles)
% If Enable == 'on', executes on mouse press in 5 pixel border.
% Otherwise, executes on mouse press in 5 pixel border or over KZ.
global tKZ
msgbox( tKZ, 'Коэффициенты Зельмаера' ); 

% ___________ % выч KZ как Линейной Комб строк eKZ__________________
function [pvZ KZ nT] = KoZLiC( QS, pvZ, PGB, LZ, KZ)
switch menu('Вычисление к-тов Зельмаера',...
    'Сразу во всех слоях на основе баз.профилей: 100% GeO2 и B2O3',...
    'Послойно на основе лин.комб коэф.Зельм', ...
    'Выход')
case 1
   [pvZ KZ] = KZ100( QS, PGB ); %выч к-тов Зельм  световода
   nT = nTSV1( QS, LZ, KZ );
   if ischar(nT),  pvZ = ''; return,end
   if MEN('','Показать профили'), showProf( QS, pvZ, PGB, LZ, KZ,1,0); end

case 2 
    poF = 'По Флемингу';  
    poK = 'По Кобаяши';
    nns = 1:QS;   
    Us  = sprintf('length(I)<=%g', QS);        
    T2  = ['После задания профилей во всех слоях\n'...
           'профили можно корркетировать выборочно'];
    fir = true; 
    while true
       if fir,  fir = false;
          T = 'Выч.коэф.Зельмаера\n1-й раз - для всех слоев';
          D = '(по ум)';                     
       else
          T = 'Выч.к.Зельм\nВыборочно по слоям';
          D = '';                  
          nns = inpRI('Номера задаваемых слоёв',nns,'nn',[1 QS],Us);
          if isempty(nns), break,end
       end
          
       for sl = nns
          T1 = [T '\n' sprintf('%g-слой', sl)];
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
             KZ(1:6,sl) = Z;
             pvZ(:,sl)  = pv;
             L = setK([LZ 100])';  
             showProfsl( QS, pvZ, PGB, L, KZ, 1, poFK, sl, 1);
          end
       end  

       if ~MEN( T2, 'Корректировать')
          nT = nTSV1( QS, LZ, KZ );
          if ischar(nT),   return,end
       end
    end
    
case 3, nT = 'Отказ от выч к-тов Зельмаера';  
end

% ________%выч к-тов Зельм KZ на основе 100% Ge и В_______________
function [pvZ KZ] = KZ100( QS, PGB) 
global  eKZ 
pvZ = cell(2,QS); 
for i = 1:QS,   pvZ(:,i) = {'2 3';'100'}; end
KZ = 0.01*( eKZ(3:8,1)*(100.0-PGB(1,:)-PGB(2,:)) +eKZ(3:8,2:3)*PGB);

% ____________% ввод Коэфф. Зельмаера __________________________________
function [Zsl pvZsl] = inpKZ( QS, sl, pvZsl, PGBsl, t, N1,N2,N3) 
global  eKZ          
if sl <= QS  &&  all(PGBsl) == 0
   Zsl = eKZ(3:end,1); return,end

pv0 = pvZsl;
               %к-ты eKZ, выбр-е базовыми
bZ = {{sprintf('%s\n\nНомера строк:  ',eKZ_t)},...
      {'Задать веса: if pass, p1=...=pN, else p1+...+pN=100'}};
  
d0  = sprintf('%d %d;...',N1,N2,N1,N3,N2,N3,N3-1,N3);  
d0(end-3:end) = [];
if isempty(pv0{1}),  pv0 = {d0;''};  end

if sl <= QS,  tit = sprintf('%d слой. К-ты Зельм-%s',sl,t);
else          tit = 'Задание к-тов Зелм. для 100%B'; end

pv = cellfun( @str2num, pv0, 'UniformOutput', false);
if isempty(pv)
   Zsl = 'inpKZ: Содерж ячейки pv(пары,веса) дб численным';
   return
end

while true
   pv = inpU( tit, pv, bZ, {50 50}, {[1 17];[0 100]});
   if ischar(pv), Zsl = ['inpKZ: ' pv]; return,end
   
   [p,v]   = pv{:}; % - p-пары номеров, v-веса строк с №№ p массива eKZ
   [rp,cp] = size(p);
   mi      = min(min(p));
   if cp~=2 || 3<mi && mi<N1 || max(max(p))>N3,  prie(...
      ['   Д.быть:\n1) №№ задаются парами, разделяются знаком ";"\n'...
      '   напр., к-ты на базе комб пар строк 1, 4 и 5, 8 - 1 4;5 8\n'...
      '   на базе k-й стр - k k (можно, если %Ge=eKZ(1,k) и %B=eKZ(2,k)'...
      '\n2) %d<=№строки<=%d'],N1,N3);  
      continue
   end

   if rp~=1 && (~isempty(v) && (sum(v)~=100 || rp~=length(v)))
      prie(['Д/быть:\n1) К-во весов=к-во пар\n'...
      '2) Если веса заданы, то их сумма=100']); 
      continue
   end
   break
end

if isempty(v) || rp==1,   v = 100.0*ones(1,rp)/rp; end
pvZsl = {matstr(p);  matstr(v)};    
Zsl = KZsl( QS, sl, pvZsl, PGBsl);

%________преобр. м-цы чисел в симв. строку строк, разд ';'_______
function s = matstr(m)
if isempty(m), s = '';
else  r = size(m,1);     s = num2str(m(1,:));
  if  r>1, for i = 2:r,  s = [s ';' num2str(m(i,:))]; end,end
end

%____________% выч к-ты Зельм для слоя sl ____________________________
function Zsl = KZsl( QS, sl, pvZsl, PGBsl) 
% if sl = QS+1, Z выч для базы В2О3
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
         else Zsl = sprintf('Слой %d\nСтрока %g) %g, %g не соотв G=%g B=%g',...
                    sl,T,GB,pG,pB);  return
         end
           
      else        % sl=QS+1 - рассч к-ты для 100% B2O3
         if GB(1) == 0,  Zk = f/GB(2);
         else  Zsl = sprintf('Слой %d\nСтрока %g) %g %g не соотв 100%%B',...
                   sl,T,GB);  return
         end
      end
   elseif det(GB) == 0
      Zsl = sprintf('Слой %d\nСтроки %g %g\nвырожд.м-ца=\n%g %g\n%g %g',...
          sl,T,GB');     return
   else Z100 = f/GB;
   end
  
   if ~isZk
      if sl <= QS,  Zk = (1-pG-pB)*eKZ(3:8,1)+Z100*[pG;pB];
      else          Zk = Z100(:,2); end
   end
   Zsl = Zsl+v(k)*Zk; 
end

%_________ Информация о профиле _____________________________________
function [pG, pB, ns, v, rp] = infProf( QS, sl, pvZsl, PGBsl)
% pG=%Ge,pB=%Bor, ns-пары № строк eKZ, v-их веса, rp=rows q-ty of ns
if sl <= QS
   spGB = 0.01*PGBsl;            %PGB(:,sl);
   pG = spGB(1);  pB = spGB(2);
else
   pG = NaN;      pB = NaN;
end

[ps,vs] = pvZsl{:};
ns = str2num(ps);   v = 0.01*str2num(vs);   rp = size(ns,1);

% ______ Тип СВ с дисп __________________________________________
function nT = nTSV1( QS, LZ, KZ )
% nT      = № типа профиля
% TSV =  {'1. n1 >  n2 >  n3',    '3. n1 >  n3 >= n2',
%         '2. n2 >= n1 >  n3',    '4. n2 >= n3 >= n1'}
K    = 40; 
L    = setK([LZ K]);
L_2  = L'.^2; 
n1_2 = n_2kZ( L_2, KZ(1:6,1));  % n^2 в 1 слое 
n2_2 = n_2kZ( L_2, KZ(1:6,2));

if QS == 2      
   if n1_2(K) > n2_2(K),  nT = 1;
   else                   nT = 'n1_2 < n2_2';   end 
else 
   n3_2 = n_2kZ( L_2, KZ(1:6,3)); 
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
 
% ______ Тип СВ без дисп ___________________________
function [nT NA_2] = nTSV0( pn2_2, ee)
% NA - Number of Aperture на сетке L 
% pn2_2 = pn2^2 - квадрат пп во 2-м слое
% ee =  e1     для 2-СВ
% ee = [e1 e3] для 3-СВ
% TSV =  {'1. n1 >  n2 >  n3',    '3. n1 >  n3 >= n2,
%         '2. n2 >= n1 >  n3',    '4. n2 >= n3 >= n1'}
pn1_2 = pn2_2*ee(1);    
if size(ee,2) == 1   % 2-СВ
   if nargout == 2
      if pn1_2 > pn2_2,  nT = 1; else  nT = 2; end
   end
   NA_2 = abs(pn1_2-pn2_2);
else                 % 3-СВ
   pn3_2 = pn2_2*ee(2); 
   if pn1_2 > pn2_2
      if pn2_2 > pn3_2
         NA_2 = pn1_2-pn3_2;  
         if nargout == 2, nT = 1; end              
      else
         NA_2 = pn1_2-pn2_2;
         if nargout == 2, nT = 3; end
      end  % pn2 <= pn3       
   else                                              % pn1 <= pn2        
      if pn1_2 > pn3_2
         NA_2 = pn2_2-pn3_2;  
         if nargout == 2, nT = 2; end     
      else
         NA_2 = pn2_2-pn1_2;                          % pn1 <= pn3
         if nargout == 2, nT = 4; end
      end
   end
end 

%_______________________________________________________________________
function Lw_Callback( hObject, ~, ~)
global CALC LZ  % read only
global Lw       % edit
global clr1 clr2
Lwn  = str2num(get(hObject,'String'));
if ProV( hObject, Lw, Lwn, 1, LZ),  return,end

if Lw ~= Lwn
   Lw  = Lwn;
   set( CALC(5:8),'Enable', 'off','BackgroundColor', clr1 );
end

% ______ Executes during object creation, after setting all properties.
function Lw_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end

% _____________на уд______________________________________________________
function eewLZ = v_eew
global Lw LZ KZ  % read only
L_2   = [Lw LZ].^2; 
n_2   =  n_2kZ( L_2, KZ(1:6,2));      % n^2 во 2-м слое
eewLZ = [n_2kZ( L_2, KZ(1:6,1))/n_2;  n_2kZ( L_2, KZ(1:6,3))/n_2]; 

% ___________________________________________________________________
function c_Callback(hObject, ~, ~)
global CALC clr1  % read only
global c          % edit

cn = str2num(get(hObject,'String'));
if ProV( hObject, c, cn, 1, [0 1]),  return,end

if c ~= cn
   c  = cn;
   set( CALC(5:8), 'Enable', 'off','BackgroundColor', clr1);
end

% ______ Executes during object creation, after setting all properties.
function c_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ______ Executes on selection change in n.
function n_Callback(hObject, ~, ~)
% Hints: contents = cellstr(get(hObject,'String')) returns n contents as cell array
%        contents{get(hObject,'Value')} returns selected item from n
global CALC clr1 % read only 
global n DxHF    % edit
nn = get(hObject,'Value');
if  n ~= nn
    n  = nn;  DxHF = NaN;
    set( CALC(5:8), 'Enable', 'off', 'BackgroundColor', clr1 );
end

% ______ Executes during object creation, after setting all properties.
function n_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ______ Executes on selection change in Moda.
function Moda_Callback(hObject, ~, ~)
global CALC clr1   % read only
global NNM DxHF    % edit
Vn = get(hObject,'Value');
if  sum(NNM) ~= Vn
    if Vn == 3,  NNM = 1:2;
    else         NNM = Vn;  end
    DxHF = NaN;
    set( CALC(5:8), 'Enable', 'off', 'BackgroundColor', clr1 );
end

% --- Executes during object creation, after setting all properties.
function Moda_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%________________________________________________________
function XnXkK_Callback( hObject, ~, ~)
global CALC clr1    % read only
global XnXkK        % edit
XnXkKn  = str2num( get( hObject, 'String'));

if     isempty(XnXkKn),                ER = 'Введены не числа';
elseif numel(XnXkKn) ~= 3,             ER = 'Чисел дб ровно 3';              
elseif XnXkKn(1) > XnXkKn(2) ,         ER = 'Xн д.б < Хк';
elseif XnXkKn(1)<0  || XnXkKn(2)>100 , ER = 'Выход Х за границы [0 100]';
elseif XnXkKn(3)<10 || XnXkKn(3)>1e6 , ER = 'Выход К за границы [10 1e6]';
elseif mod( XnXkKn(3), 1 ) ~= 0,       ER = 'K - нецелое число';
else                                   ER = NaN;
end 

if ischar(ER)
   prie(ER)
   set( hObject, 'String', num2str(XnXkK) );
   return
end

if any( XnXkK ~= XnXkKn )
   XnXkK = XnXkKn;
   set( CALC(5:8), 'Enable', 'off', 'BackgroundColor', clr1 );
end

% ______ Executes during object creation, after setting all properties.
function XnXkK_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%______________________________________________________________________
function Hgru_Callback(hObject, ~, handles)
global CALC clr1 % read only
global Hgru      % edit
Hgrun   = str2double( get( hObject, 'String'));
if ProV( hObject, Hgru, Hgrun, 1, [1e-10 2]),  return,end

if Hgru ~= Hgrun
   Hgru = Hgrun; 
   set( CALC(5:8), 'Enable', 'off', 'BackgroundColor', clr1 );
end

% ______ Executes during object creation, after setting all properties.
function Hgru_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%_________________________________
function c_s_Callback(hObject, ~, ~)
global CALC clr1 % read only
global c_s       % edit
c_sn  = str2num(get(hObject,'String'));

if     isempty(c_sn),            ER = 'Введено не число';
elseif numel(c_sn) ~= 2,         ER = 'Чисел дб ровно 2';              
elseif c_sn(1)<=0 || c_sn(1)>1 , ER = 'Выход c_гр за границы  [0  1]';
elseif c_sn(2)<=0 || c_sn(2)>1 , ER = 'Выход к.суж s за границы  [0  1]';
else                             ER = NaN;
end 

if ischar(ER)
   prie(ER)
   set( hObject, 'String', num2str(c_s) );
   return
end

if any( c_s ~= c_sn )
   c_s = c_sn;
   set( CALC(5:8), 'Enable', 'off', 'BackgroundColor', clr1 );
end

% ______ Executes during object creation, after setting all properties.
function c_s_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% _______ Executes on selection change in m_max.
function m_max_Callback(hObject, ~, handles)
global CALC clr1 mm  mm_max  % read only 
global m_max                 % edit
m_maxn = get(hObject,'Value');
if  m_max ~= m_maxn
    m_max  = m_maxn;  
    if m_max < mm(2)
       prib(['Значения m оказались > m_max\n' ...
             ' и сейнчас будут изменены'])
       set([handles.m1 handles.m9], 'String', mm_max(1:m_max) )
       set([handles.m1 handles.m9], {'Value'}, {1 m_max} )
    end
    set( CALC(5:8), 'Enable', 'off', 'BackgroundColor', clr1 );
end
% _______ Executes during object creation, after setting all properties.
function m_max_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% _______ Executes on button press in vGX.
function vGX_Callback(~, ~, ~)
global QS KZ nT Lw c n NNM XnXkK Hgru c_s  eew m_max % read only
global GX tGX                                            % edit
global CALC clr1 clr2

h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

if QS == 3,  GXn = vGX3( nT,n,c,NNM, XnXkK, Hgru,c_s, eew, m_max);             
else 
   try       GXn = GraniX_12 ( KZ, n, Lw^2, m_max);  
   catch ME, GXn = ['АВОСТ: GraniX_12-п.3\n' ME.message];               
   end 
end

set( h_on,    'Enable', 'on'); 
if ischar(GXn),  prie(GXn), return,end  

GX  = GXn;
tGX = GX_t;
set( CALC(5:6), 'Enable', 'on',  'BackgroundColor', clr2 );
set( CALC(7:8), 'Enable', 'off', 'BackgroundColor', clr1 );

% ____________Границы Х для 3 сл СВ________________________________
function tGX = GX_t
global m_max GX 
no = 1:m_max;
tGX = sprintf('%2d)  %7.3f  %7.3f\n', [no; GX']);

% _______ Показ границ Х by right click mouse
function vGX_ButtonDownFcn(hObject, eventdata, handles)
global tGX
msgbox( tGX, 'границы Х')

% ____________Границы Х для 3 сл СВ________________________________
function GX = vGX3( nT, n, c, NNM, XnXkK, Hgru, c_s, eew, m9)
% KIN: корневой ин-л - это ин-л, содержащий внутри себя корень х.ф.
koro =  KINs( nT, 1, n, c, NNM, m9, eew, XnXkK, Hgru, c_s );
if ischar(koro), GX = koro; return,end

knan = length( find( isnan(koro) ) );
if knan
   GX = [ sprintf(...
   'Найдено %d корней отсечки вместо %d,\n тк задан малый отрезок Х:\n',...
   m9-knan,m9) sprintf('%g  ',koro)];  return
end

korf = KINs( nT, 2, n, c, NNM, m9, eew, XnXkK, Hgru, c_s );
if ischar(korf)
   GX = ['Корни в отсечке найдены\n' sprintf('%g  ',koro) ...
        '\nв дальн.зоне - нет\n' korf ]; return
end

knan = numel(find(isnan(korf)));
if knan 
   GX = ['Корни в отсечке найдены\n' sprintf('%g  ',koro) ...
   sprintf('\nВ дальн.зоне найдено %d корней из %d:\n', m9-knan,m9)...
   sprintf('%g  ',korf)];  return
end
GX = [koro korf]; 
%if n == 1,  vGX = [[0; koro(1:end-1)] korf];
%else        vGX = [koro korf];  end

% _____________ Опред Корневых ИН-лов ______________________
% Корневой ин-л - это ин-л, в к-ом находятся все корни Х для данного m
function kor = KINs( nT, nof, n, c, NNM, m9, eew, XnXkK, Hgru, c_s )
% eew = [e1(Lma) e3(Lma)],  Lma - это дл.волны, где апертура максимальна
% NNM = {1, 2, 1:2} номера мод
EH   = 'EH';
setX = XnXkK;            H = Hgru;           
fs   = {@HFot @HFfa};
f    = fs{nof};
fna  = func2str(f); 
it   = 0; 

oof  = str2func(['oo' fna]); 
f_ar = str2func([fna '_ar']);
zag  = sprintf('nT=%d  %s  n=%d  m=[1 %d] c=%g', nT, fna, n, m9, c);
%                       ВЫБОР П-РОВ
subplot(1,1,1)
KM  = length(NNM);             % - к-во мод ( либо 1, либо 2 )
kor = nan( m9, KM );  

if fna(end) == 't',  KIN = true;    
else                 KIN = false; end   
s   = 3;    
e1  = eew(1);           e3 = eew(2); 
u1  = (e1-1)/(e1-e3);   u2 = (e1-1)/(1-e3);   u3 = (e1-e3)/(1-e3);  
sT  = {setX;  [H KIN]};
while true
   setX = sT{1};
   H    = sT{2}(1); 
   KIN  = sT{2}(2);
   X    = setK(setX);
   XH   = setX(1) : H : setX(2)+H/2;    
   lenXH = length(XH);
   [AL BE GA] = oof(  nT, n, c, c_s, X,  u3);
   [A  B  G]  = oof(  nT, n, c, c_s, XH, u3); 
   Y          = f_ar( nT, n, c, eew, X,  u1,u2,u3, AL,BE,GA);
   YH         = f_ar( nT, n, c, eew, XH, u1,u2,u3, A, B, G);
   
   plot( X,Y, XH,YH,'.r'); 

   grid on;  titlab(zag, {'X',fna});
   NePok( '', 2,...
      ['Задание нач значения левого конца интервала\n' ...
      'KIN=0, if корень-в горбе, исходящем из 0(1-й горб)\n'...
      ' else 1'], [600 400 350 150] )
  
   Up = YH(2) > YH(1);
   kk = 0;
   for j = 3:lenXH      % считаем к-во всех горбов графка YH(X)
      U  = YH(j)>YH(j-1);
      if U ~= Up
         kk = kk+1; 
         Up = U;
      end
   end
   
   if 0.5*(kk+1) < m9
      prib(['Возможно интервал по Х [%g  % g] мал\n' ...
            'для нахождения %d корней'],...
            setX(1:2), m9);
   end

   if length(YH) >= 3,  D = YH(3) > YH(2);  end
   sT = inpU('Изменить п-ры?', sT,...
        {{'Xmin' 'Xmax' 'K'}; {'H' 'KIN'}},...
        {[9 14 19] [5 12]}, ...
        {[5e-15 999; setX(1) Inf; 2 1e6]; [0.01 1; 0 1]});
   if isempty(sT),  break,end
end

Plus = length(YH(YH>0));       % sigY - преобладающий знак ф-ции 

if Plus > lenXH-Plus,  sigY = 1;  else  sigY = -1; end

if n == 1 && nof == 1,  i = 2;  kor(1,KM) = 0;
else                    i = 1;  end

for k = 1:KM
   NNMk = NNM(k); 
   while s < lenXH && i <= m9  
      s = s+1;
      Dp = D;  D = YH(s)>YH(s-1);
      if Dp == D , continue
      else
         KIN = ~KIN;
         if ~KIN,  continue,end
      end
   
      si = sign(YH(s-2:s));
      if all(si == sigY)
         KO = oopSR(A,B,G,s);
         ab = KIN_pend( nT,  n,         c,     NNMk,  ...
                        eew, XH(s-2:s), YH(s), ...
                        u1,  u2, u3,    KO,   f);
         if ischar(ab)
            kor = [ab 'Найдено\n' sprintf('%g ',kor(1:i-1,k))];
            return
         end
      elseif NNMk == 2 && si(2) ~= si(3),   ab = XH(s-1:s);   % H-мода
      elseif NNMk ~= 2 && si(1) ~= si(2),   ab = XH(s-2:s-1); % E-мода     
      else
         zag = sprintf('%s  i=%d  s=%d',fna,i,s); 
         sig = sign(YH(s-1));
         sL  = s-3;        % sL - вЛево от s
         s   = s+1;        
         
         if NNMk == 2    % H-мода
            while sign(YH(s)) == sig && s < lenXH, s = s+1; end       
            if s == lenXH
               [H XH YH] = podborH( nT,  zag, oof,    f_ar, ...
                                    n,   c,   NNMk,   c_s,  ...
                                    eew, XH(s-3:end), YH(s-3:end), ...
                                    u1,  u2,  u3,     H );
               s   = 3;  
               KIN = false;  
               D   = YH(3)>YH(2);
               it  = it+1;
               if it > 20, kor = 'Непр выбран KIN'; return,end
               continue
            else       ab = XH(s-1:s);
            end   
         else   % NNMk = 1    E-мода 
            while sign(YH(sL)) == sig && sL > 1,  sL = sL-1; end         
            if sL == 1
               [H XH YH] = podborH( nT,  zag, oof,    f_ar, ...
                                    n,   c,   NNMk,   c_s,  ...
                                    eew, XH(s-3:end), YH(s-3:end), ...
                                    u1,  u2,  u3,     H );
               s   = 3;  
               KIN = false;  
               D   = YH(3)>YH(2);
               it  = it+1;
               if it > 20, kor = 'Непр выбран KIN'; return,end
               continue %на while s<=...         
            else        ab = XH(sL:sL+1);
            end               
         end        
      end        % КИН найден
 
      KO = oopSR(A,B,G,s); 
      if numel(ab) == 1, kor(i,k) = ab;
      else               kor(i,k) = fzero( @(x) ...
                            f( nT, n, c, eew, x, u1,u2,u3, KO ), ab);
      end   
      i = i+1;  it = 0;  
   end  % i
   
   if s >= lenXH && i < m9
      kor = sprintf(['Мода %s\nНайдено %d корней из %d\n' ...
            'Выбранный и-л по Х [%g  % g] мал для опр %d корней'],...
            EH(NNMk), i-1, m9, XnXkK(1:2), m9);
      return
   end
 end     % k

%____________обл ос-ти в т.s для СпецРежимов____________________________
function KO = oopSR(A,B,G,s)
if length(A) == 1,  KO(1) = A;  else  KO(1) = A(s);  end
if length(B) == 1,  KO(2) = B;  else  KO(2) = B(s);  end
if length(G) == 1,  KO(3) = G;  else  KO(3) = G(s);  end
 
%______поиск Корн интервала ХC, содержащего корень, методом маятника___
function ab = KIN_pend( nT,  n,  c,  NNMk, ...
                        eew, AB, fB, ...
                        u1,  u2, u3, KO, f)
A   = AB(1);     S  = AB(2);     B  = AB(3);
sig = sign(fB);  h  = (B-A)*0.25;
C   = B-h;       Ce = C*eps;
fC  = f( nT, n, c, eew, C, u1,u2,u3, KO );

if fC*sig < 0        % ТСВ2-л.67
   if NNMk == 1, ab = [S C];
   else          ab = [C B];   end
   return
end

if fC == 0      
   if f( nT, n, c, eew, C-Ce, u1,u2,u3, KO )*sig < 0
      if  NNMk == 1, ab = [S C-Ce];
      else           ab = C;  end
   elseif NNMk == 1, ab = C;
   else              ab = [C+Ce B];
   end
   return
end

C  = A+h;
fC = f( nT, n, c, eew, C, u1,u2,u3, KO );  
if fC*sig < 0
   if NNMk == 1, ab = [A C];
   else          ab = [C S];   end
   return
end

if fC == 0
   if f( nT, n, c, eew, C-Ce, u1,u2,u3, KO )*sig < 0 
      if NNMk == 1,  ab = [A C-Ce];
      else           ab = C;  end
   elseif NNMk == 1, ab = C;
   else              ab = [C+Ce S];
   end
   return
end

C  = B+h/2;
ahd2 = 0.5*h;;
h  = -h;   
fC = fB;
first = true;
while abs(h) > eps
   fp = fC; 
   C  = C+h;
   fC = f( nT, n, c, eew, C, u1,u2,u3, KO );
   % отладка
   %h_=abs(h);x_=C-3*h_:h_:C+3*h_;y_=f(nT,n,c,eew,x_,u1,u2,u3,KO);
   %plot(x_,y_, C,fC,'.r'); grid on
      
   if fC*sig < 0            
      if NNMk == 1,  ab = [C-ahd2 C];
      else           ab = [C C+ahd2]; end
      return
   elseif fC == 0
      if f(nT, n, c, eew, C-Ce, u1,u2,u3, KO)*sig < 0
         if NNMk == 1,  ab = [C-ahd2 C-Ce];
         else           ab = C;        end
      elseif NNMk == 1, ab = C;
      else              ab = [C+Ce C+ahd2];
      end
      return
   elseif abs(fC) > abs(fp)        % поворот
      if first,  h = -h;  first = false;
      else       h = -0.5*h;  end
      hd2 = 0.5*h;  ahd2 = abs(hd2);
      C   = C-hd2;
   end
end
ab = sprintf('КИН м.маятника не найд. f=%g',fC);

%______________визуальный ПОДБОР шага H, когда КИН не найден______________
function [H XH YH] = podborH( nT,  zag, oof,  f_ar, ...
                              n,   c,   NNMk, c_s,  ...
                              eew, XH,  YH, ...
                              u1,  u2,  u3,  H)
if NNMk == 2,  t = 'Прав кор( H ). Изм H?';
else           t = 'Лев  кор( E ). Изм H?'; end
while true
   plot(XH,YH,'.b');
   grid on;  titlab(zag,{'x',zag(1:4)});  
   vH = H;
   vH = inpN( t, vH, {'H'}, 3, [eps 1], 1, NaN);
   if isempty(vH), break,end
   H  = vH; 
   XH = XH(1) : H : XH(end)+0.01*H;
   [A B G] = oof ( nT, n, c, c_s, XH, u3); 
   YH      = f_ar( nT, n, c, eew, XH, u1, u2, u3, A,B,G); 
end

% _____________ выч Границ Х для СВ-2____________________________________
function GX2 = GraniX_12( KZ, n, L_2, m9 )
global nuliJ0 nuliJ1    
if     n == 1, GX2 = [[0; nuliJ1(1:end-1)]  nuliJ0];
elseif n > 1
               ee2 = n_2kZ( L_2, KZ(1:6,1)) / n_2kZ( L_2, KZ(1:6,2));
               Xot = vnJJX( n, m9, @JJX,(ee2-1)/(ee2+1));
               GX2 = [Xot  vnBF( @besselj, n-1, length(Xot))]; 
else               
               GX2 = [nuliJ0   nuliJ1];
end

% _____________выч Xотс: hf=Jn-2/Jn-1+(e1-1)/(e1+1)=0___________________
function Xot = vnJJX(n,QR,hf,del)
% Унгер,с.302 
Xot = nan(QR,1);  it  = 0;  
h   = 1;          i   = 1;
xa  = h;          hfa = hf(n,xa,del); 
xb  = 2*h;        hfb = hf(n,xb,del);       
while i <= QR
   while hfa * hfb > 0,
      hfa = hfb;  xb = xb+h;  hfb = hf(n,xb,del);  end
   try   [Xot(i),fv,FL,out] = fzero(@(x) hf(n,x,del),[xb-h xb]);
   catch ME, AT = sprintf('%s\nпри поиске %g-го корня',ME.message,i);
      if exist('fv','var')
         AT = [AT sprintf('\nf = %g, FL = %g\n%s',fv,FL,out.message)];
      end
      prie(AT);  
   end
   
   if FL < 0,  it = it+1;
   else        it = 0;    i = i+1;  end 
   
   if it > 20
      prie('20 итераций\nВместо %g найдено %g точек Xотс',QR,i-1);
      Xot(i:end) = [];  
      return
   end
   hfa = hfb;  xb = xb+h;  hfb = hf(n,xb,del);
end

% _____________________________________________________________________
function f = JJX(n,x,del)
f = besselj(n-2,x)+besselj(n-1,x)*del; 

% _____________ выч Границ Х для СВ-2_без уч дисп ______________________
function GX2 = GraniX_02( n, m9, ee2)
global nuliJ0 nuliJ1    
if     n == 1,  GX2 = [[0; nuliJ1(1:end-1)]  nuliJ0];
elseif n > 1   
                Xot = vnJJX(n,m9,@JJX,(ee2-1)/(ee2+1));
                GX2 = [Xot  vnBF(@besselj,n-1,length(Xot))]; 
else
                GX2 = [nuliJ0   nuliJ1];
end

% _____________выч Границ Х для СВ-3_без уч дисп______________________
function GX3 = GraniX_03
% надо написать


% Изменение значений п-ров : m, qX, qdva 
% не запрещает никакие кнопки вычислений
% ______ Executes on selection change in m1.
function m1_Callback( hObject, ~, ~)
global CALC clr1
global mm
m1 = get( hObject, 'Value' );
if m1 > mm(2)
   prie('m нач дб < m кон'); 
   set( hObject, 'Value', mm(1) );
else
   if m1 ~= mm(1)
      mm(1) = m1;
      set( CALC(7:8), 'Enable', 'off', 'BackgroundColor', clr1 );
   end
end

% ______ Executes during object creation, after setting all properties.
function m1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% _______ Executes on selection change in m9.
function m9_Callback(hObject, ~, ~)
global CALC clr1
global m_max  mm
m9 = get( hObject, 'Value' );
if     m9 < mm(1)
     prie('m нач дб < m кон'); 
     set( hObject, 'Value', mm(2) );
elseif m9 > m_max
     prie('m кон дб <= m_max'); 
     set( hObject, 'Value', mm(2) );
elseif m9 ~= mm(2)
      mm(2) = m9;
      set( CALC(7:8), 'Enable', 'off', 'BackgroundColor', clr1 );
end

% ______ Executes during object creation, after setting all properties.
function m9_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%________________________________________________________

function qX_Callback(hObject, ~, ~)
global qX
qXn = str2double( get( hObject, 'String'));
if ProV( hObject, qX, qXn, 1, [5 1000], 1),  return,end

if qX ~= qXn
   qX  = qXn;
   set( CALC(7:8), 'Enable', 'off', 'BackgroundColor', clr1 );
end

% --- Executes during object creation, after setting all properties.
function qX_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%________ ПРОВерка Ввода для 1-го или 2-х чисел _________________
function IER = ProV( hObject, gloD, D, qD, GD, varargin)
% gloD - предыдущее значение D ( бычно содержится в global)
% D    - введенное данное D
% qD   - число элементов D
% GD   - границы D
% varargin -  условие U
%    U = число ~= 0 - проверка на целочисленность D
%    U = string - произвольное условие на D 
ER = NaN;
if     isempty(D) || isnan(D),     ER = 'Введено не число';
elseif numel(D) ~= qD,             ER = sprintf('Чисел дб ровно %d',qD);           
elseif qD == 2 && D(1) > D(2),     ER = 'Левое дб < правого';     
elseif D(1)<GD(1) || D(end)>GD(2), ER = sprintf(...
                                       'Выход за границы  [%g  %g]',GD); 
elseif nargin == 6
   U = varargin{1};
   if isnumeric(U) 
      if numel(U) ~= 1,            ER = 'флажок пров на цел дб один';
      elseif mod( D(U~=0),1) ~= 0, ER = 'Нецелое число';     end
   elseif ischar(U)
      try if feval(U),  ER = ['Не вып усл: ' U];  end 
      catch ME,         ER = [U ' : непр синтаксис усл\n' ME.message];
      end 
   else  ER = 'Условие дб числом или строкой символов';
   end
end
IER = ischar(ER);
if IER
   prie(ER)
   set( hObject, 'String', sprintf('%g  %g  %g',gloD) );
end

%________Проверка Ввода 3-х чисел ___________________________________
function IER = ProV3( hObject, gloD, D, G1, G2, varargin)

ER = NaN;
if     isempty(D),                ER = 'Введены не числа';
elseif numel(D) ~= 3,             ER = 'Чисел дб ровно 3';              
elseif D(1) > D(2) ,              ER = 'нач д.б < кон';
elseif D(1)<G1(1) || D(2)>G1(2) , ER = 'Выход за границы 1 или 2-го арг';
elseif D(3)<G2(1) || D(3)>G2(2) , ER = 'Выход за границы 3-го арг';
elseif nargin == 6
   U = varargin{1};
   if isnumeric(U)     
      if     numel(U) ~= 3,             ER = 'флажков пров на цел дб 3';
      elseif any( mod(D(U~=0),1) ~= 0), ER = 'арг - нецелое';    end   
   elseif ischar(U)        
      try if ~feval(U), ER = ['Не вып усл: ' U];  end
      catch ME,         ER = [U ' : непр синтаксис усл\n' ME.message];
      end     
   else ER = 'Условие дб вектором чисел или строкой символов';
   end   
end 
IER = ischar(ER);
if IER
   prie(ER)
   set( hObject, 'String', sprintf('%g  %g  %g',gloD) );
   return
end

% ______ Executes on button press in TDG.
function TDG_Callback(~, ~, ~)
global QS LZ hL KZ nT n c c_s GX mm qX n_290 dvaX   % read only
qL  = 50;
qSV = sprintf('%d-СВ',QS);
nm_ = [n 1];          % временные значения п-ров
NAma  = sqrt( max( n_290(:,1)-n_290(:,2) ));
while true
   nm_ = inpN(qSV, nm_, {'n' 'm'}, [5 5], [1 20;  mm], 1:2);
   if ischar(nm_), prib('Выход\n%s',nm_);  break,end
   n_   = nm_(1);        m_ = nm_(2);
   dva_ = dvaX( 5, m_, 1);
   dva_ = inpA('', dva_, '2a', 10, [0.1 1000], NaN);
   TDG( 1,    QS,  ...
        LZ,   hL,       KZ, nT, n_, c, ...
        c_s,  GX(m_,:), m_, qX, ...
        dva_, qL,       NAma );
end

% _______3D-графика х.ф-ции______________________________________________
function TDG( Di,  QS,    ...
              L19, hL,  KZ, nT, n,  c, ...
              c_s, GXm, m,  qX, ...
              dva, qL,  NAma ) 
Vmax = 100;
SV = sprintf('%d-СВ, n=%d', QS, n);
if m == 1,  GXm(1) = 0.1;  end
Kur = 20;
P1  = [hL qL qX 20];      

if Di,  SKL2 = [L19 100];    
else    SKL2 = [pi*dva*NAma/L19(2) 100 100];  end
    
P2  = {SKL2; [GXm 100]; 20};
grX = [0.01 1000];
grK = [5 1e5];      
while true   
   switch MEN({SV,'Задать'},'Сетки д/заданного m','Сетки произвольные')
   case 1, P1 = inpN('П-ры сеток', P1,...
                     {'hL' 'qL' 'qX' 'Kur'}, [5 9 8 8],...
                     [ 1e-15 1; 5 500; 5 500; 0 300], 2:4, NaN);      
           SKL = [grVL( dva, Di, L19, P1(1), GXm(1), NAma, Vmax)   P1(2)];
           SKX = [GXm P1(3)]; 
           Kur = P1(4);
           
   case 2, P2 = inpU( 'Произв сетки', P2,...
                    { {'L1' 'L2' 'qL'}; {'X1' 'X2' 'qX'}; {'Kur'}},...
                    {[12 12 16] [12 19  8] 10}, ...
                    {[L19; L19; grK]; [grX; grX; grK]; [0 300]},...
                    'I{1}(1)<=I{1}(2) || I{2}(1)<=I{2}(2)',NaN);
           SKL = P2{1};
           SKX = P2{2};
           Kur = P2{3};
   case 0, return
   end 
   Grafs( Di, QS, ...
          KZ, nT, n, c, c_s, SKL, SKX, dva, Kur);
end 

%________________выч ГРаниц VL_______________________________________
function  VL19 = grVL( dva, Di, LZ, hVL, Xmin, NAma, Vmax) 
if Di, Lmax = min( LZ(2), pi*dva*NAma/Xmin);     
       VL19 = [LZ(1), floor(Lmax/hVL)*hVL];    % округл с недост до 0.1
else   VL19 = [ceil(Xmin/hVL)*hVL, Vmax];      % округл с изб до 0.1 
end  

%________ все Графики хф ____________________________________________
function Grafs( Di, QS,   ...
                KZ, nT, n, c, c_s, SKL, SKX, dva, Kur)

if QS == 2, V_2QS = @V_22;  VEP = @VEP2;  HF_ar = @HF2_ar;
else        V_2QS = @V_23;  VEP = @VEP3;  HF_ar = @HF3_ar;  end

VL  = setK(SKL);
X   = setK(SKX); 
VLU = VL( ...                                  % VL Уменьш( искл обл x>V)
         V_2QS( Di, KZ, nT, VL.^2, dva ) >= X(1)^2  ); 
[VLmm Xmm] = meshgrid( VLU, X);                % VLmm,Xmm - meshgrid-м-цы
[eeVLmm V_2mm ] = VEP  ( Di, KZ, nT, VLmm.^2, dva); 
[Zmm stAB stGD] = HF_ar( nT, n, c, c_s, eeVLmm, V_2mm, Xmm);                  

if Di, tVL = '\lambda';  else tVL = 'V';  end 

T = {'Каркас1', 'Каркас2', 'Поверхность', '0-уровни',...
     'контуры', 'Контуры+марк авт', 'Контуры+марк'};

while true
   switch MEN({[num2str( QS) '-СВ'],'3D графики'},T)     
   case 1, meshc( VLmm, Xmm, Zmm)
   case 2, meshz( VLmm, Xmm, Zmm)   
   case 3, surfc( VLmm, Xmm, Zmm)
   case 4, contour( VLmm, Xmm, Zmm, [0 0],'k');
   case 5, contour3( VLmm, Xmm, Zmm, Kur)
   case 6, [cHF,hHF] = contour3( VLmm, Xmm, Zmm);     clabel(cHF,hHF); 
   case 7, [cHF,hHF] = contour3( VLmm, Xmm, Zmm,Kur); clabel(cHF,hHF);      
   case 0, break
   end
   hidden off;  grid on;
   titlab(sprintf('nT=%d, n=%d,  2a=%g, сетка %dx%d',...
   nT, n, dva, length(X), length(VLU)), {tVL,'X'} ); 
end

% ______ Executes on button press in GrS1.
function GrS1_Callback(hObject, ~, ~)
% Hint: get(hObject,'Value') returns toggle state of GrS1
global RVDn  RVon 
if isempty(RVon),  RVon = RVonoff;  end
RVDn(1) = get(hObject,'Value');

% ______ Выключает все кроме панели RV
function RVon = RVonoff
global RVh
RVon = findobj( 'Enable', 'on');
set( RVon, 'Enable', 'off');
set( RVh,  'Enable', 'on');

% ______ Executes on button press in OK.
function OK_Callback(~, ~, ~)
global CALC clr1 ...
       RVD RVN RVS   RVDn RVNn RVSn  
if any( [RVD RVN RVS] ~= [RVDn RVNn RVSn] )
   RVD = RVDn;  RVN = RVNn;  RVS = RVSn;
   set( CALC(7:8), 'Enable', 'off', 'BackgroundColor', clr1 );  
end
RVoffon

% ______ Executes on button press in Canc.
function Canc_Callback(~, ~, ~)
global RVD RVN RVS
RVoffon
iniRV(RVD, RVN, RVS)

% ______ Executes on button press in OK.
function RVoffon
global  RVbh RVon
set( RVon, 'Enable', 'on');
set( RVbh, 'Enable', 'off');
RVon = [];

% ______ Executes on button press in ProvT.
function ProvT_Callback( hObject, ~, ~)
global RVDn  RVon 
if isempty(RVon),  RVon = RVonoff;  end
RVDn(2) = get(hObject,'Value');

% ______ Executes on button press in NUGr.
function NUGr_Callback(hObject, ~, ~)
global RVDn  RVon 
if isempty(RVon),  RVon = RVonoff;  end
RVDn(3) = get(hObject,'Value');

% ______ Executes on button press in Otl2a.
function Otl2a_Callback( hObject, ~, ~)
global RVDn  RVon
if isempty(RVon),  RVon = RVonoff;  end
RVDn(4) = get(hObject,'Value');


% ______ Executes on button press in Lev2a.
function Lev2a_Callback(hObject, ~, ~)
global RVDn  RVon
if isempty(RVon),  RVon = RVonoff;  end
RVDn(5) = get(hObject,'Value');

%________________________________________________________
function q2a_Callback( hObject, ~, ~)
global RVD RVDn  RVon
if isempty(RVon),  RVon = RVonoff;  end
RVDn(6) = str2double( get( hObject, 'String'));
if ProV( hObject, RVD(6), RVDn(6), 1, [9 100], 1),  return,end 

% ______ Executes during object creation, after setting all properties.
function q2a_CreateFcn( hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ______ Executes on button press in MZ.
function MZ_Callback(hObject, ~, ~)
global RVNn  RVon 
if isempty(RVon),  RVon = RVonoff;  end
RVNn(1) = get(hObject,'Value');

% ______ Executes on selection change in GLU.
function GLU_Callback( hObject, ~, ~)
global RVNn  RVon 
if isempty(RVon),  RVon = RVonoff;  end
cont  = cellstr(get(hObject,'String'));
RVNn(2) = str2double(cont{get(hObject,'Value')});

% ______ Executes during object creation, after setting all properties.
function GLU_CreateFcn( hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ______ Executes on button press in ILK.
function ILK_Callback( hObject, ~, ~)
global RVSn  RVon 
if isempty(RVon),  RVon = RVonoff;  end
RVSn(1) = get(hObject,'Value');

% ______ Executes on button press in OtlS.
function OtlS_Callback( hObject, ~, ~)
global RVSn  RVon 
if isempty(RVon),  RVon = RVonoff;  end
RVSn(2) = get(hObject,'Value');

% ______ Executes on button press in DVAX.
function DVAX_Callback(~, ~, ~)
global UsPath
global QS    pvB pvBS pvZ   KZB  PGB ...
       LZ    hL  KZ   nT    Lw   eew ...
       c     n   NNM  XnXkK Hgru c_s ...
       m_max GX  mm   qX    RVD  RVN RVS  n_290        % read only
global DxHF dvaX dvaX1                 % edit

h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

tic
[dvaX dvaX1 DxHF AV] = DVAX( QS,  LZ, hL, KZ, nT,   Lw, c, n, NNM, ...
                             c_s, GX, mm, qX, DxHF, RVD, RVN, RVS); 
toc                      
if isempty(dvaX),  prie(AV);  return,end

rm = dvaX(1,:);   
rm = rm(~isnan(rm));    % mm: рейндж найденных mm (range found)

if rm(end) == mm(2);
   save( [UsPath 'daSV\Last'], ...  
   'QS',   'pvB', 'pvBS', 'pvZ',  'KZB',  'PGB', ...
   'LZ',   'hL',  'KZ',   'nT',   'Lw',   'eew', ...
   'c',    'n',   'NNM',  'XnXkK','Hgru', 'c_s', ...
   'm_max','GX',  'mm',   'qX',   'RVD',  'RVN', 'RVS', ...
   'DxHF', 'n_290','dvaX','dvaX1' );
else
   m9 = mm(2);
   mm = rm([1 end]);
   prib('Получены рез-ты для m = %d...%d из %d\n%s',mm,m9,AV);
   qm = numel(rm);
   dvaX = dvaX(:, 1:qm, :);
end

% Сразу после нахождения ДХ дается возможность 
% посмотреть графики и сохранить рез-ты еще и под уникальным именем
UTO = S123( QS,   LZ,       hL,   KZ,    nT, n, c, NNM,...
            c_s,  GX(rm,:), mm,    ...
            DxHF, n_290,    dvaX, dvaX1, RVS);  
set( h_on, 'Enable', 'on');        
if prich(UTO),  return,end
if UTO
      % вставить уточнение
end 

if menu('Сохранить рез-ты под уник именем?','Да','Нет') == 1  
   EH  = 'EH+'; 
   cl  = clock;
   tim = sprintf('%g_%g_%g_%g',cl(1:4));
   save([UsPath 'daSV\' sprintf(...
      '1%d%s %s %g %g_%g_%g %g_%g_%g.mat', ...
      QS, EH(sum(NNM)), tim, Lw, PGB')],...
      'QS',   'pvB', 'pvBS', 'pvZ',  'KZB',  'PGB', ...
      'LZ',   'hL',  'KZ',   'nT',   'Lw',   'eew', ...
      'c',    'n',   'NNM',  'XnXkK','Hgru', 'c_s', ...
      'm_max','GX',  'mm',   'qX',   'RVD',  'RVN', 'RVS', ...
      'DxHF','n_290','dvaX','dvaX1' );
end

% ______ Сохранить рез-ты под уник именем ( кнопка SUI)
function SUI_Callback(~, ~, ~)
global QS  pvB pvBS pvZ   KZB  PGB ...
       LZ  hL  KZ   nT    Lw   eew ...
       c   n   NNM  XnXkK Hgru c_s ...
       GX  mm  qX   RVD   RVN  RVS ...
       DxHF n_290 dvaX dvaX1  
   
EH  = 'EH+';   
cl  = clock;
tim = sprintf('%g_%g_%g_%g',cl(1:4));
save([UsPath 'daSV\' sprintf(...
   '1%d%s %s %g %g_%g_%g %g_%g_%g.mat', ...
   QS, EH(sum(NNM)), tim, Lw, PGB')],...
   'QS',   'pvB', 'pvBS', 'pvZ',  'KZB',  'PGB', ...
   'LZ',   'hL',  'KZ',   'nT',   'Lw',   'eew', ...
   'c',    'n',   'NNM',  'XnXkK','Hgru', 'c_s', ...
   'm_max','GX',  'mm',   'qX',   'RVD',  'RVN', 'RVS', ...
   'DxHF', 'n_290','dvaX','dvaX1' );
  
% ______________________выч 2а(DVA) & X ________________________________
function [dvaX dvaX1 DxHF AV] = DVAX(QS, LZ, hL, KZ,  nT,  Lw, c,n, NNM,...
                                  c_s,GX, mm, qX0, DxHFin, RVD,RVN,RVS )              
%          Характеристики алгоритма
% FL = 0  найден Х(RVD(1)=1),  переход к след dva
% FL = 1  не найден Х,         переход к след dva
% FL = 2  не найден Х,         переход к след m
% FL = 3  найден Х(RVD(1)=0),  переход к след dva
% FL = 4  не найден Х в Solv
% avt = 0  посм 3D-графику(откл автоматического определения 0-уровня)
% ес X(1)=='2', т.е. Нет 0-уровня (мала сетка), то изменить сетку по Х
% FND=1,НАЙДЕН SKX в к-м д.быть нужное и часто единств реш
global  iNAs
global  XC__ A__ B__ XA__ XB__ SA__ Lot__       % для v_S1_Solv

Di = 1;
dvaX = [];   dvaX1 = [];  DxHF = NaN;  AV = 0;
X    = '';

Lech_X = {'К след 2a','К след m', ...
          'Посмотреть 3D и выбрать 0-уровни',...
          'Изменить сетку по X и повт для текущ 2a',...
          'Изменить h и повт для текущ 2a',...
          'Переход к след 2а автоматически, если не найд реш'};
m1 = mm(1);
          
ITmax = 50; 
qdva9 = 50;
FL    = 0;
A2    = zeros(1,ITmax);              
Sv    = A2;                          % A2=2a 
hpb   = [];                          % header для Progress Bar PB_DVAX
mk    = 0;                           % счётчик азимут. чисел m
if NNM == 1 && m1 == 1,  m = 1;      % для E-корня начинать надо с m=2
else                     m = m1-1;  end
m9   = mm(end);
mk9  = m9-m1+1;
Xs   = num2cell(nan(5,qdva9),1); 
hs   = nan(1,qdva9);
EH   = 'EH+';
modn = [EH(sum(NNM)) num2str(n)];   % модa: Hn | En
KM   = length(NNM);                 % к-во мод  
S1   = nan(qdva9,1);  

if QS == 2, V_2QS = @V_22;  iNA = [1 2];        
else        V_2QS = @V_23;  iNA = iNAs(nT,:);  end  
                   
inma = iNA(1);  
                        
qtRS  = 5;                           % к-во точек в PC
qhRAD = (qtRS-1)/2;                  % к-во шагов в радиусе РС
hL2   = qhRAD*hL;                    % радиус РС
L50   = Lw + [-hL2 -hL 0 hL hL2]'; 
nmax0 = n_2kZ( L50.^2, KZ(1:6,inma));

Lmi_2  = L50(1)^2;
Lma_2  = L50(end)^2;
Lw_2 = Lw^2;
KZNA = KZ(:, iNA);
Lpiw = Lw / (pi * sqrt( NA_2( Lw_2,  KZNA)));
NAma =            sqrt( NA_2( Lma_2, KZNA));
qX   = qX0;
qdva = RVD(6);
GLU  = RVN(2);
SM0  = MATRE( Lw, hL2, GLU);     % сеточная матрешка

while  m < m9,    m = m+1;
   GXm   = GX(m,:);              
   Xot   = GXm(1);    X1 = Xot;
   Xfa   = GXm(2);    X9 = Xfa;    
   dvaG  = [X1 X9]*Lpiw;
   NAmaX = NAma/Xot;
   if m == 1,  dvaG(1) = (dvaG(2)-dvaG(1))/(qdva+1); end
   dvaGq = [dvaG qdva]; 
   S_    = nan(1,KM);  stp = [0 0]; 
   i     = 0;                    % нач знач счетчика найд-х Х
   FND   = false;
   fir   = true(1,KM);
   nextdva = ~RVD(4);            % Переход к след 2а авт, если не найд реш
   
   while true                    % пока не удовл точность графика
      [setdva hdva] = setKH(dvaGq);
      for j = 1:length(setdva)   % Выч S1(и S2, S3) 
         avt  = 1;               % выбор ветви: авт/вручную
         dva  = setdva(j);
         if ~FND, SML = SM0; end % Cеточная Матрешка по L
         dvapi = dva*pi;
         Lot  = dvapi*NAmaX;     % начальное значение Lot
         
         if Lot ~= Inf,  Lot = FLot( KZNA, dvapi, Xot, Lot); end
         
         X9mi = min(X9, sqrt( V_2QS( Di, KZ, nT, Lmi_2, dva)));

         if m == 1  &&  ischar(X)       % для m=1 ни одного реш не найд
               SKX(1) = 0.75*X9mi;  
         else  SKX(1) = X1; 
         end
         
         SKX(2:3) = [X9mi qX];
         SX   = setK(SKX);
         umh  = 0;  
         umh1 = 0; 
         uvX  = false;
         while true
            [X h DxHF] = UR0( Di,   QS,  ...
                              KZ,   nT,  n,   Lw,  c,  NNM, ...
                              c_s,  GXm, m,   SML, SX, ... 
                              DxHF, dva, avt, FND, RVN,RVS );
            if ~ischar(X),  FL = 0;  break              
            elseif X(1) == '9'   % малый захват длины волны Lw шагом hL
               if umh < 3        % уменьш h, ес не было и повтор
                  umh = umh+1;
                  ht2 = h(1);       ht = ht2*0.5;                
                  SML = Lw + [-ht2 -ht 0 ht ht2];
                  SX  = setK( [h(2:3)  qX] );
                  FND = -1;
                  continue
               elseif FND
                  AV = sprintf('%s\n%s%d i=%d, j=%d', X,modn,m,i,j);
                  return
               end
            elseif X(1) == '6'
               if umh1 < 7        % уменьш размеров матрешки в 2
                  umh1 = umh1+1; 
                  SML  = MATRE(Lw, (Lw-SML(1))*0.5, GLU);
                  continue
               elseif FND
                  AV = sprintf('%s\n%s%d i=%d, j=%d', X,modn,m,i,j);
                  return
               end
            elseif X(1) == '7'     % удвоение ширины SX, если его не было              
               if ~uvX,   uvX = true;             
                  SX = setK( [SKX(1) 2*SKX(2)-SKX(1)  qX] );
                  continue
               end
            elseif ~FND && X(1)=='1'  ||  X(1)=='0'
               FL = 1;
               break
            elseif FND               
               if qX > 8*qX0
                  AV = sprintf(['%s\nqX=%d qX0 превышено в 8 раз\n'...
                  'Найдено %d X, j=%d\nПоследнее\n',...
                  'dva=%g X=%g %g %g %g %g'],X,qX,i,j,setdva(j-1),X_);
              
                  ii = MEN( {X AV}, Lech_X); 
                  if 0 < ii  &&  ii <= 3
                     if ii == 3,   avt = 0; continue,end
                     FL = ii; break;   % к след dva или m     
                  elseif ii == 4             
                     SKX = inpN('Сетка Х',SKX,...
                          {'X1' 'X9' 'qX'},[10 10 6],...
                          [SKX(1:2); SKX(1:2); 5 500],3,'I(1)<=I(2)',NaN);
                     SX = setK(SKX);
                     continue
                  elseif ii == 5
                     ht  = inpN(t,h,{'h'},3,[eps 2*hL],NaN);
                     SML = MATRE(Lw,ht,GLU);
                     continue              
                  elseif ii == 6, FL = 1;  nextdva = true;  break
                  else   AV = X; return
                  end                  
               end
               qX = qX*2;
               SX = setK( [SKX(1:2)  qX] );
               continue
            elseif  nextdva
               FL = 1;
               break
            else           
               ii = MEN( [X sprintf('2a=%g',dva)], Lech_X); 
               if 0 < ii  &&  ii <= 3
                   if ii == 3,   avt = 0; continue,end
                   FL = ii; break;   % к след dva или m     
               elseif ii == 4             
                   SKX = inpN('Сетка Х',SKX,...
                     {'X1' 'X9' 'qX'},[10 10 6],...
                     [SKX(1:2); SKX(1:2); 5 500],3,'I(1)<=I(2)',NaN);
                   SX = setK(SKX);
                   continue;             
               elseif ii == 5
                   ht  = inpN(t,h,{'h'},3,[eps 2*hL],NaN);
                   SML = MATRE(Lw,ht,GLU);
                   continue              
               elseif ii == 6, FL = 1;  nextdva = true;  break
               else   AV = X; return
               end
            end
         end   % ii == 0,
                   
         if FL == 1, continue,end   % к след dva, тк это dva мало                 
         if FL == 2, break,end      % к след m
          % FL = 0 или 3
         i    = i+1;                % счетчик найд-х Х
         FND  = i;                  % найд 1-й корень Х
         Xmi2 = X( qtRS, KM);
         if m == m1 && i == 1
            if ~isnan(DxHFin) && DxHFin*DxHF < 0
               AV1 = sprintf(...
              'DVAX. Мода %s%d. Несовпадеие знаков DxHFin=%g, DxHF=%g',...
               modn, m, DxHFin, DxHF);
               if menu(AV,'Так и дб. Продолжить','Выход') == 2
                  AV = AV1;
                  return
               end
            end
         end
         
         if hL-h < 1e-10*h
            L5   = L50;
            nmax = nmax0;
         else    
            h2   = h*2;
            L5   = Lw + [-h2 -h 0 h h2]';
            nmax = n_2kZ(L5.^2,KZ(1:6,inma));
         end         
                                    % ниж гр Х для след dva  
         if i == 1 || m > 18,  X1 = Xmi2;
         else                  X1 = (Xmi2+extDLfV(X9,[Xmi1 Xmi2]) )/2; end
                    
         qX = qX0; 
         Xmi1 = Xmi2;
                                    % X1 = X(qtRS,1);  end
         KR = size(X,2);            % к-во найденных решений (мб < KM)         

         if RVD(1)                  % Строить график S1(2a), ес не найд 2а
            Xs{j} = X;   hs(j) = h;  
            if KM == 1,  S1(j) = v_S1(L5,h, X,dva,nmax);
            else                    % KR = 2 только при m>1
               if KR == 1,  S1(j) = v_S1(L5,h, X,dva,nmax); 
               else         S1(j) = v_S1(L5,h, X(:,KR),dva,nmax);  end              
            end
         else                       % Не строить промеж график S1(2a)
            if KM == 1               
               S = v_S1( L5, h, X, dva, nmax);
               S1(j) = S;
               if m == 1
                  %if m1_dva,  m1_dva = false;  prib(m1_dvaT);  end
                  if RVD(6)           % выбор левого 2а
                     if S_> 0 && S < 0, FL = 3;  break;
                     else               S_ = S;  X_ = X;  h_ = h;  end  
                  else                  % выбор правого 2а (по умолч)
                     if S_< 0 && S > 0, FL = 3;  break;
                     else               S_ = S;  X_ = X;  h_ = h;  end 
                  end
               else
                  if     fir && S > 0,  FL = 2; break            % след m
                  elseif fir,           fir = false;             % S<=0
                                        S_ = S;  X_ = X;  h_ = h;
                  elseif S < 0,         S_ = S;  X_ = X;  h_ = h;% продолж
                  else                  FL = 3;  break
                  end      % и-л найд
               end
            else
               if KR == 1       %  найд 1 решениe: KR == 1        
                  if m == 1
                     S(2) = v_S1(L5,h, X,dva,nmax);
                     if RVD(6)           % выбор левого 2а
                        if S_(2)> 0 && S(2) < 0, FL = 3;  break
                        else        S_(2) = S(2); X_= X; h_(2) = h; end 
                     else                  % выбор правого 2а (по умолч)
                        if S_(2)< 0 && S(2) > 0, FL = 3;  break
                        else        S_(2) = S(2); X_= X; h_(2) = h; end
                     end
                  else
                     S(1) = v_S1(L5,h, X,dva,nmax);
                     if     fir(1) && S(1) > 0,  FL = 2; break  % след m
                     elseif fir(1)
                                       fir(1) = false;          % S<=0
                                       S_(1) = S(1);  X_ = X; h_(1) = h;
                     elseif S(1) < 0,  S_(1) = S(1);  X_ = X; h_(1) = h; 
                     else              FL = 3;  break; end
                  end  % и-л найд              
               else               %  найд 2 решения: KR == 2  
                  if ~stp(1)
                     S(1) = v_S1(L5,h, X(:,1),dva,nmax);
                     if     fir(1) && S(1) > 0,  stp(1) = 1;   % 2a1 н/н
                     elseif fir(1)
                            fir(1) = false;                     % S<=0
                            S_(1) = S(1);  X_(:,1) = X(:,1); h_(1) = h;
                     elseif S(1) < 0
                            S_(1) = S(1);  X_(:,1) = X(:,1); h_(1) = h;
                     else   stp(1) = 2;  
                     end
                  end              % и-л найд 
                  if ~stp(2)
                     S(2) = v_S1(L5,h, X(:,2),dva,nmax);
                     if     fir(2) && S(2) > 0,  stp(2) = 1;   % 2a2 н/н
                     elseif fir(2)
                            fir(2) = false;                     % S<=0
                            S_(2) = S(2);  X_(:,2) = X(:,2); h_(2) = h;
                     elseif S(2) < 0
                            S_(2) = S(2);  X_(:,2) = X(:,2); h_(2) = h;
                     else   stp(2) = 2;
                     end
                  end              % и-л найд
                  if stp == 1,   FL = 2;  break; end
                  if stp == 2,   FL = 3;  break; end
               end
            end
         end
      end 
  
      if FL == 2,  break,end              % след m
      
      if RVD(1)                           % Строить графики S1(2a)
         IZ = izS1([dvaG qdva],S1,Xs,hs); % поиск и-лов: =0 S1(2a)  
         iIZ = any(~isnan(IZ(1,:)));      % для каких NM найдены KIN`ы
                                         
         if iIZ,  break       % найдены KIN`ы для всех NM
         elseif any(iIZ)
            plot(setdva,S1);
            titlab(sprintf(...
            ['%Для моды %d (%d%d) и-л AB: S1(A)*S1(B)<0 не найден'...
            '\nИщем 2а: S1(2a)=0 для моды %d'],...
            NNM(~iIZ),n,m,NNM(iIZ)),{'2a','S1'});  grid on 
          
         elseif RVD(2),  FL = 2;  break;  % откл проверка точности графика
         else
            plot(setdva,S1);
            titlab(sprintf('%s%d',modn,m),{'2a','S1'});  grid on 
            AV2 = sprintf(' %s%d. Корн. и-лы для S1 не найд',modn,m);
            
            switch MEN(AV2,'След m','Увел точность графика и повтор')
            case 1, FL    = 2;  break;              % к след m
            case 2, dvaGq = inpN('2a-сетка', dvaGq,...
                               {'2a1' '2a9' 'qdva'},[6 6 6],...
                               [0.1 999; 0.1 999; 1 500],3,...
                              'I(1)<=I(2)',NaN);     % повтор для текущ m
                    continue
            case 0, AV = [AV2 'Выбран Выход']; return
            end
         end
      elseif FL == 3,  break         % Не строить гр S1(2a). Реш найдено
      else                           % Реш найдено => Строим график S1(2a)
         fig = figure;
         plot(setdva,S1);
         titlab(sprintf(...
         ['Корни не найдены\n%s%d 2a = [%g %g] qX = %d\n' ...
         '=> Удвоение к-ва шагов'],modn,m,dvaG,qX),{'2a','S1'});
         grid on ;
         qX = qX*2;
         if ~RVD(3),  delete(fig);  end
      end
   end  % пока не удовл точность графика     
 
   if FL == 2, continue,end    % след m

                         % поиск 2а                      
   for NM = 1:KM                   % № моды
     if RVD(1)                     % построение промеж графиков
       if ~iIZ(NM), continue,end   % пропуск моды с не найд КИН
       no = size(IZ{NM},2);
       if no > 1
          t = cell(1,no);
          for i =1:no, t{i} = sprintf('(%g  %g)',IZ{NM}(1:2,i)); end
          plot(setdva,S1);
          titlab(sprintf('Мода %s%d',modn,m),{'2a','S1'});  grid on
          AV3 = sprintf('%s%d, 2a=%g. Не найд корн.ин-ла',modn,m,dva);
          no = MEN(['Выбор интервала\n' AV3],t); 
       end 
       if no == 0, AV = AV3; return,end       
    
       A=IZ{NM}(1,no);SA=IZ{NM}( 2,no);XA=IZ{NM}( 3: 7,no);hA=IZ{NM}(8,no); 
       B=IZ{NM}(9,no);SB=IZ{NM}(10,no);XB=IZ{NM}(11:15,no);hB=IZ{NM}(16,no);
     
     else              % без построения промеж графиков
        if KR ==2 && stp(NM) ~= 2
           continue,end          % пропуск моды с не найд КИН
       
        A = dva-hdva;  SA = S_(NM);  XA = X_; hA = h_(NM);
        B = dva;       SB = S(NM);   XB = X;  hB = h;
     end
        
     if hA < hB-1e-10
        h   = hA;    h2 = h*2;
        L5  = Lw + [-h2 -h 0 h h2]';
        SXB = setK( [XB([end 1]); 20] );
        [XB ht] = UR0( Di,   QS,   ...
                       KZ,   nT,  n,   Lw, c,   NNM, ...
                       c_s,  GXm, m,   L5, SXB, ...
                       DxHF, B,   avt, 0,  RVN,RVS); 
        if ischar(XB),  AV = sprintf(...
           'DVAX: Такого не ДБ\n%s\nМода %s%d, 2a=%g\nXB19=%g %g',...
           XB,modn,m,B,SXB(1:2)); return
        end
   
        if abs(h-ht) > 1e-6*h
           AV = sprintf('h=%g дб = ht=%g. XB-?',h,ht);   return,end
   
        nmax = n_2kZ(L5.^2,KZ(1:6,inma));
        SB   = v_S1(L5,hA, XB,B,nmax);
        
     elseif  hA > hB+1e-10
        prie('СТРАННОСТЬ:DVAX: hA=%g > hB=%g; дб <=',hA,hB); 
        h   = hB;    h2 = h*2;       
        L5  = Lw + [-h2 -h 0 h h2]';
        SXA = setK( [XA([end 1]); 20] );
        [XA ht] = UR0( Di,   QS,  ...
                       KZ,   nT,  n,   Lw, c,   NNM, ...
                       c_s,  GXm, m,   L5, SXA, ...
                       DxHF, A,   avt, 0,  RVN,RVS );
        if ischar(XA),  AV = sprintf(...
           'DVAX: Такого не ДБ\n%s\nМода %s%d, 2a=%g\nXA19=%g %g',...
           XA,modn,m,A,SXA(1:2));  return
        end
   
        if abs(h-ht) > 1e-6*h        
           AV = sprintf('h=%g дб = ht=%g. XA-?',h,ht);   return,end  
       
        nmax = n_2kZ(L5.^2,KZ(1:6,inma));
        SA   = v_S1(L5,hB, XA,A,nmax);
     end
     
           % Поиск 2a(dva), причем корень dva заведомо есть, т.к SA*SB<0
     A__= A;   B__= B;
     try
        XA__= XA(1:2);  SA__ = SA; 
        XB__= XB(1:2);  Lot__= Lot;     
        [dva SC FL1 out] = fzero( @(dv)  v_S1_Solv(...
                               Di,   QS, ...
                               KZ,   nT,  n,   c,    NNM, ...
                               c_s,  GXm, m,   h,    L5,  qtRS, ...
                               DxHF, dv,  Xot, nmax, iNA, RVS), ...
                               [A__ B__]);
        if FL1 ~= 1
           AV = ['DVAX: fzero при поиске dva.\n' out.message];
           return
        end
       
        XC = XC__;
        BA = B__-A__;
        % КОНЕЦ поиска корня 2а для вар-та с исп fzero
     catch ME
        AV4 = sprintf(['fzero не нашла 2а на AB=[%g %g]\n'...
               'S(AB)=[%g %g] %s%d\n%s\n'],...
               A,B,SA,SB,modn,m,ME.message);
        mes = menu(AV,'Самодельный вар-т(авт)',...
                      'Самодельный вар-т(отлад)', 'Выход');
        if mes == 3,  AV = [AV4 'Выбран выход']; return;  end
        
        otlad = mes == 2;
        v = 0;  
        while true
          if SA ~= 0 && SB ~= 0                
             it2 = 0; 
             BA  = B__-A__; 
             ves = SA/(SA-SB);
             while BA > 4.0*eps*max(B__,1.0)
                it2 = it2+1;
                dva = A__+ves*BA;
                XC0 = ((B__-dva)*XA(1:2)+(dva-A__)*XB(1:2))/BA;
                if Lot ~= Inf
                   Lot = FLot( KZNA, dva*pi, Xot, Lot); end
             
                XC = Solv( Di,   QS, ...
                           KZ,   nT,  n,   c,   NNM, ...
                           c_s,  GXm, m,   h,   L5(1), qtRS,...
                           DxHF, dva, Lot, XC0, 1, RVS);      
                if ischar(XC)
                   FL  = 4; 
                   tFL = XC; break
                end
        
                SC = v_S1( L5, h, XC, dva, nmax); 
                if SC == 0,   break, end
                if SA*SC<0,   B__ = dva;  SB = SC;  XB = XC;
                else          A__ = dva;  SA = SC;  XA = XC; end
                BA  = B__-A__;    ves = SA/(SA-SB);
       
                if it2 > ITmax,  FL = 4;
                   tFL = sprintf('%g итераций недост',it2); break,end
             
                if otlad,  v  = v+1;     Sv(v) = SC;   A2(v) = dva;    
                   plotS1_otl2a( m, A2(1:v), Sv(1:v));  end
            end
    
            if SC ~= 0, dva = A__+ves*BA; 
                        XC  = ((B__-dva)*XA+(dva-A__)*XB)/BA; end
            break
          else                    % SA*SB=0
            if SA == 0, dva = A__; XC = XA; 
            else        dva = B__; XC = XB; end
         
            if otlad,  Sv(v) = 0; A2(v) = dva; end
            break; 
          end
        end
      
        if FL == 4   
           if otlad, plotS1_otl2a( m, A2(1:v), Sv(1:v));  end
           XT = sprintf('%g ',XC0);
           AV = sprintf(['СТРАННОСТЬ-DVAX\n'...
           '2a не найд, хотя найден корневой и-л(КИН)'...
           'на концах к-го S1 имеет разные знаки:\n' ...
           'Мода %s%d\n'...
           'Последн значения:\n2а=%g\nX=%s\nS1=%g\n%s'],...
            modn,m,dva,XT,SC,tFL);
           return
        end    
        if otlad, prib(...
           'Мода %s%d\n2a=%g\nS1=%e\nАбсП=%g\nОтнП=%g',...
           modn,m,dva,SC,abs(BA),abs(BA/B__));
        end
     end  % КОНЕЦ поиска корня 2а для самод вар-та (dva изменилось!)

          % Вычисление х.кривой для найд 2а=dva и х=ХС
          % это продолжение(by Solv) 5-точечной кривой ХС в обе стороны
                         % реш у-я (6) Тетрадь_СВ2
     
     if Lot ~= Inf,  Lot = FLot( KZNA, dva*pi, Xot, Lot);  end  
     LotZ  = min(Lot,LZ(2));    % Ограничение Lot представлением Зельм                
                                 % Разгон h до hL влево и вправо от Lw           
     if h >= 0.9*hL
        X0L = XC([2 1]);  X0R = XC(4:5);    vst = XC(3);  % vst вставка 
        L1L = Lw-h;       L1R = Lw+h;       dob = 1;       be = 1;
     else
        X0L = XC([3 1]);  X0R = XC([3 5]);  vst = [];      hr = 2*h;    
        L1L = Lw;         L1R = Lw;         dob = -1;      be = 2;
        while abs(hL-hr) > 0.5*hr 
           XrL = Solv( Di,   QS, ...
                       KZ,   nT,  n,   c,   NNM, ...
                       c_s,  GXm, m,   hr,  Lw, 3,...
                       DxHF, dva, Lot, X0L, 2,  RVS ); 
           if ischar(XrL),  AV = XrL;  return,end
           
           XrR = Solv( Di,   QS, ...
                       KZ,   nT,  n,   c,   NNM, ...
                       c_s,  GXm, m,   hr,  Lw, 3,...
                       DxHF, dva, Lot, X0R, 3,  RVS ); 
           if ischar(XrR),  AV = XrR;  return,end
           
           hr     = hr*2;  
           X0L(2) = XrL(1);  
           X0R(2) = XrR(3);  
        end
     end
           % конечное значенин hr дб=hL
     qLe = floor( (L1L-LZ(1)) / hL + 1e-7) + 1;   
     qRi = floor( (LotZ- L1R) / hL + 1e-9) + 1; 
     
     XL = Solv( Di,   QS, ...
                KZ,   nT,  n,   c,   NNM, ...
                c_s,  GXm, m,   hL,  L1L, qLe,...
                DxHF, dva, Lot, X0L, 2,   RVS ); 
     if ischar(XL),  AV = XL;  return,end
     
     XR = Solv( Di,   QS, ...
                KZ,   nT,  n,   c,   NNM, ...
                c_s,  GXm, m,   hL,  L1R, qRi,...
                DxHF, dva, Lot, X0R, 3,   RVS ); 
     if ischar(XR),  AV = XR;  return,end
     
     mk = mk+1;
     q  = qLe+qRi+dob; 
     temp = [m;  L1R+(qRi-1)*hL; q; dva; Lot; XL; vst; XR(be:end)];
     
     if m == 1 
        if NM==1,  dvaX1 = temp;
        else       dvaX1 = [dvaX1 temp];  end
     else
        if (m==2 || mk==1) &&  NM == 1
           le1  = 5+q;
           dvaX = nan( le1, mk9, KM);
           
           if ~isempty(dvaX1) 
              dvaX(:, 1, NM) = dvaX1( 1:le1 ); 
              dvaX( [2 3 5], 1, NM) = temp( [2 3 5] );
           end
        end            
        dvaX(1:5+q, mk, NM) = temp;
     end
   end 
   hpb = PB_DVAX( hpb, m, mk, m9-m1+1);
end
 
delete( hpb )

% _____________Ф-ция вычисления Lot побыстрее fLot _____________________
function Lot = FLot( KZNA, dvapi, Xot, L0)
Lot = fzero( @(L)  L*Xot-dvapi*sqrt( n_2kZ( L^2, KZNA(:, 1)) - ...
                                     n_2kZ( L^2, KZNA(:, 2))), L0);
                                 
% ____________Выч дисперсии S1 по 5 равноотстоящим точкам Х___________
function S1 = v_S1(L, hL, X, dva, nmax) % только для X длины 5
% L, X, nmax - столбцы        
S1 = -L(3)*([-1  16 -30  16 -1]*sqrt(nmax-((X.*L)/(pi*dva)).^2))...
      /(12*hL*hL*0.299792458e-3);

% ____________сеточная МАТРЕшка__________________________________________
function SM = MATRE( C, h2, G)
% C   центр,   h2 - диаметр, G - глубина
SM = C + [ -h2./2.^(0:G+1)  0  h2./2.^(G+1:-1:0) ]';
  
% ____________Изменение Знака S1 на сетке Sdva_______________________
function IZ = izS1(Sdva,S1,Xs,hs)
dva1 = Sdva(1);       
qdva = Sdva(3);
IZ   = nan(16,1);
H    = (Sdva(2)-dva1)/(qdva-1);
s    = 0;
for j = find(~isnan(S1(1:qdva-1)))'
   if S1(j) * S1(j+1) < 0
      dva = dva1+j*H;   s = s+1;
      IZ(:,s) = [dva-H;  S1(j);   Xs{j};   hs(j);...
                 dva;    S1(j+1); Xs{j+1}; hs(j+1)];
   end
end 

% ________________________________________________________________
function plotS1_otl2a( m, A2, S1)
fig = figure;
tit = sprintf('2a-shooting: S1(2a), m=%g',m);
plot( A2, S1,'.','MarkerEdgeColor','r');
titlab(tit,{'2a','S1'});
prib('Дальше')
delete(fig)

%________нахожд реш Х, когда нач прибл берутся из УРовня = 0__________
function [X h varargout] = UR0( Di,   QS,   ...
                                KZ,   nT,  n,   Lw,  c,   NNM, ...
                                c_s,  GXm, m,   L,   setX, ...
                                DxHF, dva, avt, FND, RVN,RVS)                           
% hu  - h возможно уменьшенное
% Lw  - Lambda of working(рабочая частота)
% FND = 1,НАЙДЕН 1-й Х,=> SKX в к-м д.быть нужное и часто единств реш
% avt - выбор ветки вручную
global iNAs
DM = {'1. HF = NaN || сообщ',      '2. 0-уровня нет: мб hX велико', ...
      '3. Не найд инд для DxHF',   '4. После Solv'};
% if X0s == char => X = X0s = 
%   5. Lw вне сетки кривых
%   6. Lw в сетке кривых, но не в узлах
%   7a. Сетка XL мала для двух мод. Ув SX
%   7b. H%d%d-мода не умещается в SX'
%   8. Выход при выборе вручную VVV'
%   9. Lend-Lw < hL: захват мал 
%   +. KM=2, но найдена одна кривая. Нужнао расширить SX
%   *. KM=2, но avt=0(выбор вручную),=> можно выбрать только одну кривую
h = [];          
if nargout == 3,  varargout{1} = DxHF;  end
hL = L(2)-L(1);     
EH = 'EH+';
sm = sprintf('\nUR0: модa %s%d%d\n', EH(sum(NNM)), n, m);  

if QS == 2
   V_2QS = @V_22;  VEP = @VEP2;  HF_ar = @HF2_ar;  
   iNA   = [1 2];
else
   V_2QS = @V_23;  VEP = @VEP3;  HF_ar = @HF3_ar;
   iNA   = iNAs(nT,:);
end

LU = L( ...
       V_2QS( Di, KZ, nT, L.^2, dva) >= setX(1)^2);% L Уменьш(искл обл x>V)
[Lmm Xmm] = meshgrid( LU, setX );                  % meshgrid-м-цы(L,setX)
[eeLmm V_2mm ] = VEP( Di, KZ, nT, Lmm.^2, dva); 
[Z stAB stGD]  = HF_ar( nT, n, c, c_s, eeLmm, V_2mm, Xmm);                   

if all(isnan(Z)),  X = [DM{1} 'NaN' sm]; return,end
if ischar(Z) ,     X = [DM{1}  Z    sm]; return,end

lenX = length(setX);
if ~avt
   lenL = length(LU);  
   if Di, tL = '\lambda'; else tL = 'V';  end
   while true
      switch menu('Выбрать график','Каркас1','Каркас2','0-Уровни',...
        'контуры','Уровни+марк','Выход')
      case 1, meshc   ( Lmm, Xmm, Z);  
      case 2, meshz   ( Lmm, Xmm, Z);  
      case 3, contour ( Lmm, Xmm, Z, [0 0] );
      case 4, contour3( Lmm, Xmm, Z);
      case 5, [cHF,hHF] = contour( Lmm,Xmm,Z);    clabel(cHF,hHF);
      case 6, break
      end
      titlab(sprintf('nT=%d, 2a=%g, n=%d, m=%d, cетка %dx%d',...
             nT, dva, n, m, lenL, lenX ),  {tL,'X'});
   end
end
 
cHF = contourc( LU, setX, Z, [0 0]);
if isempty(cHF),  X = [DM{2} sm]; return,end

                         % нп HF(L,X)~0                         
[X0s hu] = NP0( Di,  QS, ...
                KZ,  nT,  n,   Lw,  NNM, m,  hL, ...
                dva, avt, FND, RVN, cHF);
if ischar(X0s)
   X = [X0s sm];  h = hu; 
   return
end
                      % Входные п-ры для Solv   
h    = hu(1:end-1);
L1   = Lw-2*h;         
qtRS = 5;
Xot  = GXm(1);
if Xot
   KZNA  = KZ(:, iNA); 
   dvapi = dva*pi;
   Lot0  = dvapi*sqrt( NA_2( Lw^2, KZNA))/Xot;
   Lot   = FLot( KZNA, dvapi, Xot, Lot0);
else     Lot = Inf;
end

if isnan(DxHF)
   iLw    = find(LU == Lw);
   [O iX] = min(abs(setX - hu(end)));
   if isempty(iX), X = [DM{3} sm];    return,end 
   Z1 = Z(iX+1, iLw);
   if iX ~= lenX && ~isnan(Z1)
         DxHF = (Z1       - Z(iX, iLw)) / (Xmm(iX+1,iLw)-Xmm(iX,iLw));
   else  DxHF = (Z(iX,iLw)-Z(iX-1,iLw)) / (Xmm(iX,iLw)-Xmm(iX-1,iLw));
   end  
end
    
X = Solv( Di,   QS,...
          KZ,   nT,  n,   c,   NNM, ...
          c_s,  GXm, m,   h,   L1, qtRS, ...
          DxHF, dva, Lot, X0s, 1,  RVS);
      
if nargout == 3,  varargout{1} = DxHF;  end
if ischar(X),     X = [DM{4} sm X];  return,end

%_____________ группа VEP ____________________________
%______________________________________________________
function [ eeVL V_2 ] = VEP2( Di, KZ, nT, VL2, dva)
% nT не исп
% KZ = KZ для СВ c дисп
% KZ = ee для СВ без дисп          
if Di
   n12 = n_2kZ( VL2, KZ(1:6,1));     
   n22 = n_2kZ( VL2, KZ(1:6,2));
   eeVL = n12./n22;  
   V_2  = (pi*dva)^2./VL2.*(n12-n22);                    
else
   eeVL = KZ;   
   V_2  = VL2;      
end

%______________________________________________________
function [ eeVL V_2 ] = VEP3( Di, KZ, nT, VL_2, dva)
% KZ = KZ для СВ c дисп
% KZ = ee для СВ без дисп   
if Di
   n12 = n_2kZ( VL_2, KZ(1:6,1));   
   n22 = n_2kZ( VL_2, KZ(1:6,2));
   n32 = n_2kZ( VL_2, KZ(1:6,3));

   if     nT==1;  D = n12-n32;
   elseif nT==2;  D = n22-n32;
   elseif nT==3;  D = n12-n22;
   else           D = n22-n12; 
   end
   eeVL = [n12./n22  n32./n22];
   V_2  = (pi*dva)^2./VL_2.* D;    
else
   eeVL = KZ;   
   V_2  = VL_2;  
end

%_____________ группа V _____________________________________________
%_____________V_2 для 2-сл СВ_________________________________________
function V_2 = V_22( Di, KZ, nT, VL2, dva) 
if Di
   V_2 = (pi*dva)^2./VL2.*(n_2kZ(VL2,KZ(1:6,1))-n_2kZ(VL2,KZ(1:6,2)));
else
   V_2 = VL2; 
end

%_____________V_2 для 3-сл СВ_________________________________________
function V_2 = V_23( Di, KZ, nT, VL2, dva) 
if Di
   if     nT==1,  D = n_2kZ(VL2,KZ(1:6,1))-n_2kZ(VL2,KZ(1:6,3));
   elseif nT==2,  D = n_2kZ(VL2,KZ(1:6,2))-n_2kZ(VL2,KZ(1:6,3));
   elseif nT==3,  D = n_2kZ(VL2,KZ(1:6,1))-n_2kZ(VL2,KZ(1:6,2));
   else           D = n_2kZ(VL2,KZ(1:6,2))-n_2kZ(VL2,KZ(1:6,1));
   end
   V_2 = (pi*dva)^2./VL2.* D; 
else
   V_2 = VL2;
end

%___________________________Нач.Прибл из 0 уровня хар.функции___________
function [X0s hu] = NP0( Di,  QS, ...
                         KZ,  nT,  n,   Lw,  NNM, m, hL,...
                         dva, avt, FND, RVN, cHF)  
% if X0s ~= char => найдено 2 нач пр Х на 5-сетке, накрывающей Lw
% if X0s == char => cообщ передается в UR0
% FND = 1, НАЙДЕН 1-й Х,=>SKX в к-м д.быть нужное и часто единств реш
% GLU - глубина сетки
hu  = [];
tol = 1e-6*hL;
KM  = numel(NNM);         % к-во искомых мод

L   = cHF(1,:);
X   = cHF(2,:);
qL  = numel(L);  
iLw = find( L == Lw );    % iLw = abs(L-Lw) < 1e-10;
Lb0 = L(L>0);
Lma = max( Lb0 );
Lmi = min( Lb0 );
qLw = numel(iLw);
if ~qLw  
   if Lma<Lw || Lmi>Lw,  X0s = '5. Lw вне сетки кривых';
   else                  X0s = '6. Lw в сетке кривых, но не в узлах'; 
   end
   return
end

Epe = 1+1e-4;             % Ed plus eps
if Lma < Epe*Lw || Lw < Epe*Lmi
   X0s = '0. Малый захват: DL < 0.0001*Lw';
   return
end

if qLw <= 2 || avt
   avt2 = true;
   if qLw == 1
      if KM == 2
         X0s = sprintf('7а. Cетка XL мала для двух мод. Ув Х');
         return
      end 
      
      if ~FND             % НАЙДЕН 1-й Х
         if m ~= 1 && NNM == 2
            X0s = sprintf('7б. H%d%d-мода не умещается в SX',n,m);
            return
         end
      end
   else
      if qLw == 2
         if X(iLw(1)) < X(iLw(2)),  qLw = 1:2;                     
         else                       qLw = [2 1];  end
      else                % qi >= 3
         qLw = [0 0]; 
         [mi qLw(1)] = min( X(iLw) ); 
         iLw(qLw(1)) = [];
         [mi qLw(2)] = min( X(iLw) );
      end        
      if KM == 1,  qLw = qLw(NNM);  end
   end
   iw = iLw(qLw);
   
   okk = numel(qLw);    %  окончательное к-во кривых     
   if KM ~= okk
      X0s = sprintf(['+. К-во искомых мод KM=%d),\n' ...
                     'но найдено кривых %d.\n' ...
                     'Нужнао расширить SX'], KM, okk); 
      return
   end
else
   if KM ~= 1
      X0s = sprintf(['*. Режим avt=%d (Выбор вручную),=>\n' ...
                     'можно выбрать только одну моду, но\n' ...
                     'К-во искомых мод KM=%d, =>\n' ...
                     'Поменять режимна avt=1 или поменять NNM'],...
                     avt, KM );
      return
   end
   avt2 = false;
   prib(['!! Нужно выбрать кривую, соотв-щую %s-моде,\n' ...
         'иначе будут записаны данные для другой моды !!'], EH(NNM));
            
   i = 2;  k = 1;          % выч: кол-во, длина кривых и нач. номер кривых 
   while i <= qL           % nn = №№ начал и концов кривых из cHF
      nn(1,k) = i;     i = i+X(i-1)+1;
      nn(2,k) = i-2;   k = k+1; 
   end
  
   V  = VVV( Di, QS, KZ, nT, n,NNM,m,dva, cHF, q, nn);  
   if isempty(V),  X0s = '8. Выход при выборе вручную VVV';  return,end
end

MZ  = RVN(1);
GLU = RVN(2);
X0s = nan(2,KM);
hu  = nan(1,KM);
hL2 = 2*hL;
for k = 1:KM 
   if avt2
      qL_1 = qL-1;
      iwk  = iw(k); 
      if L(iwk-1) == 0  || iwk == qL  ||  L(iwk+1) == 0
         X0s = '0. Малый захват: Lw - концевая точка';
         return
      end
      sig  = Lw > L(iwk-1);  % знак приращения L в таблице cHF
      sigt = sig;  
      
      iL = iwk;              % ищем границу слева от Lw
      while L(iL-1) ~= 0 && sig == sigt
         iL   = iL-1;  
         sigt = L(iL+1) > L(iL);
      end
      
      iR = iwk;              % ищем границу справа от Lw
      if sigt == sig         % слева слияния нет 
         while iR <= qL_1 && L(iR+1) ~= 0 && sig == sigt
            iR   = iR+1;
            sigt = L(iR) > L(iR-1);
         end                 
      else                   % слева - слияние,=> справа б.простой цикл          
         while iR <= qL_1 && L(iR+1) ~= 0,  iR = iR+1;  end
      end

      Li = L( iL:iR );  
      Xi = X( iL:iR );
      if L(iL) > L(iR)
         Li = fliplr(Li); 
         Xi = fliplr(Xi);
      end
      
   else                   % avt2 = 0 (выбор ветки вручную)
      Li = V(1,:); 
      Xi = V(2,:); 
      if Li(1) > Li(end)
         Li = fliplr(Li); 
         Xi = fliplr(Xi);
      end
   end
  
   G1  = Lw-hL2;       G2 = Lw+hL2;    % ГАБариты сетки
   h   = hL;
   iL1 = abs(Li-G1) < tol;
   iL2 = abs(Li-G2) < tol;
   cc  = 1;
   while ~any(iL1) || ~any(iL2)  % пока хотя бы один пустой
       if cc == GLU,  break,end
       G1  = G1+h;     G2 = G2-h;
       iL1 = abs(Li-G1) < tol;
       iL2 = abs(Li-G2) < tol;
       h   = 0.5*h;  
       cc  = cc+1;  
   end
          
   if cc < GLU,   hu(k) = h; % накрыто 5-сеткой: Х2 мб опр точно, но    
   else                      % опр (X1+FL)/2 д/единообразия со случ сс>GLU 
      G1  = G1+h;     G2 = G2-h;
      iL1 = abs(Li-G1) < tol;
      iL2 = abs(Li-G2) < tol;
      if ~any(iL1) || ~any(iL2)  
         if ~MZ              % при малом захвате Lw ищем Х при этом же 2а              
            hmi = min(Lw - Li(1), -Lw + Li(end));
            while h > hmi+eps,  h = 0.5*h;  end 
            if any(iL1),  iX1 = iL1;  else  iX1 = 1;  end
            if any(iL2),  iX2 = iL2;  else  iX2 = numel(Li); end 
            X0s = '9. Lend-Lw < hL: захват мал';
            hu  = [ h  Xi(iX2) Xi(iX1) ]; 
         else         % при малом захвате Lw переходим к след 2а       
            X0s = sprintf(['0. Малый захват %g %g при фикс глубине\n',...
                  'трактуем как неудачу\n'],Li(1),Li(end),Lw); 
         end
         return
      else    hu(k) = 0.5*h; % накрыто 5-сеткой: Х2=(X1+FL)/2 
      end
   end
   X1 = Xi( iL1 );
   Xw = Xi( abs(Li-Lw) < tol );
   hu = [ hu  Xw ];                         % Xw: HF(Lw,Xw) = 0
   try X0s(:,k) = [X1;  0.5*(X1+Xw)]; 
   catch ME
       k,X0s(:,k),X1,Xw,dva, ME.message
   end
end

%___________ Выбор Ветви Вручную для кривых, числом > 2____________
function V = VVV(  Di, QS, KZ, nT, n,NNM,m, dva, cHF, q, nn)
if Di, labx = '\lambda'; else labx ='V'; end
lab = {labx,'X'};   
Curs = cell(1,q);
EH = 'EH+';
for k = 1:q
   n1 = nn(1,k);  n2 = nn(2,k);
   Curs{k} = sprintf('%2g)%5g;   %g %g',k,n2-n1+1,n1,n2);
end

fig = figure;
for k = 1:q
   SN  = nn(1,k) : nn(2,k);             %сетка номеров
   SNT = [SN(1) SN(round(end/2)) SN(end)];
     
   if QS == 3,  P = NaN;
   else 
      P = POW( n, ...
               V_22( Di, KZ, nT, cHF(1,SNT(2))^2, dva ), ...
               cHF( 2, SNT(2)) );
   end
    
   plot(cHF(1,SN),cHF(2,SN));
   nn = str2num( Curs{k}(12:end));
   T  = {sprintf('beg=%g',nn(1)), sprintf('%g) P=%g',k,P),...
         sprintf('end=%g',nn(2))};
   text(cHF(1,SNT),cHF(2,SNT),T,'FontSize',7);
   hold on
end
         
titlab(sprintf('nT=%g, 2a=%g, %s%g%g', nT, dva, EH(sum(NNM)),n,m), lab);
hold off
V = VybRedCur( Di, cHF, Curs); 

prib('Выбор кривой закончен')
delete(fig)

%____________Выбор и редактир-е кривой_________________________________
function V = VybRedCur( Di, cHF, Curs)%
if Di, labx = '\lambda'; sig = -1;
else   labx = 'V';       sig =  1; end

lab  = {labx,'X'}; 
Lmen = length(Curs)+1;
fig  = figure;
kPl  = 0;
while true
   men = menu('Выбор нач. кривой',[Curs 'Выход']);
   if men == Lmen || men == 0,    V = '';  return,end
   
   Vt  = VybCur( cHF, Curs, men);     
   kPl = mod(kPl,4)+1;
   subplot(2,2,kPl)
   nn  = [1 size(Vt,2)];   
   t   = [Curs{men} '.'];      
   while true  
      nn = inpRI(t,nn,'NN',nn,'length(I)==2',NaN);
      SN = nn(1):nn(2); 
      V  = Vt(:,SN);
      plot( V(1,SN), V(2,SN) );  
      titlab(t,lab);
      text(V(1,1)  ,V(2,1)  ,sprintf('beg=%g',nn(1)));
      text(V(1,end),V(2,end),sprintf('end=%g',nn(2)));
      
      if length(SN)>1 && sig*(V(2,end)-V(2,1)) <= 0
         prie('VybRedCur: x(1:end)=[%g %g] с разных веток',...
         V(2,1),V(2,end)); 
      end
 
      switch menu('','OK','Редактировать дальше','На пред уровень')
      case 1, return
      case 2, continue
      case 3, break;  
      end
   end
end

prib('Редактирование кривой закончено')
delete(fig)

%_____________Выбор кривой_____________________________________________
function LX = VybCur( cHF, Curs,N ) 
nn = str2num(Curs{N}(12:end)); 
LX = cHF(:, nn(1):nn(2));
if cHF(1,nn(1)) > cHF(1,nn(1)+1),  LX = fliplr(LX);   end  

% _____________________________________________________________________
function X = Solv( Di,   QS,    ...
                   KZ,   nT,  n,   c,   NNM, ...
                   c_s,  GXm, m,   h,   VL1, qL, ...
                   DxHF, dva, Lot, X0s, EXT, RVS)         
% X0s = [x1 x2];                       
% EXT = 0:  X0s - прибл зн-я; x0=X0s(i=1:2); экстр х0 назад  с 3й итерации
% EXT = 1:  X0s - прибл зн-я; x0=X0s(i=1:2); экстр х0 вперед с 3й итерации
% EXT = 2:  X0s - точные зн-я;               экстр х0 назад  с 1й итерации 
% EXT = 3:  X0s - точные зн-я;               экстр x0 вперед с 1й итерации
% DxHF - знак производной х.ф HF в НЕ-корне(истинном)
global  TSV TFL stat
%_________________________1 Общие данные_______________________________ 
Ty   = TSV{nT};
EH   = 'EH';
KM   = numel(NNM);         % к-во мод
tol  = 1e-12; 
onetol = 1+tol; 
Xtol = X0s(1,1)*tol;
eps2 = eps*2;
X    = nan(max(qL),KM);       
Xot  = GXm(1); 
Xf   = GXm(2);
if Di,  lab = {'\lambda' 'x'};     else    lab = {'V' 'x'}; end 

if     EXT == 0,  i0 = 1;  h = -h;
elseif EXT == 1,  i0 = 1;  
elseif EXT == 2,  i0 = 3;  h = -h;  
else              i0 = 3;  
end
              
if QS == 2
   VEP = @VEP2;  HF = @HF2;   KO = []; 
   if m == 1,   Pist = 1; 
   elseif KM == 1     
      if NNM == 1, Pist  = -1;
      else         Pist  =  1;  end
   else            Pist2 = [-1 1];
   end
else
   VEP = @VEP3;  HF = @HF3;
end

dd  = 0.1;
inf = '';

%_____________________2 Цикл: поиск корней____________________________
for k = 1:KM
 RRK  = NaN;   
 NNMk = NNM(k);
 zNNM = sign(NNMk-1.5);
 EHk  = EH(NNMk);
 FL   = 0; 
 qx0  = 1;
 ILK0 = ~RVS(1);     ILK    = ILK0;     
 SOS  = false;       firSOS = true;
 if QS==2 && KM == 2 && m ~= 1,  Pist = Pist2(k); end % учет моды для 2-СВ
 q    = qL(k); 
 qeq5 = q==5;
 VL1k = VL1(k);
 VL   = VL1k + (i0-2)*h;  
 VL9  = VL1k + (q-1) *h; 
 L = (VL1k : h : VL9+h*0.5)';
 
 if EXT ~= 1
    if size(X0s) ~= [2 1]
       prie('Начальные значения дб столбцом длины 2'),  return,end
    X(1:2,k) = X0s(:,k);
 end
    
 i = i0;  
 while i <= q 
   t2 = '';
   if FL <= 8 || FL >= 20   % при первом входе или переходе к след точке 
      VL  = L(i);           % текущее    VL 
      VLp = VL-h;           % предыдущее VLp = L(i-1)
     
     [eei V_2] = VEP( Di, KZ, nT, VL^2, dva);
     V    = sqrt(V_2);      % так сделано, чтобы 
     V_2  = V^2;            % V^2 было точно равно V_2
     dV   = V*eps2; 
     Veps = V-dV;      
     
     if    i <= 2
        x0e = X0s(i,k);  
        if i == 1,   hx = abs(X0s(2,k) - x0e);
        else         hx = abs(x0e - Xp);  end

        if x0e < 1e-10,  x0 = [0;4*x0e];
        else             x0 = [x0e-hx;  min(x0e+hx,Veps)];  end
        ILK = 2;
     else
        if     Di ==0, x0e = extDLfV( Xf, X(i-2:i-1,k));
        elseif EXT==2, X1 = X(i-1,k);  x0e = X1+h*(Xf-X1)/VLp;
            % x0e = extDLf ( Xf, [VLp-h;VLp], X(i-2:i-1,k));
        elseif n==1 && m==1,  x0e = extDLo1( X(i-2:i-1,k) );
        else           x0e = extDLo( Lot, Xot, [VLp-h;VLp], X(i-2:i-1,k));         
        end
        x0 = x0e; 
        if i == 3
           if i0 == 3,  hx = abs(x0e - X0s(2,k));  end % 
           x0  = [x0e-hx;  min(x0e+hx, Veps)];
           ILK = 3;
        else
           hx = abs((x0e-Xp));
           if ~qeq5   % APe - а.п экстрап-я
              AP1 = abs(x0ep-Xp);  % абс погр на пред шаге(выч через х0е)  
              if i == 4,   APep = AP1;  APe = AP1;  RxVe = abs(V-x0e); 
              elseif APe,  APep = APe;  APe = min(AP1, AP1^2/APe);
              else         APe  = AP1;  
              end  
              
              if EXT ~= 2
                 RxV  = Vp-Xp;            % расстояние до V на пред шаге
                 AP2  = abs(RxV-RxVe);    % абс погр (выч через V)
                 RxVe = RxV^2/RxVe;       % расстояние экстраполируемое
              end
           end
           if x0 >= V,    ILK = 1;  end
           
           if ILK == 1 
             if qeq5 || i <= 3,   x0 = [x0e-hx;  min(x0e+hx*0.5, Veps)];
             else  
               if EXT ~= 2          
                 if AP1 < AP2
                   if APep < hx && APe < hx
                     x0=[x0e-8*APe;min(x0e+4*APe,Veps)];stat(1)=stat(1)+1;               
                   else
                     x0=[x0e-hx; min(x0e+hx*0.5,Veps)]; stat(3)=stat(3)+1;                
                   end            
                 else
                   x0=[V-(1+2*dd)*RxVe;V-(1-dd)*RxVe];  stat(5)=stat(5)+1;                 
                 end       
               elseif APep < hx && APe < hx   % EXT==2
                 x0 = [x0e-3*APe; x0e+3*APe];           stat(2)=stat(2)+1;
               else
                 x0 = [x0e-hx;    x0e+0.5*hx];          stat(4)=stat(4)+1; 
               end
             end
           end           
        end
     end
        
     qx0 = 1;
     if QS == 3       
        if isnan(RRK),  tolIZO = 0.01*hx;
        else            tolIZO = RRK;  end
        [KOx A B] = ooHF3( nT, n, c, c_s, eei, V_2, x0, tolIZO);
        qx0 = size(KOx,1);
        if qx0 == 2,  KO = KOx(1,:);  x0 = [A-tolIZO; A];
        else          KO = KOx;  end
     end    
  end
  % строка-отладка  
%figure;a_=51;b_=52;[ko A B]=ooHF3(nT,n,c,c_s,eei,V_2,a_,APe);h_=(b_-a_)/100;x_=a_:h_:b_;y_=HF(nT,n,c,eei,V_2,x_,ko);plot(x_,y_);title(sprintf('m=%d i=%d ko=%d x0=%g %g',m,i,ko(2),x0));grid
  f  = HF( nT, n, c, eei, V_2, x0, KO);
  if ILK                                             
     f1 = f(1);  f2 = f(2);  
     if f1*f2 > 0
        if SOS &&  m==1 && x0(2) == Veps 
           if EXT ~= 2
              FL = 4;  
              hh = (V-Veps)/2;
              xx = V-8*hh : hh : V;
              [fv imi] = min(abs(HF( nT, n, c, eei, V_2, xx, KO )));
              Xp = xx(imi); 
           end
        else
           [x0 FL KO t1] = SigIA ( nT,   n,  c,   NNMk,    ...
                                   DxHF, HF, eei, V,    KO,...
                                   x0,   f,  Xot, Veps, RRK);
           if     FL == 5,  Xp = x0;              
           elseif FL == 27
              if isempty(inf)
                 inf = infSolv(Ty,EHk,n,m,dva,V,EXT,i,q,VL,VL1k,VL9,h);
              end
              [x0 FL t1] = SigI( sprintf('Анализ\n%s\n%s',inf,t1), QS,...
                                nT,   n,  c,   NNMk, c_s, m, ...
                                DxHF, HF, eei, V,    KO,     ...
                                x0,   f,  Xot, Veps, RRK); 
              if FL == 5,   Xp = x0; 
              elseif ~isempty(t1), prie(['SigIA->SigI->SigIA\n' t1]); end
           end
        end        
     
     elseif f1 == 0,  Xp = x0(1);  fv = 0;  FL = 7;
     elseif f2 == 0,  Xp = x0(2);  fv = 0;  FL = 8; 
     end
  end
               
  if FL == 0 || FL == 0.5  || 9 <= FL && FL <= 20
     out = '';
     try 
       if k == 1, [Xp,fv,FL,out] = fzero(@(x) HF(nT,n,c,eei,V_2,x,KO),...
                                   x0,optimset('Display','off'));
       else       [Xp,fv,FL,out] = fzero(@(x)...
                                   HF(nT,n,c,eei,V_2,x,KO)/(x-X(i,1)),...
                                   x0,optimset('Display','off'));
       end         
     catch ME, FL = 24;           % Не дб. К сл.т.
     end         
  end                   
    
  if 1 <= FL && FL <= 8
     if Xp < Xot || Xp > Xf,      FL = 20;
     else 
        if ~qeq5 && i > 3             % есть ли переСКОК через корень ?
           if abs(Xp - X(i-1,k)) > 1  % &&  D1 > 3*( X(i-1,k) - X(i-2,k)) 
              if qx0 == 2             % ЕСТЬ !
                 qx0 = 3;
                 x0 = [B; B+hx];  KO  = KOx(2,:);
                 FL = 9;          ILK = 7;                
              else    
                 %[nEXT x0 KO RRK i] =TUNING( nT, n,c, eei,  V_2, x0, i,...
                 %                            KOx,A,B, L, X, EXT, Xot,Xf);
                 figure
                 a_ = x0(1);b_=x0(2);
                 h_ = (b_-a_)/100;    x_= a_:h_:b_;
                 y_ = HF(nT,n,c,eei,V_2,x_,ko);plot(x_,y_);
                 title(sprintf('m=%d i=%d ko=%d x0=%g %g',m,i,ko(2),x0))
                 grid
                 X = 'Дальше выход';  prib(X)
                 return
              end 
              continue
           end    
        end
        
        SOS = (HF(nT,n,c,eei,V_2,Xp*onetol,KO)-fv)*DxHF < 0;
        
        if QS == 2                % опр СОСКОКа для 2СВ
           if (POW( n, V_2, Xp)*Pist < 0) ~= SOS  
              fig = figure;
              plot( L(1:i-1), X(1:i-1,k)-X(2:i,k));
              titlab('Соскок. Первые разности X',lab); grid on
              if isempty(inf)
                 inf = infSolv(Ty,EHk,n,m,dva,V,EXT,i,q,VL,VL1k,VL9,h);
              end
              SOS = mod(menu(sprintf('%s Xp=%g\n%s\nSOS=%d SOS2=%d',...
                          inf,Xp,t2,SOS,~SOS),...
                    'Соскок есть','Соскока нет'),2); 
              delete(fig);
           end
        end
        
        if SOS
           XpE = Xp;          % Xp сопряженной ( обычно Е ) моды
           if m == 1
              if isempty(inf)
                 inf = infSolv(Ty,EHk,n,m,dva,V,EXT,i,q,VL,VL1k,VL9,h);
              end
              X = ['Solv: Не МБ: Cоскок при m=1\n' inf]; return                               
           elseif firSOS
              firSOS = false;
              FL = 16;                                            % E-мода
              if NNMk == 1,   x0 = Xp - [hx; Xtol];               ILK = 4;  
              else                                                % H-мода    
                 if EXT ~= 2, x0 = Xp + [Xtol; (Veps-Xp+hx)*0.5]; ILK = 5;                               
                 else         x0 = Xp + [Xtol; hx];               ILK = 6;
                 end                       
              end
           else
               X  = ['Solv: Не МБ: 2-й соскок\n' inf]; return
           end
        end 
     end
 
  elseif FL <= -3                        % f=Cmp|NaN|Inf|Sing
     if ~ILK,  ILK = 1;  FL = 17;  else  FL = 22; end
  end

  if 1 <= FL && FL <= 8                  % К след(i+1-му) корню 
     if     ILK == 0,  stat(6) = stat(6)+1;
     elseif ILK == 1,  stat(7) = stat(7)+1; end      
     X(i,k) = Xp;     
     x0ep   = x0e;    
     Vp     = V;     
     firSOS = true; 
     if SOS,  RRK = zNNM*(Xp-XpE)*0.5;  end
     SOS    = false;            
     FL     = 0; 
     ILK    = ILK0;  
     i = i+1;  
  elseif FL < 20                 % попытка найти корень в текущей точке
     if RVS(2)
        t2 = sprintf('i=%d, ILK=%d\nx=%d\n%s', i,ILK,Xp,TFL{round(FL)});
        if ~isempty(out)
           t2 = [t2 sprintf('\nf(x)=%d:%s',fv,out.message)]; end
        prib(t2)
     end      
  else                      % Корень не найден.Печать переменных.Выход
     if isempty(inf)
        inf = infSolv( Ty, EHk, n,m, dva, V, EXT, i,q, VL,VL1k,VL9,h);
     end 
        
     to = sprintf(['%s\nSolv: Реш не найдено\n' ...  % текст отладочный
          '%s\nILK=%d\n'...
          'x0=[%3.17g %3.17g]\nV=%3.17g\n'...
          'f1=%g, f2=%g\nFL=%g, qx0=%d'],...
          TFL{round(FL)}, inf, ILK, x0(1), x0(end),...
          V, f(1), f(end), FL, qx0);
      
     if     FL == 24,  X = sprintf('%s\n%s\n', ME.message, to); 
     elseif FL == 25,  X = to; 
     else              X = sprintf('%s\n%s\n', out.message, to);
     end 
     return 
  end
 end % цикла по i
end  % цикла по k

if h < 0,  X = flipud(X);  end

%_______ ДОВОДКА п-ров вручную после проскакивания корня
function [nEXT x0 KO RRK i] = TUNING( nT, n,c, eei, V_2, x0, i, tol,...
                                      qx0, KOx,A,B, L,  X, EXT, Xot, Xf)
 if qx0 == 1
    if EXT == 2 || EXT == 0,  ILx = [X0s(1) Xf];
    else                      ILx = [Xot   X0s(1)];  end        
    [KOx A B ] = ooHF3( nT, n, c, c_s, eei, V_2, ILx, tol);
    
 end
    

% ____________Выч дисп S1 = v_S1( Solv( X0)) для FZERO, 
% где Х0-интерполяция для 2а: А<2а<B при известных Х(А) и Х(В)_______
function SC = v_S1_Solv( Di,   QS,...
                         KZ,   nT,  n,   c,    NNM, ...
                         c_s,  GXm, m,   h,    L5,  qtRS,...
                         DxHF, dva, Xot, nmax, iNA, RVS )
global XC__  A__  B__  XA__  XB__  SA__  Lot__
 
XC0 = ((B__-dva)*XA__+(dva-A__)*XB__)/(B__-A__);

if Lot__ ~= Inf
   Lot__ = FLot( KZ(:, iNA), dva*pi, Xot, Lot__);  end

XC__ = Solv( Di,   QS,...
             KZ,   nT,  n,     c,   NNM, ...
             c_s,  GXm, m,     h,   L5(1), qtRS, ...
             DxHF, dva, Lot__, XC0, 1, RVS);
if ischar(XC__)
    SC = XC__;  fprintf(SC);
else
    SC = v_S1( L5, h, XC__, dva, nmax); 
    if SA__*SC < 0
        if A__ ~= dva,  B__ = dva;  XB__ = XC__(1:2);  end
    elseif B__ ~= dva,  A__ = dva;  XA__ = XC__(1:2);  SA__ = SC; 
    end
end

%_____________ЭКСТРАПОЛЯЦИИ _____________________________________________
%_____________ ОТСЕЧКА __________________________________________________
% ____________Экстр-я Др-Лин к L=Lo(ots)=Inf  (n=1)______________________
function X3 = extDLo1(X)  
X3 = X(1)*X(2)/(2*X(1)-X(2));

% ____________Экстр-я Др-Лин к L=Lo(ots)(n>1) на шаг h=L2-L1_____________
function X3 = extDLo( Lo, Xo, L, X) 
% X=(a*L+b)/(L-c). В данной задаче используется ВПЕРЕД
% База экстрап = [L1 L2 Lo]
Lo1  =  Lo-L(1);          
Lo22 = (Lo-L(2))*2;   
Lo3  =  Lo22-Lo+L(1);
X3   = ( -X(1)*( Xo*Lo1 + X(2)*Lo3 ) + Xo*X(2)*Lo22) / ...
       (X(2)*Lo1 + Xo*Lo3 - X(1)*Lo22);
   
% ____________Экстр-я Др-Лин к L=Lo(ots)(n>1) в произвольную точку L3 
function X3 = extDLoh( Lo, Xo, L, X, L3) 
% X=(a*L+b)/(L-c). В данной задаче используется ВПЕРЕД
% База экстрап = [L1 L2 Lo]
Lo3 = Lo-L3;    L23 = L(2)-L3;   L13 = L(1)-L3;
L1o = L(1)-Lo;  Lo2 = Lo-L(2);   L21 = L(2)-L(1);
X3  = -( Lo3*L21*X(1)*X(2) + L23*L1o*X(1)*Xo + L13*Lo2*X(2)*Xo) / ...
       ( Lo3*L21*Xo        + L23*L1o*X(2)    + L13*Lo2*X(1) );
    
%_____________ ДАЛЕКИЙ РЕЖИМ ____________________________________________    
%_____________ Экстр-я Др-Лин к L=0(far)  л.7 ТСВ2 ______________________
function X3 = extDLf( Xf, L, X)    
% X=(a*L+Xf)/(c*L+1),   В задаче Svetovod используется экстр-я НАЗАД
% База экстрап = [0 L1 L2]
d1 =   L(1)*(Xf-X(2));  
d2 = 2*L(2)*(Xf-X(1));
X3 = (d1*X(1)-d2*X(2))/(d1-d2);
%_____________ Экстр-я Лин к L=0(far)  ТСВ3-6 ______________________
function X = extLf( Xf, L1, X1, L)    
X = X1-((Xf-X1)/L1)*(L-L1);

%_____________Экстр-я кубич к L=0(far)  л.7 ТСВ2 ______________________
function X4 = ext3f( Xf, L, X, L4)    
% X=a*L^3+b*L^2+c*L+Xf.  В задаче Svetovod используется экстр-я НАЗАД
% База экстрап = [0 L1 L2 L3]
C   = [L.^2 L [1; 1; 1]] \ ((X-Xf)./L);    % реш СЛУ
L42 = L4^2;
X4  = [L42*L4 L42 L4]*C + Xf;

%_____________Экстр-я Др-Лин к L=0(far) в произвольную точку L3 _________
function X3 = extDLfh( Xf, L, X, L3) 
A  = L(1)*L3  * ( X(2)-Xf );
B  = L(2)*L3  * ( Xf  -X(1) );
C  = L(1)*L(2)* ( X(1)-X(2) );
X3 = ( A*X(1) + B*X(2) +C*Xf ) / (A+B+C);

%_____________Экстр-я Дробно Лин к V=INF(ВПЕРЕД)_________________________
function X3 = extDLfV(Xf,X)
% X=(Xf*V+A)/(V+B). 
% База экстрап = [ V1 V_2 Inf ]
% Исрп-ся в DVAX, где Xmin=X(dva) 
% и в Solv для Di=0, когда n=const и X=X(V)
% V~dva => ф-лы зависимостей X(dva) и X(V) одинаковы
X3 = (Xf*(X(2)-X(1))+X(2)*(Xf-X(1)))/(Xf-2*X(1)+X(2));

%_________ группа SigI ______________________
%________ m > 1 Одинак Знак на концах И-ла: Авт опр и-ла локализации ___
function [x0 FL KO t] = SigIA( nT,   n,  c,   NNMk, ...
                               DxHF, HF, eei, V,    KO, ...
                               x0,   f,  Xot, Veps, RRK)
% л.50
% 1. Найден КИН,            => х0 = КИН,    FL = 0.5
% 2. Найден корень          => x0 = корень, FL = 5
% 3. Считать, что корня нет,=> х0 = х0 вх,  FL = 27
% RRK = (xH-xE)/2 - радиус разности корней
% f = HF(x0)

t = ''; 
V_2 = V^2;    
A  = x0(1);  Cmi = A;
B  = x0(2);  Cma = B;  
fB = f(2);    zfB = sign(fB); 
C  = (A+B)*0.5; 
fC = HF( nT, n, c, eei, V_2, C, KO );
if fC*zfB < 0                 % ТСВ2-36 п.5 
   if NNMk == 2,  x0 = [C; B]; 
   else           x0 = [A;C];  end
   FL = 0.5;
   return
end    

Ke   = 100;      
Ce   = C*(1-Ke*eps);     
fCe  = HF( nT, n, c, eei, V_2, Ce, KO);
Df   = fC-fCe;
fD   = -fC/Df;          
firK = true;                        % 1-й найденный корень - истиный

zzz  = [fD Df*DxHF]*(NNMk-1.5) > 0; % знак(hC) = знак(fD), ТСВ3-3
zhC  = sign(fD);

NV   = zzz*(1:2)';                  % ТСВ3-5
if     NV == 1;  firK = false;           
elseif NV == 0,  zhC  = -zhC; end
 
if isnan(RRK), h = zhC*min( (B-A)*0.25, abs((C-Ce)*fD) ); % h дб < (B-A)/2
else           h = zhC*RRK;   end  

fCp = fCe;
e1  = eei(1);  
e3  = eei(2);   
e1_1 = e1-1;   e1_e3 = e1-e3;  E_e3 = 1-e3;
IZKO = false;     % изменение знака KO
while abs(h) > 100*eps
   C = C+h;
   if C > Veps  
      if DxHF*(fC-fCp)/h > 0     %  x = {x:min(|HF(x)|)} ~ Veps
         hh = (V-Veps)/2;
         xx = V-8*hh : hh : V;
         [fv imi] = min(abs(HF( nT, n, c, eei, V_2, xx, KO)));
         x0 = xx(imi);
         FL = 5;
         return
      end
      
      A1 = (A+Xot)*0.5;
      C  = B;
      h  = 1.5*(V-B);
      while C > A1
         h = 2*h;
         C = C-h;
         fC = HF( nT, n, c, eei, V_2, C, KO);
         if fC*zfB < 0
            if NNMk == 2,  x0 = [C;  C+h]; 
            elseif A < C,  x0 = [A;  C];
            else           x0 = [A1; C];
            end
            FL = 0.5;
            return
         end
      end
      FL = 27;
      t = sprintf('Л50: б,в,е,ж. B~V\nКорень дб влево от B\nC=%g',C);
      return
   end
   
   if ~IZKO
      if C > Cma || C < Cmi
         if C > Cma,  Cma = C;
         else         Cmi = C;  end

         if     nT == 1      
            x12 = C^2;      
            x32 = V_2-x12;     
            zVS = sign((E_e3*x12 - e1_1*x32)/e1_e3);  % = x22z
            nVS = 2:3;
         elseif nT == 2      
            x22 = C^2;     
            x32 = V_2-x22;      
            zVS = sign((e1_e3*x22 + e1_1*x32)/E_e3);   % = x12z
            nVS = 1;
         end
         
         if zVS * KO(nVS(1)) < 0
            IZKO = true;
            KO(nVS) = zVS;
            [A C] = IZO( nT, e1, e3, V_2, [C-h C], zVS, 1e-6 );
            fC = HF( nT, n, c, eei, V_2, C, KO);
            C  = C+h;
         end        
      end
   end
   
   fCp = fC;  
   fC  = HF( nT, n, c, eei, V_2, C, KO);
   if fCp*fC < 0 
      if ~firK,    firK = true;      
      else
         if h>0,   x0 = [C-h; C  ];        
         else      x0 = [C;   C-h];  end    
         FL = 0.5;
         return 
      end
      
   elseif fC == 0
      if ~firK,    firK = true;
      else         x0 = C;     FL = 5;  return,end 
      
   elseif abs(fC) > abs(fCp)   && ...   % маятник при перепрыгивании КИН
          ( NV == 1 && ~firK   ||  NV == 2 )      
      C  = C-h; 
      fC = fCp;
      h  = -h*0.5;
      NV = 3-NV;
      firK = ~firK;
   end    
end 
t = sprintf('КИН не найд\n№ вар=%d, C=%g, fC=%g, fCпред=%g',NV,C,fC,fCp);
FL = 27;

%________анализ и-ла х0, if Знаки f0 на его концах совп-ют  ______________
function [x0 FL t] = SigI( t,    QS,  ...
                           nT,   n,  c,   NNMk, c_s, m, ...
                           DxHF, HF, eei, V,    KO,...
                           x0,   f0, Xot, Veps, RRK )
% Одно из 3-х
% 1. Найден КИН,            => х0 = КИН,    FL = 0.5
% 2. Найден корень ~ Veps;  => х0 = корень, FL = 5
% 3. Считать, что корня нет,=> х0 = х0 вх,  FL = 25

% f0 = HF(x0)
V_2 = V^2;    
x02 = x0(2);    fB = f0(2);
fVeps = HF( nT, n, c, eei, V_2, Veps, KO);
if fB*fVeps < 0,  x0 = [x02; Veps];  FL = 0.5;  return,end

x01 = x0(1);        fA  = f0(1);        
A   = x01;          B   = x02;        
qt  = 20;           h   = (V-A)/qt;
x   = A : h: V+h/2;              
y   = HF( nT, n, c, eei, V_2, x, KO);
fV  = fVeps;        KOx = [];

hf = figure('name',sprintf('Анализ КИН. m=%d',m), 'MenuBar', 'none');
while true
   if x01 >= x(1),    A0 = x01;  fA0 = fA; else  A0 = NaN;  fA0 = NaN; end
   if x02 <= x(end),  B0 = x02;  fB0 = fB; else  B0 = NaN;  fB0 = NaN; end
  
   plot( x,y, A0,fA0,'.k', B0,fB0,'.k', Veps,fV,'.r');  grid on;    
   YLim  = get(gca,'YLim');   Y1 = YLim(1);
   YTick = get(gca,'YTick');  hY = (YTick(2)-YTick(1))/4;
   titlab(t, {'x','HF'})
   text([A0 B0 Veps], [Y1+hY Y1+hY fV+hY], {'x_{01}' 'x_{02}' 'V'})
   text([A0 B0] , [Y1 Y1], {'\bullet' '\bullet'})
   
   me = menu('','1. Удвоить диапазон',...
                '2. Изменение диапазона',... 
                '3. Выбор корневого ин-ла вручную',...
                '4. Деление отрезка на 2',...
                '5. Корня в этом и-ле нет');
   if     me == 1
      d = (B-A)*0.5;
      A = A-d;    B = B+d;
      if A <= 0,  A = eps;  end
      if B >= V,  B = V; end
      h = (B-A)/qt;
      x = A : h: B+h/2;
      y = HF( nT, n, c, eei, V_2, x, KO);
      
   elseif me == 2    
      [D yt] = ginput(2);    %yt - y temporary
      A = D(1);   B = D(2);
      if     A >  B,  A = B;   B = D(1);
      elseif A == B,  A = A*(1-2*eps);  end
      
      if     B >= V,     B = V;  end
      if     A < x(1),   A = x(1);  end
      if B < Veps,       fV = NaN;  else  fV = fVeps;  end
      
      h = (B-A)/qt;
      x = A : h : B+h/2;
      if QS == 3   % тк арг x(end) - скаляр, то посл арг tol не исп
         [KOx Ax Bx qx0] = ooHF3( nT, n, c, c_s, eei, V_2, x(end), []);
      end
      y = HF( nT, n, c, eei, V_2, x, KOx);
      
   elseif me == 3
      [x0, yt] = ginput(2); 
      if     x0(1) >  x0(2),  x0 = x0([2 1]);
      elseif x0(1) == x0(2),  x0 = [x0(1); x0(1)*(1+4*eps)];  end
   
      if x0(2) >= V,  x0(2) = V;  end
      sfx0 = sign(HF( nT, n, c, eei, V_2, x0, KO));
      if sfx0(1)*sfx0(2) > 0, prib('Выб и-ла вручную. Корня нет');
      else                    FL = 0.5;    break,end
               
   elseif me == 4
      [x0 FL KO t] = SigIA ( nT,   n,  c,   NNMk, ...
                             DxHF, HF, eei, V,    KO,...
                             x0,   f0, Xot, Veps, RRK);    
      if FL == 0.5 || FL == 5,  break,end
      
   else  FL = 25;   break
   end
end    
delete(hf)

% ________Инф о выч в Solv ______________________
function inf = infSolv( Ty,EHk, n, m, dva, V, EXT, i, q, VL, VL1k, VL9, h)
inf=sprintf('%s\n%s%d%d 2a=%g V=%g EXT=%d\ni=%d/%d L=%g/[%g %g] h=%g\n',...         
              Ty, EHk, n, m, dva, V, EXT, i, q, VL, VL1k, VL9, h);

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

%_____________ Кнопка GDH _________________________________________
% ______ Графики ДХ _______________________________________________
function GDH_Callback(~, ~, ~)
global QS ...
       LZ   hL    KZ   nT n c NNM ...
       c_s  GX    mm    ...
       DxHF n_290 dvaX dvaX1 RVS
global CALC

h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

rm = dvaX(1,:);                 % рейндж аз чисел m
UTO = S123( QS,...
            LZ,   hL,       KZ,   nT, n, c, NNM,...
            c_s,  GX(rm,:), mm,    ...
            DxHF, n_290,    dvaX, dvaX1, RVS);  
set( h_on, 'Enable', 'on');                
if prich(UTO),  return,end 
if UTO
      % вставить уточнение
end 

% ________выч дисперсий S1,S2,S3 и других дисп х-к______________________
function  UTO = S123( QS,   ...                       
                      LZ,   hL,    KZ,   nT, n, c, NNM,...
                      c_s,  GXmmm, mm,   ...
                      DxHF, n_290, dvaX, dvaX1, RVS )
% if UTO==0, завершение пр-мы нормальное,
% else      UTO = 'диагн.сообщение при Аварийном Выходе'
% (1:5+q,k,NM) = [m; dva; L1; L9; q; XL; xw; XR] - k-й столбец для NM
% dvaX(le1,m9,KM) = hL

UTO = 0;     
KM  = length(NNM);               % к-во мод
SZ  = size(dvaX);
qm  = SZ(2);                     % к-во аз чисел m
vv  = false;
%if nKT >= 12,  vv = false;  else  vv = true;  end

m2as = cell(qm,KM);
for k = 1:KM 
   for i = 1:qm                   % m dva 
      m2as{i,k} = sprintf('%2d %.5g', dvaX([1 4], i, k)); end
end

LZ1 = LZ(1);
LL0 = [LZ1 dvaX(2,1,k)];
LL  = LL0; 
sL0 = setH([LL0 hL])';
mmmi = mm(1):mm(2);        % рейндж mm, изменяемый в цикле
basa = mm(1)-1;
while true
   NM0 = k;
   if KM == 1,  k = 1;    
   elseif vv,   k = inpN('Выбор моды',2,{'1-E, 2-H'},10,[1 2],1,NaN);
   else         k = 2;  
   end
   
   if k ~= NM0
      LL0 = [LZ1 dvaX(2,1,k)]; 
      sL0 = setH([LL0; hL])'; 
   end
   
   if ~vv,  vv = true;
   else    
      mL = {mmmi; LL}; 
      if length(mmmi) > 10,  mL{1} = mm;  end
      mL = inpU('Графики дисперсий', mL,...
           { {'!!азимутальные числа m1 : m9'}; {'L1'  'L9'} },...
           { 3 [10 10]}, { mm; [LL0; LL0] },...
           ['I{1}(1) <= I{1}(end) && all(mod(I{1},1)==0)' ...
            '&& I{2}(1) < I{2}(2)']);
      if prich(mL), break,end
      mmmi = mL{1};   LL  = mL{2};       
   end
   
   mmo = mmmi-basa;
   iL  = LL(1) <= sL0 & sL0 <= LL(2);  % возможное сужение ин-ла
   L   = sL0(iL);
   n_2 = n_290( iL,:);
   suzLe = L(1)-1e-10 > sL0(1);        % инт-л L СУЖен слева(LEft)
   L9s   = dvaX( 2, mmo, k);
   qLs   = dvaX( 3, mmo, k);
   dvas  = dvaX( 4, mmo, k);  
   Lots  = dvaX( 5, mmo, k);
   Xs    = dvaX( [false(5,1);  iL], mmo, k);  % только Х-ы, соотв-е iL   
   S     = v_S123( L, hL, n_2, dvas, Xs,  2, 0);

   UTO = shuto_S123( m2as( mmo, k ),     QS, ...
                     KZ,   nT,           n,     L,    c, NNM(k),...
                     c_s,  GXmmm(mmo,:), mm, ...
                     DxHF, n_2,          ...
                     L9s,  qLs,          dvas,  Lots, Xs, ...                     
                     S,    suzLe,        dvaX1, RVS);
   if ischar(UTO),   return,end
end

% ___________Вычисление дисп х-к S123__________________________________
function S = v_S123 (L, hL, n_2, dvas, Xs, id,ip) 
% DisH - дисп х-ки, X дб столбцом
% dX  = dvaX(iX,mm,NM)
% n_2 = n_290(iL,NM) :  2 столбца значений n^2 для слоев с max и min n^2

% Искл.т и-ла До дифф-я (id)   0  0  0    1  1  1    2  2  2
% Искл.т и-ла После DIFi(ip)   0  1  2    0  1  2    0  1  2
% cумма искл.в рез-те точек    0  1  2    1  2  3    2  3  4

SZ  = size (Xs);
qX  = SZ(1);
qm  = SZ(2);
NA_2 = n_2(:,1)-n_2(:,2);    % квадрат апертуры
S   = nan (qX,8,qm);  

for i = 1:qm   
   Lpid2 = (L/(pi*dvas(i))).^2;
   V_2 = NA_2./Lpid2;
   Xi  = Xs(:,i);
   X2  = Xi.^2;
   nef = sqrt(n_2(:,1)-X2.*Lpid2);              
   ngr = nef -DIFi(1, nef,     hL, 0, 0).*L; % ip=0, те исп 2 нецентр РС =>                                      
   S(:,1,i) =-DIFi(2, nef,     hL, 0, 0).*L; % ngr и S1 опр во всех точках
   S(:,2,i) = DIFi(2, ngr,     hL,id,ip); 
   S(:,3,i) = DIFi(2, S(:,1,i),hL,id,ip);   
   S(:,1:3,i) = S(:,1:3,i)/0.299792458e-3;
               % X  nef ngr  Bef            Bgr             
   S(:,4:8,i) = [Xi nef ngr (V_2-X2)./V_2  (ngr.^2-n_2(:,2))./NA_2];
end

%______ ДИФф-е ф-ции F, заданной в M точках, с исключениями крайних тт
%        в зависимости от выбора РС на концах и-ла ___________________
function DF = DIFi( k, F, h, qid, qip)  
% qid - К-во Исключенных точек До    дифф-я 
% qip - К-во Исключенных точек После дифф-я
% Исключение точек: с правого края - qid и c левого - qid
% Аналогично - qip
% qip = 0: В 1-й и 2-й точках исп ДВЕ нецентральные несимм РС
% qip = 1: В n-1 и n-й точках исп ДВЕ аналогичные(антизеркальные) РС
% qip = 2: В центральной части исп центральные симм РС
% Производная Df определена во всех точках
M = length(F);       DF = nan(M,1);
m = M-2*qid;
I = qid+1 : M-qid;   f  = F(I);   Df = DF(I);         

if k == 1  
   L = [ 1.0  -8.0   0  8.0 -1.0];          z = 12*h;
   if qip <= 1
      f1 = f(1:5);      f2 = f(m-4:m);
      Df(2)  = [ -3.0 -10.0  18.0  -6.0  1.0]*f1;
      Df(m-1)= [ -1.0   6.0 -18.0  10.0  3.0]*f2;
      if qip == 0
         Df(1) = [-25.0 48.0 -36.0  16.  -3.0]*f1;
         Df(m) = [ 3.0 -16.0  36.0 -48.0 25.0]*f2;
      end
   end
else       
   L = [-1.0  16.0 -30.0  16.0 -1.0];          z = 12*h*h;
   if qip <= 1
      f1 = f(1:5);      f2 = f(m-4:m);
      Df(2)  = [ 11.0 -20.0   6.0   4.0 -1.0]*f1;
      Df(m-1)= [ -1.0   4.0   6.0 -20.0 11.0]*f2;
      if qip == 0
         Df(1) = [ 35.0 -104.0 114.0  -56.0 11.0]*f1;
         Df(m) = [ 11.0 -56.0  114.0 -104.0 35.0]*f2;
      end
   end
end
for i = 1:m-4, Df(i+2) = L*f(i:i+4); end
DF(I) = Df/z;

%_____________ Дифф-е ф-ции f, заданной в n точках _____________________
% Во 2-й точке исп ОДНА нецентральная несимм РС
% В n-1 точке исп ОДНА аналогичная(антизеркальная) РС
% В центральной части исп центральные симм РС
% Df(1) = Df(n) = NaN
function Df = DIFi1( k, f, h)  
m  = length(f);   Df = nan(m,1);
f1 = f(1:5);      f2 = f(m-4:m);
if k == 1  
   L      = [  1.0  -8.0   0     8.0 -1.0];        z = 12*h;
   Df(2)  = [ -3.0 -10.0  18.0  -6.0  1.0]*f1;
   Df(m-1)= [ -1.0   6.0 -18.0  10.0  3.0]*f2;
else       
   L      = [ -1.0  16.0 -30.0  16.0 -1.0];        z = 12*h*h;
   Df(2)  = [ 11.0 -20.0   6.0   4.0 -1.0]*f1;
   Df(m-1)= [ -1.0   4.0   6.0 -20.0 11.0]*f2;
end
for i = 1:m-4, Df(i+2) = L*f(i:i+4); end
Df = Df/z;

%_____________ Дифф-е ф-ции f, заданной в n точках _____________________
% В точках 3,...,n-2 исп Центральне симм РС
% Df(1) = Df(2) = Df(n-1) = Df(n) = NaN
function Df = DIFi2( k, f, h)  
m  = length(f);   Df = nan(m,1);
if k == 1,   L = [ 1.0  -8.0   0    8.0 -1.0];      z = 12*h;
else         L = [-1.0  16.0 -30.0  16.0 -1.0];     z = 12*h*h; end

for i = 1:m-4, Df(i+2) = L*f(i:i+4); end
Df = Df/z;
       
%_________SHow и УТОчнение дисп х-к S123_________________________________
function  UTO = shuto_S123 ( m2a,  QS,    ...
                             KZ,   nT,    n,    L,    c, NNMk,...
                             c_s,  GXmm,  mmG,  ...
                             DxHF, n_2,   ...
                             L9s,  qLs,   dvas, Lots, Xs, ...
                             S,    suzLe, dvaX1, RVS )     
% m2a информация о: моде(n,m,NM) и dva 
Di  = 1;
UTO = 0;
Gra = {'Дисперсии',   'Эфф и групп х-ки', 'Отдельно',...
       '3D-график хф','Уточнение кривой', 'Выход'};
   
Otd = {'Дисперсия S1', 'Дисперсия S2', 'Дисперсия S3', 'X',  ...
       'n_э',          'n_г',          'B_э',          'B_г', 'Выход'};  
qidp = [0 0 0   1 1 1   2 2 2;...
        0 1 2   0 1 2   0 1 2]';
lab = {'\lambda',''}; 

me = 1;
m  = mmG(1);
dm = mmG(1)-1;     %  сдвиг по m
LR = 2;            %  LR=1(2) влево(вправо) 
hL = L(2)-L(1);
Lend = L(end);
qL   = length(L);
qu0  = 3;           % К-во т. Уточнения
qid  = 0; qip = 2; 
EH   = 'EH';
moda = [EH(NNMk) num2str(n)];
first = true;
tme  = sprintf('Графики %d-CB', QS);
while me && me~=6
   if first,  first = false;  me = 1;
   else       me = menu(tme, Gra);  end
   
   if     me==1, sp_S123(2,2, moda,m2a, Otd(1:4), lab,L, Lots, S(:,1:4,:));
   elseif me==2, sp_S123(2,2, moda,m2a, Otd(5:8), lab,L, Lots, S(:,5:8,:));
   elseif me==3   
      while true
         me1 = menu(Gra{3}, Otd);
         if me1 == 0 || me1 == 9,  break,end
         sp_S123( 1,1, moda, m2a, Otd(me1), lab, L, Lots, S(:,me1,:) );
      end    
   elseif me == 4  
      m_   = inpA(Gra{4}, m, 'm', 10, mmG, 1, NaN);  % m1 <= m_ <= m9
      mdm  = m_-dm;                                  % 1 <= mdm <= m9-dm
      dva_ = dvas( mdm );
      fig  = figure;
      NAma = sqrt( max( n_2(:,1)-n_2(:,2) ));
      TDG( Di,          QS,    ...
           L([1 end])', hL,          KZ, nT, n, c, ...
           c_s,         GXmm(mdm,:), m_, qL, ...
           dva_,        qL,          NAma )
      prib('Построение 3-D графиков закончено')
      delete(fig)
   elseif me == 5  % Уточнение кривой
      mLR = inpN( Gra{5}, [m LR], {'m' '1-влево, 2-вправо'},...
                  [5 15], [mmG; 1:2], 1:2, NaN); 
              
      m   = mLR(1);    LR = mLR(2);   
      a   = 1;             
      mdm = m-dm; 
      qLm = qLs(mdm);
      b   = qLm;
      Lot = Lots( mdm );  
      dva = dvas( mdm );
      GXm = GXmm( mdm, :);
      Xot = GXm(1);    Xf = GXm(2);
      
      if LR == 1
         if suzLe  
            prie('Для уточнения кривой Х слева ввести L1=Lmin'); break,end
      elseif Lend < L9s(mdm)-1e-10
         prie('Для уточнения кривой Х справа ввести L9=Lmax'); break
      end      

      while true                     % опр к-ва т.осцилляции qosc
         I  = a:b; 
         H1 = subplot(221); hold(H1,'off'); 
         [AX H11 H12]=plotyy(L(I),[S(I,5,mdm) S(I,6,mdm)],L(I),Xs(I,mdm)); 
         grid on
         set( [get(AX(1),'Ylab') get(AX(2),'Ylab') ],{'Str'},...
         {'nef, ngr';'x(\lambda)'})
         YLim = get(AX(1),'YLim');
         Y1 = YLim(1);
         hY = (YLim(2)-Y1)/20;
         I1 = I(1);  LI1 = L(I1);
         text( [Lot Lot LI1 LI1], ...
               [Y1 Y1+hY  S(I1,5,mdm)+hY S(I1,6,mdm)+hY ],...
               {'\bullet' ...
               ['\lambda_{отс}' sprintf('=%.4g',Lot)] ...
               'nef' 'ngr'}, 'FontSize',9)
         title(sprintf('nef, ngr  -%d-  x', length(I))); 
         xlabel('\lambda')
         
         H2=subplot(222); hold(H2,'off'); plot(L(I),S(I,1,mdm)); title('S1'); grid on
         H3=subplot(223); hold(H3,'off'); plot(L(I),S(I,2,mdm)); title('S2'); grid on 
         H4=subplot(224); hold(H4,'off'); plot(L(I),S(I,3,mdm),'.');
         title(sprintf('S3, qidp = %d %d, DIFF%d',qid,qip)); grid on
                       
         mem = menu('Подбор РС',...
                        '1. К-во искл тт  0 0',...
                        '2. К-во искл тт  0 1',...
                        '3. К-во искл тт  0 2',...
                        '4. К-во искл тт  1 0',...
                        '5. К-во искл тт  1 1',...
                        '6. К-во искл тт  1 2',...
                        '7. К-во искл тт  2 0(ум)',...
                        '8. К-во искл тт  2 1',...
                        '9. К-во искл тт  2 2',...
                        'Увеличить масштаб', 'Уменьшить масштаб',...
                        'Оставить этот вариант');
         if mem < 10
            qid = qidp(mem,1);  qip = qidp(mem,2);
            S = v_S123( L, hL, n_2, dvas, Xs, qid, qip); 
         elseif mem == 10            
            if LR == 1 
               if b == 2
                  prib('Увеличить данный масштаб нельзя');  continue,end
               b = max( round(b/2), 2); 
            else
               if a == b-1
                  prib('Увеличить данный масштаб нельзя');  continue,end 
               a = min( round(a+0.5*(b-a)), b-1);
            end                        
         elseif mem == 11            
            if LR == 1
               if b == qL
                  prib('Уменьшить данный масштаб нельзя');  continue,end
               b = min( b*2, qLm);
            else
               if a == 1
                  prib('Уменьшить данный масштаб нельзя');  continue,end                          
               a = max( round(a-0.5*(b-a)), 1); 
            end                
         else
            hold(H1,'on');  hold(H2,'on');
            hold(H3,'on');  hold(H4,'on');  break
         end
      end
       
      qu0 = inpA('', qu0, 'ч.т уточнения' , 30, [3 qL], 1);
      if isempty(qu0),  break,end
                  
      sln9 = 1;            sln0 = 2;
      ic   = 0;            clrs = 'rgbcmk';        
      if LR == 1              % уточнение слева
         iu   = qu0+1;        % Индекс точки, после к-й нач-ся Уточнение
         i0   = 1:iu;  
         Xnew = Xs(iu-1, mdm );                   
      else                    % уточнение справа
         iu   = qL-qu0-sum(isnan(Xs(:,mdm)));
         i0   = iu : iu+qu0;  
         Xnew = Xs(iu+1, mdm ); 
      end 
      
      Lu    = L(iu);    
      Xu    = Xs (iu, mdm ); 
      Xmax  = Xs (i0, mdm );
      N_2max= n_2(i0,: );
      Stmax = S  (i0,:,mdm );
      qu    = qu0;            qu2 = qu0*2;   qumax = 0; 
      quh   = qu0*hL;
      izm   = true;
      quOSC = 16384;
      OSC   = false;   % ОСЦИЛЛЯЦИИ не было
      qPO   = 5;       % К-во точек, на к-х Проверяется к-во Осцилляций
      while true       % Нахождение неосциллирующего S3
        if izm
        ic  = ic+1;           clr = clrs( mod( ic,6)+1);
        h   = quh/qu;
        h2  = h/2; 
        if ~OSC && qu > qumax
           qumax = qu;  
           if LR == 1
              Lu_h = Lu-h;
              X01 = extDLfh( Xf, [Lu_h Lu], [Xnew(end) Xu], Lu+h2);
              X02 = extDLfh( Xf, [Lu_h Lu], [Xnew(end) Xu], Lu-h2);     
           else 
              Luph = Lu+h;
              X01 = extDLoh( Lot, Xot, [Lu Luph], [Xu Xnew(1)],Luph-h2);
              X02 = extDLoh( Lot, Xot, [Lu Luph], [Xu Xnew(1)],Luph+h2);   
           end 
          
           L1   = Lu+h2;                    
           Xnew = Solv( Di,   QS,...
                        KZ,   nT,  n,   c,    NM, ...
                        c_s,  GXm, m,   h,    L1,   qu, ...
                        DxHF, dva, Lot, [X01; X02], LR-1, RVS );
                        % В Solv EXT=LR-1 = 0 | 1
           if ischar(Xnew),  UTO = ['shuto_S123\n' Xnew];  return,end
                          
           Lnew   = ( L1 : h : L1 + (qu-1)*h )';
           N_2new = n_2_2( Lnew.^2, KZ( 1:6, [sln9 sln0]));
           qu1 = qu2+1;
           J1  = (1 : qu1)';    
           J   = logical( mod( J1,2) );
           Lt  = (Lu :h2: Lu+qu*h)';
           Lmax = Lt;
           
           Xt = nan(qu1,1);   N_2t   = nan(qu1,2);  
           Xt( J) = Xmax;     N_2t( J,:) = N_2max;  
           Xt(~J) = Xnew;     N_2t(~J,:) = N_2new;  
           Xmax   = Xt;       N_2max     = N_2t;    
           Stmax  = v_S123( Lmax, h2, N_2max, dva, Xmax, 2,0);
           St     = Stmax; 
           
           qPO1 = qPO+1;
           RAZ = St(2:qPO1,3)-St(1:qPO,3);
           sch = 0;
           for i = 1:qPO-1
               if RAZ(i)*RAZ(i+1) < 0, sch = sch+1;  end
               if sch >= 2,  OSC = true;  break;  end
           end    
                        
           if OSC   % откат к предыд (удвоенному) шагу
              quOSC  = qu/2;
              if quOSC < qu0
                 tS3 = sprintf('%g ',St(1:qPO1,3));
                 AV1 = sprintf(['Для S3 к-во осцилляций = %d,\n' ...
                      'но откат к пред шагу невозможен,\n'...
                      'т.к.это первое уточнение'],OSC);
                 UTO = sprintf('shuto_S123\n%s\nS3=\n%s',AV1,tS3);
                 fig = figure;
                 plot(St(1:qPO1,3));
                 title(sprintf('Осцилляция S3 обнаружена на %d точках',qPO1))                
                 prie(AV1)
                 delete(fig)
                 return
              else
                 qumax  = quOSC;
                 I = 1:2:qu1;
                 Lmax   = Lmax(  1:2:end ); 
                 Xmax   = Xmax(  1:2:end ); 
                 N_2max = N_2max(1:2:end,: );
                 Stmax  = v_S123( Lmax, h, N_2max, dva, Xmax, 2,0);
              end
           end
        else
           hi = qumax/qu;
           Lt = Lmax(  1:hi:end ); 
           St = Stmax( 1:hi:end,: );
        end
        
        subplot(221);  plot( Lt, St(:,5:6),clr);
        title(sprintf('nef, ngr, к.т =%d+%d, h=%g=%g/%d',...
                      iu, qu2, h2, hL, qu2/qu0));              grid on;   
        subplot(222);  plot( Lt, St(:,1), clr);  title('S1');  grid on;   
        subplot(223);  plot( Lt, St(:,2), clr);  title('S2');  grid on;   
        subplot(224);  plot( Lt, St(:,3), clr);  title('S3');  grid on; 
        end % izm
                
        meu = menu('Уточнение решения',...
                   '1.Уменьшить шаг',...
                   '2.Откат к пред шагу',...
                   '3.Указать диапазон и постр графики',...
                   '4.Выход');
        if     meu == 1
            izm =  qu2 <= quOSC;
            if izm 
               qu  = qu2;
               qu2 = qu*2;
               hold(H1,'on');  hold(H2,'on');
               hold(H3,'on');  hold(H4,'on'); 
            else
               prib('Шаг уменьш нельзя\nОсцилляция');
            end                         
        elseif meu == 2
           izm =  qu >= qu0;
           if izm,  qu2 = qu;
              qu  = qu/2;                    
              hold(H1,'off');  hold(H2,'off');
              hold(H3,'off');  hold(H4,'off'); 
           else
              prib('Шаг увеличен до первонач\nУм-ть');
           end
        elseif meu == 3
           izm = true;
           if LR == 1,  LL = L(iu:end);
           else         LL = L(1:iu);  end
           
           while true
             x  = diap( L(1), L(end));
             iL = x(1)< LL & LL < x(2);
             iv = x(1)< Lt  &  Lt < x(2);
             
             hold(H1,'off');  hold(H2,'off');
             hold(H3,'off');  hold(H4,'off');
             subplot(221); 
                plot( L(iL),[S(iL,5,mdm) S(iL,6,mdm)], Lt(iv), St(iv,5:6)); 
                text( Lt(end)+hL, St(end,5), 'nef')
                text( Lt(end)+hL, St(end,6), 'ngr')
                title(sprintf('nef, ngr, к.т=%d+%d, h=%g=%g/%d',...
                    iu, qu, h2, hL, qu/qu0)); 
                grid on
             subplot(222); 
                plot( L(iL),S(iL,1,mdm), Lt(iv), St(iv,1)); 
                grid on;    title('S1');
             subplot(223); 
                plot( L(iL),S(iL,2,mdm), Lt(iv), St(iv,2));
                grid on;    title('S2');
             subplot(224); 
                plot( L(iL),S(iL,3,mdm), Lt(iv), St(iv,3));
                grid on;    title('S3');
             if ~MEN,  break,end
           end         
        else break
        end  % meu == 4
      end    % Конец нахождения неосциллирующего S3
      
      hold(H1,'off');  hold(H2,'off');
      hold(H3,'off');  hold(H4,'off');
      UTO = [Lt; Xt]; 
   end
end

%__________Задать диапазон в [A,B] _______________________________________
function x = diap(A,B)
fig = figure('Name','Задать диапазон',...
     'NumberTitle','off', 'MenuBar','none',...
     'Position', [360 502 560 40]);
h = (B-A)/100;
plot( A:h:B, zeros(1,101))
set(gca,'XMinorTick','on','XTick',A:0.1:B)
[x,y] = ginput(2);
if x(1)>x(2), x    = x([2 1]); end
if x(1)<A,    x(1) = A;  end
if x(2)>B,    x(2) = B;  end
delete(fig)

%__________SubPlot дисп х-к S123_______________________________________
function   sp_S123 (I, J, moda, m2a, ZaG, lab, L, Lots, S)
siS = size(S);
qX  = siS(1);
if length(siS) == 3,  qm  = siS(3);  else  qm = 1;  end
ed  = ones(1,qm);

if    qm == 1,  it = 1; % Индекс Текст.переменной m2a
      mmG = m2a{1}(1:2); 
else
   if  qm < 12,  mmG = ['= [' sprintf('%.2s ',m2a{:} ) ']'];
   else          mmG = ['in [' m2a{1}(1:2) ' ' m2a{end}(1:2) ']'];  end
   if strcmp( m2a{1}(1:2), ' 1' ),  it = 2:qm; % it нач с 2,тк Lots(1)=Inf
   else                             it = 1:qm;   end
end
lenit = length(it);
if lenit == 1,  iG = 1;   
else            iG = [1 lenit];  end

mm = cellfun(@(x) sprintf('%.2s',x),m2a(it), 'UniformOutput', false);
for k = 1:I*J
    subplot(I,J,k)
    plot(L, reshape(S(:,k,:), qX, qm)) 
    
    XLim = get(gca,'XLim');
    x1   = XLim(2)*1.01;
    x2   = XLim(2)*1.04;
    
    if qm == 1,  text (x1, S(end,k,1), m2a{1}(1:8)); 
    else
       iS = sum( ~isnan(S(:,k,end)) );
       text ([x1 x1], [S(iS,k,1) S(iS,k,end)],...
            { m2a{1}(1:2) m2a{end}(1:2) }, 'FontSize', 6);
    end 
    
    YLim = get(gca,'YLim');
    Y2 = YLim(2);
    Y1 = YLim(1);
    if k == 1        
       hy = ( Y2-Y1 )/ (qm+1);
       text ( x2, Y2, 'm   2a','FontSize',8); 
       text ( x2*ed, setK( [Y2-hy Y1+hy qm]), m2a,'FontSize',8); 
    end
        
    hold on; grid on
    titlab([ZaG{k} '.  ' moda 'm, m ' mmG],lab);
    
    Y0 = Y1*ed(it);
    plot ( Lots(it), Y0, '.r');  
    text ( Lots(iG), Y0(iG)-(Y2-Y1)*0.03, mm(iG),'FontSize',6);  
    hold off; 
end


%________________________ВСПОМОГАТЕЛЬНЫЕ Ф-ЦИИ___________________________
%                        Полезные аргументы
%XT=get(gca,'XTick'); hx=(XT(2)-XT(1))/5;
% _______% к-ты лин интерп: Если f(ti)=fi, то f(t) = А*t+B _____________
function [A B] = CLI(t1,t2,f1,f2)  
d = t2-t1;  A = (f2-f1)/d;  B = (f1*t2-f2*t1)/d;

% _______title+ylabel_____________________________________________________
function titlab(tit,lab)
title(tit); xlabel(lab{1});   ylabel(lab{2}); grid on

%___________________________СЕТКИ________________________________________
function s = setK(X)  % X= [X1 X2 K], на входе к-во точек K
h = (X(2)-X(1))/(X(3)-1);
s = X(1) :h: X(2)+h*1e-6;

%____________________________________________________________________
function [s h] = setKH(X)  % X= [X1 X2 K], на входе к-во точек K
h = (X(2)-X(1))/(X(3)-1);
s = X(1) :h: X(2)+h*1e-6;

%____________________________________________________________________
function s = setH(X)  % X = [X1 X2 h], на входе шаг h
s = X(1) :X(3): X(2)+X(3)*1e-6;

% _________________________НАПОМИНАНИЯ____________________________
function NePok( z, N, t, P)
%function NePok(t,handles)% cooбщение, к-ое можно не показывать далее
global NePoks
if NePoks(N) == 0
   hf = figure('NumberTitle','off', 'MenuBar','none',...
        'Name',z, 'Units','pixels',...
        'Position',P);
   col  = get(hf,'Color');
   
   uicontrol(hf,'Style','text','String',t,'BackgroundColor',col,...
       'HorizontalAlignment','left',...
       'Units','pixels', 'Position',[20 55 P(3)-40 P(4)-70]);
  
   cb = uicontrol(hf,'Style','checkbox','BackgroundColor',col,...
       'String','Не показывать в дальнейшем',...
       'Position',[20 33 196 20]);
   
   uicontrol(hf,'Style','pushbutton','String','OK',...
       'Position',[110 5 40 20],...
       'Callback',{@pbNePok_CB,[],N,cb,hf});

   waitfor(hf)
end 

% ______________________________________________________________________
function pbNePok_CB(~, ~, ~, N,cb,hf)
global NePoks
NePoks(N) = get(cb,'Value');
delete(hf)

% ______________________Группа pri_____________________________________
function prib( frm, varargin )
waitfor(msgbox(sprintf(frm,varargin{1:end}),'replace'))
function pribz(z,frm,varargin)
waitfor(msgbox(sprintf(frm,varargin{1:end}),z,'replace'))
function prie(frm,varargin)
waitfor(errordlg(sprintf(frm,varargin{1:end}),'Ошибка','on'))
function r = prich(X)
if ischar(X)
   r = true; 
   if ~isempty(X), prib(X); end
else
   r = false;
end

% _________________________МЕНЮ_____________________________
function me = MEN(varargin) % me=0-вых; arg1='tit'
% arg2={ };К-во арг=0:2
if nargin == 0,      T = '';   P = {'Продолжить'};        
else
   T = varargin{1};
   if nargin == 1,     P = {'Продолжить'};
   else P = varargin{2};
      if ~iscell(P),   P = varargin(2:end); end
   end
end
me = menu(T,[P,'Выход']);
if me == length(P)+1,   me = 0; end

%___________________________ Группа  inp ______________________________
% ___________ввод функции F(х,varargin) _______________________________
function I = inpFX( tit, I, im, varargin) 
if ~ischar(I),   prie('Inp mb  char array');  return,end
%if Lzag ~= length(I), prie('К-во заголовков д/б= к-ву строк');return,end
op.Interpreter = 'tex'; op.Resize = 'on';  op.WindowStyle = 'modal'; 
x = -1;
if isempty(varargin),        Na = false;
else                         LV = length(varargin);
   if isnan(varargin{LV}),   Na = true;     LV = LV-1; 
   else                      Na = false;    end
   for i = 1:LV
      try   eval([varargin{i} '=1;']);
      catch ME, prie(sprintf(...
          'Неверно задан %g-й арг ф-ции\n%s',i,ME.message));
      end
   end
end
[RF CF] = size(I);
  
while true
   C = inputdlg(im,tit,[RF 2*CF],{I},op);  
   if isempty(C),  if Na,  prie('Дб непустой ввод');  continue
                   else    I = '';                    return,end,end
   I = C{1}; 
   try   cellfun(@eval,C,'UniformOutput',false);   return
   catch ME, prie(['Неверно заданы функции\n' ME.message]),  end
end

%_______________________I = ROW; G=[G1 G2]- 2 числа____________________
function I = inpRI( tit, I, im, G, varargin) 
% если посл арг = NaN, то Esc, Canc игнорируются,т.е. ввод дб непустым
% ввод строки целых(Row of Integer), длина I м/меняться
% im - имя I (char)
% varargin = char, содерж условие в символах I, например: 'I(1)<I(2)'
if size(I,1) ~= 1,  I = 'Нач.зн вводимых данных дб строкой'; return,end
if any(size(G) ~= [1 2]) || G(1) > G(2) 
   I = 'Гр.зн. дб строкой из 2-х неубывающих чисел';         return,end
op.Interpreter = 'tex';  op.Resize = 'on';   op.WindowStyle = 'modal'; 
z = sprintf('%g< %s <%g     ',G(1),im,G(2));
if     isempty(varargin),    ERRon = false;  Na = false;
elseif isnan(varargin{1}),   ERRon = false;  Na = true; 
elseif isnan(varargin{end}), ERRon = true;   Na = true;
else                         ERRon = true;   Na = false;  end 
S   = num2str(I);                
while true   
   C = inputdlg(z,tit,1,{S},op);
   if isempty(C),  if Na,  prie('Дб непустой ввод'); continue
                   else    I = '';                   return,end,end
   S = C{1};           I = str2num(S);   
   if isempty(I),      prie('Некорректный ввод чисел');     continue,end      
   if size(I,1) ~= 1,  prie('Вводимые данные дб строкой');  continue,end
   if any(I<G(1)) || any(I>G(2)), prie('Выход за границы'); continue,end                  
   if any(mod(I,1)),   prie('Ввод нецелых чисел');          continue,end   
   if ERRon
      if    eval(['(' varargin{1} ')']),  return
      else  prie(['Не вып доп условие\n' varargin{1}]);  end
   end
end

%______________________________________________________
function I = inpN( tit, I, im, wid, G, varargin)
% I  = wid-vector; G=wid*2-matrix
% im = {wid-string-vector} имена вводимых переменных
% varargin = empty,    нет условий
%          = intArr, напр: [2 3], проверка на целочисл I(2), I(3)
%          = string, содерж усл в символах I, например: 'I(1)<I(2)'
%          = intArr,string  или  string,intArr - 2 условия
if any(G(:,1) > G(:,2)),       I = 'Неверные границы';       return,end
if isempty(im),                I = 'Не задан вектор имён';   return,end
if any(cellfun(@isempty,im)),  I = 'Не все имена заданвы';   return,end
RG = size(G,1); 

lenim = length(im);
if isempty(I), [RI CI] = size(im);  lI = lenim;
else           [RI CI] = size(I);   lI = length(I); end
%if RI ~= 1,     I = 'вводимые данные и их имена дб строками';return,end
if lI ~= lenim,       I = 'к-во эл-тов ~= к-ву их имён';     return,end
if lI ~= length(wid), I = 'к-во эл-тов ~= к-ву длин ф-тов';  return,end
if lI ~= RG,          I = 'к-во эл-тов ~= к-ву границ';      return,end

if     isempty(varargin),       Na = false;   ERRon = 0;  
elseif isnan(varargin{1}),      Na = true;    ERRon = 0; 
else   v1 = varargin{1};
   if  isnan(varargin{end}),    Na = true;    narMax = 8;
   else                         Na = false ;  narMax = 7; end
   if nargin == narMax,  v2 = varargin{2}; end
   if isnumeric(v1) && all(mod(v1,1)==0),        ERRon = 1;  
      if nargin == narMax  
         try te = eval(v2);  v2 = ['(' v2 ')'];  ERRon = 2;           
         catch ME, I = [ME.message '\n 2 усл'];    return,end
      end
   else
      try te = eval(v1);  v1 = ['(' v1 ')'];     ERRon = 3;
      catch  ME,   I = [ME.message '\n 1 усл'];    return,end
      if nargin == narMax         
         if all(mod(v2,1)==0),                   ERRon = 4; 
         else   I = 'Неверен вектор пров целоч'; return,end
      end
   end
end   
  
z = '';  F = '';
for k = 1:lI
    p   = wid(k);
    F   = [F sprintf('%%%d.%dg',round(2*p+3+length(im{k})),p)];
    %frm = sprintf('%%.%dg \\\\leq %%s \\\\leq %%.%dg    ',p,p);
    frm = sprintf('%%.%dg < %%s < %%.%dg    ',p,p);
    z   = [z sprintf(frm,G(k,1),im{k},G(k,2))]; 
end
S = sprintf( F, I);

op.Interpreter = 'tex';  op.Resize = 'on';   op.WindowStyle = 'modal'; 
LT  = length(tit);       Lpromp    = max(cellfun(@length,im));
if 2*LT < Lpromp, numlin = 1;
else              numlin = [1 length(z)]; end  %round(lI*sum(wid))

while true
   try,       C = inputdlg( {z}, tit, numlin, {S}, op);
   catch ME,  prie(ME.message);
   end
   if isempty(C),  if Na,  prie('Дб непустой ввод'); continue
                   else    I = '';                   return,end,end
   S = C{1};   
   try I = reshape( str2num(S), RI,CI);
   catch ME, prie(ME.message);    continue,end
   
   if isempty(I),              prie('некорр ввод чисел');    continue,end
   rI = reshape( I, lI, 1 );
   if any( rI < G(:,1)) || any( rI > G(:,2))
                               prie('выход за границы');     continue,end
   if ~ERRon,   return
   else switch  ERRon
        case 1, ERR = any(mod(I(v1),1));          
                dop = sprintf('Цел I(%g)',v1);
        case 2, ERR = any(mod(I(v1),1)) || ~eval(v2);
                dop = [sprintf('Цел I(%g) & ',v1) v2];
        case 3, ERR = ~eval(v1);      dop = v1;
        case 4, ERR = ~eval(v1) || any(mod(I(v2),1));
                dop = [v1 sprintf('Цел I(%g) & ',v2)];
        end
        if ~ERR, return  
        else     prie(['Не вып доп условие\n' dop]); end
   end
end

%___________ ввод массива(строка,ст-ц,м-ца) _____________________________
function I = inpA(tit,I,im,wid,G,varargin)
% I=массив;
% im=string-имя I; 
% wid=шир ф-та на одно число;  
% G=[1x2]-array
% ! в начале имени означает,что у массива мб изменена размерность

if any(size(G) ~= [1 2]) && any(size(G) ~= [2 1])
                           I = 'Границы дб 1х2-array';    return,end
if     isempty(im),        I = 'Не задано имя';           return
elseif ~ischar(im),        I = 'Имя дб строкой символов'; return,end
if isempty(I),             I = 'Не задан массив';         return,end
[RI CI] = size(I);

if     isempty(varargin),       Na = false;      ERRon = 0;  
elseif isnan(varargin{1}),      Na = true;       ERRon = 0; 
else   v1 = varargin{1};
   if  isnan(varargin{end}),    Na = true;    narMax = 8;
   else                         Na = false ;  narMax = 7; end
   if nargin == narMax,  v2 = varargin{2}; end
   if isnumeric(v1) && all(mod(v1,1)==0),        ERRon = 1;  
      if nargin == narMax  
         try   te = eval(v2); 
               v2 = ['(' v2 ')']; 
               ERRon = 2;           
         catch ME, I = ['Неверно задано 2 усл\n' ME.message];
               return
         end
      end
   else
      try   te = eval(v1); 
            v1 = ['(' v1 ')'];  
            ERRon = 3;
      catch ME,    I = ['Неверно задано 1 усл\n' ME.message];
            return
      end
      if nargin == narMax         
         if all(mod(v2,1)==0),                   ERRon = 4; 
         else   I = 'Неверен вектор пров целоч'; return,end
      end
   end
end   

op.Interpreter = 'tex';  op.Resize = 'on';   op.WindowStyle = 'modal';
%len = round(3*size(num2str(I),2));
S = num2str(I);   
z = sprintf('%s  %g %g',im,G(1),G(2));
while true
   C = inputdlg(z,tit,[RI wid],{S},op);
   if isempty(C),  if Na,  prie('Дб непустой ввод');  continue
                   else    I = '';                    return,end,end
   S = C{1};
   I = str2num(S);
   if isempty(I),              prie('Некорр ввод чисел');    continue,end
   if im(1) ~= '!'
      if any(size(I) ~= [RI CI])
         prie('Неверная разм массива');continue,end
   end 
   if any(any(I<G(1))) || any(any(I>G(2)))
                               prie('Выход за границы');     continue,end
   if ~ERRon, return
   else switch  ERRon
        case 1, ERR = any(mod(I(v1),1));          
                dop = sprintf('Цел I(%g)',v1);
        case 2, ERR = any(mod(I(v1),1)) || ~eval(v2);
                dop = [sprintf('Цел I(%g) & ',v1) v2];
        case 3, ERR = ~eval(v1);      dop = v1;
        case 4, ERR = ~eval(v1) || any(mod(I(v2),1));
                dop = [v1 sprintf('Цел I(%g) & ',v2)]; 
        end
            
        if ~ERR, return
        else  prie(['Не вып доп условие\n' dop]);  end
   end
end

%____________% ввод универсальный _______________________________________
function I = inpU(tit, I, im, wid, G, varargin) 
% если последний аргумент = NaN, то Esc и Canc при вводе игнорируются
% I={SOV or Arrays}- вектор; SOV - SetOfVar(набор переменных)
% im - {имена},   G={границы I}
% wid - {w1...wL}, L-длина I(=LI)
% if I{k}is SOV, wk is ROW=[ширины ф-тов для I{k}]; else wk не исп.
% ! в 1-м символе имени озн, что у данного массива мб изменена размерность
% ! в 2-м символе имени озн, что данные в окне предст в виде: Iнач : Iкон
if ~isvector(I) || ~isvector(G) 
   I = 'н.зн I и гр.зн G дб векторы';     return,end
if isempty(I), I = 'Вх.аргумент I не дб пустым';  return,end

LI = length(I);
if LI ~= length(G)
   I = 'к-во строк ввода ~= к-ву границ'; return,end

z = cell(LI,1);     SOI = zeros(LI,2);  % Sizes of I
F = cell(1,LI);     C = z;
for j = 1:LI
   if ~isnumeric( I{j}) || ~isnumeric( G{j})
      I = 'содержимое I и G дб числа';  return,end 
   if any( G{j}(:,1) > G{j}(:,2) )
      I = 'Неверные границы';           return,end
   SOI(j,:)  = size(I{j});
   [Rim Cim] = size(im{j});
   if Rim >  1, I = 'В окне - одно имя, либо строка имен';  return,end
   if Cim == 1  % I{j} - переменная: число, вектор или матрица
      if any(size(G{j}) ~= [1 2])
         I = sprintf('Для перем.I{%g} size(G) ~= [1 2]',j); return,end
      if size(wid{j},2) ~= 1
         I = sprintf('Для перем.I{%g} к-во.длин ~= 1',j);   return,end
   elseif length(I{j}) ~= length(G{j}(:,1)) % I{j} - набор переменных
      I = 'к-во переменных в строке ~= длине гран-м-цы'; return
   end      
   
   za   = '';
   for k = 1:Cim           
      F{j} = [F{j} sprintf('%%%dg ',wid{j}(k))];
      zk   = sprintf(' %s: %g  %g    ',im{j}{k}, G{j}(k,1), G{j}(k,2));            
      za   = [za zk]; 
   end
   str = im{j}{1};
   if numel(str) >=2 && str(2) == '!'
      C{j} = sprintf('%g : %g',I{j}([1 end]));
   else
      if Cim > 1 || all( SOI(j,:)==[1 1]), C{j} = sprintf(F{j},I{j});
      else                                 C{j} = num2str(I{j},F{j}); end
   end
   z{j} = za; 
end

op.Interpreter = 'tex'; op.Resize = 'on';   op.WindowStyle = 'modal';  
if     isempty(varargin),    ERRon = false;  Na = false;
elseif isnan(varargin{1}),   ERRon = false;  Na = true; 
elseif isnan(varargin{end}), ERRon = true;   Na = true;
else                         ERRon = true;   Na = false;
end 
NL    = zeros(LI,1);
for j = 1:LI,  NL(j) = size(I{j},1); end
while true
   C1 = inputdlg( z, tit, NL, C, op);
   if isempty(C1), if Na,  prie('Дб непустой ввод');  continue
                   else    I = '';                    return,end,end
   C = C1;            
   I = cellfun(@str2num,C,'UniformOutput',false);   
   if any(cellfun(@isempty,I)),prie('Некоррек. ввод чисел');continue,end          
   E1 = false;  E2 = false;
   for j=1:LI  
      if all(size(im{j}) ~= [1 1]) || im{j}{1}(1)~='!'
         E1 = E1 || any(size(I{j}) ~= SOI(j,:) );  end
   end
   if E1,  prie('Неверная размерность');    continue,end
   for j=1:LI,  E2 = E2 || any(any( I{j}' <  G{j}(:,1) )) ...
                        || any(any( I{j}' >  G{j}(:,2) ));end   
   if E2,  prie('Выход за границы');        continue,end
   if ~ERRon, return 
   else if  eval(['(' varargin{1} ')']),  return
        else  prie(['Не вып доп условие\n' varargin{1}]); end
   end
end


%_______________________Группа HF_______________________________________
%____________выч к-та P (энергетическая (POW) х-ка 2-сл СВ ____________
function P = POW( n, V_2, x)
[x2, y2, J, xDJJ, yDKK] = JK( n, V_2, x);
P = -n*V_2./(xDJJ.*y2+yDKK.*x2);
i0 = x == 0;
if any(i0),  P(i0) = -1;  end

%____________ХФ 2 сл СВ_________________________________________________
function f = HF2( nT, n, c, e1, V_2, x, KO )
% 2 сл СВ, здесь NTR=NR № режима
% nT, c, KO - не используются
[x2, y2, J, xDJJ, yDKK] = JK(n, V_2, x);

y22 = y2./x2;
A = xDJJ.*J.*y22;
B = yDKK.*J; 

f  = (A+B).*(e1.*A+B)-(n*J).^2./x2.*V_2.*(e1.*y22+1);
i0 = x == 0;
if any(i0)
   if n == 1,  f(i0) = -0.5*e1*y2(i0);
   else        f(i0) = 0;  end
end

%_______________________________________________________________________
function [x2, y2, J, xDJJ, yDKK] = JK(n, V_2, x)
x2 = x.^2;       y2 = V_2-x2;   
y2(y2<0) = NaN;  y = sqrt(y2);
J    = besselj(n,x);
xDJJ = 0.5*(besselj(n-1,x)-besselj(n+1,x)).*x./J;
yDKK =-0.5*(besselk(n-1,y)+besselk(n+1,y)).*y./besselk(n,y);
xDJJ(x<eps) =  n;  
yDKK(y<eps) = -n; 

%____________________ХФ 2сл СВ, когда х - ARray__________________________________________________
function [f s1 s2] = HF2_ar( nT, n, c, c_s, e1, V_2, x)
% ф-ция подогнана под ф HF3_ar в UR0
s1 = [];  s2 = [];  % - вых п-ры
f  = HF2( nT, n, c, e1, V_2, x, [] );

%____________________Выделение матриц е1, е3 __________________________
function [e1 e3] = matee(eew)
sz2 = size(eew,2)/2;   
e1  = eew(:,1:sz2);
e3  = eew(:,sz2+1:end);

%____________Опред Классификтора Ос-ти HF для х ______
function [KO A B qx] = ooHF3( nT, n, c, e, ee, V_2, x, tol)
% х = x0 - это нач.прибл.(скаляр) или границы нач.пр.(вектор 2*1)
% c_s = [сGR suz]
% сGR - сГРаничное: 0.1-0.5
% suz - к-т сужения 0-особенности: 0.01-1
% KO = [A B G D]- классификатор особенностей; A B G D - скаляры
%  здесь  е1, е3 - всегда скаляры( они мб векторами, если L - вектор)
global  Keq1
%global Ieq1 Yeq1
e1 = ee(1);   e3 = ee(2);
A  = [];      B  = [];

if     nT == 1  % x12z > 0   x22z - любой
   %z1   = 1;          cx1  = c*x;                
   x12  = x.^2;     
   x32  = V_2-x12;    x32(x32<0) = NaN; 
   x22zo = (( 1-e3)*x12 - (e1-1)*x32)/(e1-e3);  
   x22z = x12-(e1-1)/(e1-e3)*V_2;
   if abs((x22z-x22zo)/x22z)>15*eps
      fprintf( 'АВАРИЯ в ooHF3!  %g  %g\n', x22z,x22zo);
   end
   %x2   = sqrt(abs(x22z));
   z2   = stup(x22z,0,1,-1);
   qx   = numel(z2);
   KO = [ones(qx,1) z2 z2];
   if qx > 1
      [A B] = IZO( nT, e1, e3, V_2, x, x22z(2), tol );
   end
   
elseif nT == 2  % x12z - любой  x22z > 0  
   %z2   = 1;       
   x2   = x;         
   x22  = x2.^2;  
   x32  = V_2-x22;  x32(x32<0) = NaN; 
   x12zo = ((e1-e3)*x22 + (e1-1)*x32)/(1-e3);  
   x12z = x22+(e1-1)/(1-e3)*V_2;
   if abs((x12z-x12z0)/x12z)>2*eps
       'АВАРИЯ в ooHF3!', x12z,x12zo
   end
   %cx1  = c*sqrt(abs(x12z)); 
   z1   = stup(x12z, 0,1,-1);
   qx   = numel(z1);
   KO = [z1 ones(qx,1) ones(qx,1)];
   if qx > 1
      [A B] = IZO( nT, e1, e3, V_2, x, x12z(2), tol );
   end
   
elseif nT == 3  % x12z > 0      x22z < 0
   % z1  = 1;         z2  = -1;
   % cx1 = c*x;     
   x12 = x.^2;       
   x22 = V_2-x12; 
   %x2  = sqrt(x22);  
   x32o = ((1-e3)*x12 + (e1-e3)*x22)/(e1-1); 
   x32 = -x12+(e1-e3)/(e1-1)*V_2;
   x32(x32<0) = NaN; 
   qx  = 1;
   KO  = [1 -1 -1];
   
else  %nT == 4    x12z < 0       x22z > 0  
   % z1  = -1;        z2  = 1;
   x2  = x;       
   x22 = x2.^2;
   x12 = V_2-x22;  
   %cx1 = c*sqrt(x12);     
   x32 = (-(1-e3)*x12 -(e1-e3)*x22)/(e1-1); 
   x32 = -x22-(1-e3)/(e1-1)*V_2;
   x32(x32<0) = NaN; 
   qx  = 1;
   KO  = [-1 1 1];
end

if max(x32) > Keq1(n+1)^2,  KO4 = 1;  else  KO4 = 0;  end
KO = [KO KO4*ones(qx,1)];

%{
cGR   = c_s(1);        suz    = c_s(2);
Ieq1n = Ieq1(n+1);     Yeq1n  = Yeq1(n+1);     Keq1n = Keq1(n+1);
Iepsn = suz*Ieq1n;     Yepsn  = suz*Yeq1n;     Kepsn = suz*Keq1n;
Jepsn = 0.1;           KIepsn = min(Kepsn,Iepsn);               
% AB = '00';  GD = '00';
% Сузим узкие(0-особенности) области по х: 
% было сx1 < Ieq1n, cтало cx1 < Iepsn = suz*Ieq1n

if     z1  > 0,    JI   = Jepsn;  else  JI    = Iepsn;  end
if     cx1 > JI,   KO(1) = z1;    else  KO(1) = 0;      end

if     z2  > 0,    YKI  = Yepsn;  else  YKI   = KIepsn; end
if     x2  > YKI,  KO(3) = z2;    else  KO(3) = 0;      end

if     c   > cGR,  KO(2) = KO(3);   
elseif c*x2> YKI,  KO(2) = z2;    else  KO(2) = 0;  end
%}

% Опр границ Изм Знак Ос-ти( изм знака x^2 в менее плотном слое)
function [A B] = IZO( nT, e1, e3, V_2, X, x_2B, tol )
A    = X(1);   B     = X(2);
e1_1 = e1-1;   e1_e3 = e1-e3;  E_e3 = 1-e3;

while abs(B-A) > tol
   x = (A+B)*0.5; 
   if     nT == 1                          % x12z > 0;  x22z = xVS- любой               
      x12 = x^2;     
      x32 = V_2-x12;   
      xVS = (E_e3*x12 - e1_1*x32)/e1_e3;   % x^2 во ВСпомогат слое
   else                                    % x12z = xVS - любой;  x22z > 0         
      x22 = x^2; 
      x32 = V_2-x22;   
      xVS = (e1_e3*x22 + e1_1*x32)/E_e3;  
   end
   
   if xVS * x_2B > 0,  B = x;
   else                A = x;
   end     
end

%___________ ХФ 3 сл СВ, Mathcad-9.УстрОс ________________________________
function HF = HF3( nT, n, c, ee, V_2, x, KO )   
% пока исп-ся только для х - скаляра или х=[x1 x2] при ILK,
% хотя предусм х-вектор, если набор ос-тей KO не меняется
% для HF3 глоб переменные и соотв ф-ции для выч бф 
% отл-ся добавлением символа '_' к аналогичным объектам в HF3_ar 
% KO - классификатор особенностей(сингулярностей)
global xRPI xRPK RPK xPZ 
global J1 DJ1   J2c DJ2c   Y2c DY2c   J2 DJ2   Y2 DY2

SZX = size(x);               % KO=[Alfa,Beta,Gamma,Delta] - скаляры
e1  = ee(1);  
e3  = ee(2);   

if     nT == 1  % x12z > 0      x22z - любой
   x1  = x;             x12 = x1.^2;      
   x32 = V_2-x12;       x32(x32 < 0) = NaN;
   x22zo = (( 1-e3).*x12 - (e1-1).*x32)./(e1-e3);  
   x22z = x12-(e1-1)/(e1-e3)*V_2;
   x22  = abs(x22z);    x2  = sqrt(x22);  
   cx1  = c*x1;         cx2 = c*x2;  
   z1 = 1;              JD1(n,cx1);
   
   ip = x22z >= 0; 
   if    all(ip),   z2 =  1;  JYD2(n,cx2,x2);
   else
      im = x22z < 0;      
      if all(im),   z2 = -1;  IKD2(n,cx2,x2); 
      else
         %KO(2:3) = -1;       % смена знака х22 => x22~0 => кл.ос КО=-1
         z2  = nan(SZX);
         J2c = z2;   J2 = z2;    DJ2c = z2;   DJ2 = z2;
         Y2c = z2;   Y2 = z2;    DY2c = z2;   DY2 = z2; 
         
         z2(ip) = 1;         JYD2_ar(n,cx2(ip),x2(ip),ip);
         z2(im) = -1;        IKD2_ar(n,cx2(im),x2(im),im);
      end
   end
  
elseif nT == 2  % x12z - любой  x22z > 0  
   x2  = x;            x22 = x2.^2;     
   x32 = V_2-x22;      x32(x32 < 0) = NaN; 
   x12zo = ((e1-e3).*x22 + (e1-1).*x32)./(1-e3);
   x12z = x22+(e1-1)/(1-e3)*V_2;
   x12 = abs(x12z);    x1  = sqrt(x12);
   cx1 = c*x1;         cx2 = c*x2;
   z2  = 1;            JYD2(n,cx2,x2);
   
   ip = x12z >= 0;  
   if    all(ip),   z1 = 1;  JD1(n,cx1);
   else
      im = x12z < 0;
      if all(im),   z1 =-1;  ID1(n,cx1);
      else
         %KO(1) = 0;       % смена знака х12 => x12~0 => кл.ос КО=0 
         z1 = nan(SZX);
         J1 = z1;            DJ1 = z1;        
         z1(ip) = 1;         JD1_ar(n,cx1(ip),ip);
         z1(im) =-1;         ID1_ar(n,cx1(im),im); 
      end
   end
  
elseif nT == 3  % x12z > 0       x22z < 0
   x1  = x;         x12 = x1.^2;      
   x22 = V_2-x12;   x2  = sqrt(x22); 
   x32o = ((1-e3).*x12 + (e1-e3).*x22)./(e1-1);
   x32 = -x12+(e1-e3)/(e1-1)*V_2;
   cx1 = c*x1;      cx2 = c*x2;        
   z1 = 1 ;         JD1(n,cx1);
   z2 =-1;          IKD2(n,cx2,x2);
   
else  %nT == 4    x12z < 0        x22z > 0  
   x2  = x;         x22 = x2.^2;      
   x12 = V_2-x22;   x1  = sqrt(x12);  
   x32o = (-(1-e3)*x12-(e1-e3)*x22)/(e1-1);
   x32 = -x22-(1-e3)/(e1-1)*V_2;
   cx1 = c*x1;      cx2 = c*x2;  
   z1 = -1;         ID1(n,cx1);
   z2 =  1;         JYD2(n,cx2,x2); 
end

cx12 = cx1.^2;       cx22     = cx2.^2;
x3   = sqrt(x32);    [K3 DK3] = KD3(n,x3);

z     = z1.*z2;
z2vec = ~isscalar(z2);  % z1 не входит в  векторные вычисления
zvec  = ~isscalar(z);

                             % switch AB  Выч p=[a;b],r
if     KO(1:2) == [1 1]       % A == 1 && B == 1          % case '++'
   u  = J1./cx2;       v  = DJ1./cx1;      S1 = J1./cx12-J1./cx22;   
   a2 = u.*DJ2c;       a1 = v.*J2c;        e = S1.*J2c;
   b2 = u.*DY2c;       b1 = v.*Y2c;        f = S1.*Y2c;  
   ab = 1./(cx1.*cx2);
   
elseif KO(1:2) == [-1 1]      % A ==-1 && B == 1          % case '-+'
   i = find(cx1 > xRPI);   v    = -DJ1./(cx1.*J1);
   if ~isempty(i),         v(i) = -1./cx1(i);  end
   %if all(cx1 > xRPI),    v  = -1./cx1; else   v = -DJ1./(cx1.*J1); end
   
   S1 = -1./cx12-1./cx22;  a2 = DJ2c./cx2;      a1 = v.*J2c;      
   e = S1.*J2c;            b2 = DY2c./cx2;      b1 = v.*Y2c;             
   f = S1.*Y2c;     
   ab = 1./(cx1.*J1*cx2);
   
elseif KO(1:2) == [0 1]       % A == 0 && B == 1          % case '0+'
   i = find(cx1 < xPZ(n));  j1 = z.*cx1.*DJ1./J1;
   if ~isempty(i),          if zvec, j1(i) = z(i)*n;
                            else     j1(i) = z*n;   end,end
   %if all(cx1 < 1e-8),     j1 = z.*n;  else  j1 = z.*cx1.*DJ1./J1; end
   
   S1 = z-cx12./cx22;   u  = cx12./cx2;          
   e  = S1.*J2c;        a2 = u.*DJ2c;   a1 = j1.*J2c;  
   f  = S1.*Y2c;        b2 = u.*DY2c;   b1 = j1.*Y2c;
   ab = cx1./(J1.*cx2);
   
elseif KO(1:2) == [1 0]       % A == 1 && B == 0          % case '+0'
   j = find(cx2 < xPZ(n));  b2    = J1 .*cx2.*DY2c./Y2c; 
   if ~isempty(j),          b2(j) = -J1(j).*n;  end
   %if all(cx2 < 1e-8),     b2 = -J1.*n; else b2 = J1.*cx2.*DY2c./Y2c; end
   
   wc = J2c./Y2c;                         b1 = z.*cx22.*DJ1./cx1;   
   f  = J1.*(z.*cx22./cx12-1);                   
   e  = f.*wc;      a2 = b2.*DJ2c./DY2c;  a1 = b1.*wc;                      
   ab = cx2./(cx1.*Y2c);
  
elseif KO(1:2) == [-1 0]      % A ==-1 && B == 0          % case '-0'
   i = find(cx1 > xRPI);    b1 = z.*cx22.*DJ1./(cx1.*J1);        
   if ~isempty(i),          if zvec, b1(i) = z(i).*cx22(i)./cx1(i);
                            else     b1(i) = z*cx22(i)./cx1(i);  end,end 
   %if all(cx1 > xRPI),     b1 = z.*cx22./cx1; 
   %else                    b1 = z.*cx22.*DJ1./(cx1.*J1); end
   
   j = find(cx2 < xPZ(n));  j2 = cx2*DJ2c./J2c;   b2 = cx2.*DY2c./Y2c;
   if ~isempty(j),          j2(j) = n;            b2(j) = -n;   end
   %if all(cx2 < 1e-8),     j2 = n;               b2 = -n;    
   %else                    j2 = cx2*DJ2c./J2c;   b2 = cx2.*DY2c./Y2c; end
   
   wc = J2c./Y2c;          a2 = wc.*j2;           a1 = wc.*b1; 
   f  = z.*cx22./cx12-1;   e  = f.*wc;                                   
   ab = cx2./(cx1.*J1*Y2c);
   
elseif KO(1:2) == [0 0]     % A == 0 && B == 0          % case '00'
   wc = J2c./Y2c;
   
   i = find(cx1<xPZ(n));   b1 = z.*cx22.*cx1.*DJ1./J1;
   if ~isempty(i),         if zvec, b1(i) = z(i).*cx22(i)*n;   
                           else     b1(i) = z*cx22(i)*n; end,end
   %if all(cx1<1e-8),      b1    = z.*cx22*n; 
   %else                   b1    = z.*cx22.*cx1.*DJ1./J1; end
   
   j = find(cx2<xPZ(n));   b2    = cx12.*cx2.*DY2c./Y2c;
   if ~isempty(j),         b2(j) = -cx12(j)*n;   end   
   %if all(cx2<1e-8),      b2    = -cx12*n;   
   %else                   b2    = cx12.*cx2.*DY2c./Y2c;  end
   
   a2 = b2.*DJ2c./DY2c;    a1 = wc.*b1;       
   f  = z.*cx22-cx12;      e  = f.*wc;
   ab = cx1.*cx2./(J1.*Y2c);   
    
elseif KO(1:2) == [1 -1]      % A == 1 && B ==-1          % case '+-'
   wc_ = Y2c./J2c;    u = J1./cx2;
   
   j = find(cx2>xRPI);    a2    = u.*DJ2c./J2c;
   if ~isempty(j),        a2(j) = u(j);  end
   %if all(cx2>xRPI),     a2    = u;     
   %else                  a2    = u.*DJ2c./J2c;     end
   
   jj= find(cx2>xRPK(n)); b2     = wc_.*u.*DY2c./Y2c;
   if ~isempty(jj),       b2(jj) = -wc_(jj).*u(jj);  end   
   %if all(cx2>xRPK(n)),  b2     = -wc_.*u; 
   %else                  b2     = wc_.*u.*DY2c./Y2c; end
   
   e = -J1./cx12-J1./cx22;             a1 = -DJ1./cx1;                    
   f  = e.*wc_;                        b1 = a1.*wc_;         
   ab = 1./(cx1.*cx2.*J2c);
  
elseif KO(1:2) == [-1 -1]      % A ==-1 && B ==-1          % case '--'
   wc_  = Y2c./J2c;
   
   i = find(cx1>xRPI);    a1    = DJ1./(cx1.*J1); 
   if ~isempty(i),        a1(i) =  1./cx1(i);  end
   %if all(cx1>xRPI),     a1    =  1./cx1;  
   %else                  a1    = DJ1./(cx1.*J1);   end
    
   j = find(cx2>xRPI);    a2    = DJ2c./(cx2.*J2c); 
   if ~isempty(j),        a2(j) =  1./cx2(j);  end
   %if all(cx2>xRPI),     a2    =  1./cx2; 
   %else                  a2    = DJ2c./(cx2.*J2c);    end
   
   jj= find(cx2>xRPK(n)); b2     = wc_.*DY2c./(cx2.*Y2c);
   if ~isempty(jj),       b2(jj) = -wc_(jj)./cx2(jj);  end 
   %if all(cx2>xRPK(n)),  b2     = -wc_./cx2; 
   %else                  b2     = wc_.*DY2c./(cx2.*Y2c); end
   
   e = 1./cx12-1./cx22;  f = e.*wc_;      b1 = a1.*wc_;          
   ab = 1./(cx1.*J1.*cx2.*J2c); 
   
elseif KO(1:2) == [0 -1]      % A == 0 && B == -1          % case '0-'
   u = cx12./cx2;           wc_   = Y2c./J2c; 
   
   i = find(cx1<xPZ(n));    a1    = z.*cx1.*DJ1./J1;
   if ~isempty(i),          if zvec,  a1(i) = z(i).*n;  
                            else      a1(i) = z*n; end,end
   %if all(cx1 < 1e-8),     a1    = z.*n;
   %else                    a1    = z.*cx1.*DJ1./J1; end
   
   j = find(cx2>xRPI);      a2    = u*DJ2c./J2c; 
   if ~isempty(j),          a2(j) = u(j);  end
   %if all(cx2 >xRPI),      a2    = u; 
   %else                    a2    = u*DJ2c./J2c;     end 
   
   jj= find(cx2>xRPK(n));   b2     =  wc_.*u.*DY2c./Y2c;
   if ~isempty(jj),         b2(jj) = -wc_(jj).*u(jj);  end          
   %if all(cx2 >xRPK(n)),   b2     = -wc_.*u; 
   %else                    b2     =  wc_.*u.*DY2c./Y2c;  end
   
   e = z-cx12./cx22;       f = e.*wc_;       b1 = wc_.*a1;                                                                                
   ab = cx1./(J1.*cx2.*J2c);
end

                             % switch GD  % выч q=[C;d],t 
if     KO(3:4) == [1 1]       % G == 1 && D == 1      % case '++' 
   L = find(x3>xRPK(n));  v    = DK3./(x3.*K3);
   if ~isempty(L),        v(L) = RPK(n)./x3(L);  end 
   %if x3 > xRPK(n),      v    = RPK(n)./x3; 
   %else                  v    = DK3./(x3.*K3); end
   
   S2 = 1./x32+1./x22;   C2 = DJ2./x2;      C1 = v.*J2;             
   g  = S2.*J2;          d2 = DY2./x2;      d1 = v.*Y2;   
   h  = S2.*Y2;
   gd = 1./(x3.*x2.*K3); 

elseif KO(3:4) == [-1 1]       % G ==-1 && D == 1          % case '-+'
   w_ = Y2./J2;
   
   L = find(x3>xRPK(n));  C1    = -x22.*DK3./(x3.*K3);
   if ~isempty(L),        C1(L) = -x22(L).*RPK(n)./x3(L);  end  
   %if x3 > xRPK(n),      C1    = -x22.*RPK(n)./x3; 
   %else                  C1    = -x22.*DK3./(x3.*K3); end
   
   K = find(x2>xRPI);    C2    = x2.*DJ2./J2;
   if ~isempty(K),       C2(K) = x2(K);  end   
   %if x2 > xRPI,        C2    = x2;  
   %else                 C2    = x2.*DJ2./J2;     end
   
   KK= find(x2>xRPK(n)); d2    =  w_.*x2.*DY2./Y2;
   if ~isempty(KK),      d2(KK)= -w_(KK).*x2(KK);  end
   %if x2 > xRPK(n),     d2    = -w_.*x2;  
   %else                 d2    =  w_.*x2.*DY2./Y2; end
   
   g = -x22./x32+1;  h = g.*w_;        d1 = C1.*w_;
   gd = x2./(x3.*J2.*K3);

elseif KO(3:4) == [1 0]       % G == 1 && D == 0          % case '+0'
   L = find(x3<xPZ(n));  v    = x3.*DK3./K3;
   if ~isempty(L),       v(L) = -n;  end
   %if all(x3 < 1e-8),   v    = -n;  
   %else                 v    = x3.*DK3./K3; end 
   
   u  = x32./x2;    C2 = u.*DJ2;    C1 = v.*J2; 
   S2 = 1+x32./x22; d2 = u.*DY2;    d1 = v.*Y2;   
   g  = S2.*J2;   
   h  = S2.*Y2;                       
   gd = x3./(x2.*K3);

elseif KO(3:4) == [-1 0]      % G == -1 && D == 0          % case '-0'
   w_  = Y2./J2;   u = x32./x2;
   
   L = find(x3<xPZ(n));   C1    = -x3.*DK3./K3;
   if ~isempty(L),        C1(L) = n;  end
   %if all(x3 < 1e-8),    C1    = n;  
   %else                  C1    = -x3.*DK3./K3;   end
     
   K = find(x2>xRPI);     C2    = u.*DJ2./J2;  
   if ~isempty(K),        C2(K) = u(K);  end
   %if all(x2 > xRPI),    C2    = u;  
   %else                  C2    = u.*DJ2./J2;     end
   
   KK = find(x2>xRPK(n)); d2     =  w_.*u.*DY2./Y2;
   if ~isempty(KK),       d2(KK) = -w_(KK).*u(KK);  end
   %if all(x2 > xRPK(n)), d2     = -w_.*u; 
   %else                  d2     =  w_.*u.*DY2./Y2; end
   
   g  = -1+x32./x22; h = g.*w_;       d1 = C1.*w_;                        
   gd = x3./(x2.*J2.*K3);

elseif KO(3:4) == [0  1]      % G == 0 && D == 1          % case '0+'
   L = find(x3>xRPK(n)); d1 = z2.*x22.*DK3./(x3.*K3); 
   if ~isempty(L),       if z2vec, d1(L)= z2(L).*RPK(n).*x22(L)./x3(L);
                         else      d1(L)= z2*RPK(n).*x22(L)./x3(L);end,end
   %if x3 > xRPK(n),     d1    = z2.*RPK(n).*x22./x3;
   %else                 d1    = z2.*x22.*DK3./(x3.*K3);      end
   
   K = find(x2<xPZ(n));   d2    = x2.*DY2./Y2;
   if ~isempty(K),        d2(K) = -n;  end
   %if x2 < 1e-8,         d2    = -n;  
   %else                  d2    = x2.*DY2./Y2; end
   
   w  = J2./Y2;           C2 = d2.*DJ2./DY2;       C1 = d1.*w;  
   h  = z2.*x22./x32+1;   g  = h.*w;                            
   gd = x2./(x3.*Y2.*K3);
   
elseif KO(3:4) == [0  0]      % G == 0 && D == 0          % case '00'
   L = find(x3<xPZ(n));   d1    =  z2.*x22.*x3.*DK3./K3;
   if ~isempty(L),        if z2vec, d1(L) = -z2(L).*x22(L)*n;
                          else      d1(L) = -z2*x22(L)*n; end,end
   %if all(x3<1e-8),      d1    = -z2.*x22*n; 
   %else                  d1    =  z2.*x22.*x3.*DK3./K3; end 
   
   K = find(x2<xPZ(n));   d2    =  x32.*x2.*DY2./Y2;
   if ~isempty(K),        d2(K) = -x32(K)*n;  end
   %if all(x2<1e-8),      d2    = -x32*n; 
   %else                  d2    =  x32.*x2.*DY2./Y2;   end
   
   w  = J2./Y2;       C2 = d2.*DJ2./DY2;     C1 = d1.*w; 
   h  = z2.*x22+x32;  g  = h.*w;      
   gd = x2.*x3./(Y2.*K3);
end

a = a2 - a1;       b = b2 - b1;      C  = C2 + C1;      d  = d2 + d1;
a_= a2 - a1.*e1;   b_= b2 - b1.*e1;  C_ = C2 + C1.*e3;  d_ = d2 + d1.*e3;

nU2 = n^2*(x12-z.*x22.*e1)./(x12-z.*x22);

HF = (a.*d - b.*C).*(a_.*d_ - b_.*C_)./nU2 ...
    +(e.*h - f.*g).^2 .*nU2                ...
    -(a.*h - b.*g).*(a_.*h  - b_.*g)       ...
    -(C.*f - d.*e).*(C_.*f  - d_.*e)       ...
  -2*(C.*h - d.*g).*(a .*f  - b .*e);

%{          
f0 = HF./(ab.*gd).^2;

V2 = cx1.*J1;   V1 = z.*cx2.*DJ1; 
A2 = V2.*DJ2c;  A1 = V1.*J2c;    A = A2-A1;    A_ = A2-A1.*e1;
B2 = V2.*DY2c;  B1 = V1.*Y2c;    B = B2-B1;    B_ = B2-B1.*e1;
V  =(z.*cx2./cx1-cx1./cx2).*J1;
E  = V.*J2c;    F  = V.*Y2c;

W2 = x3.*K3;    W1 = z2.*x2.*DK3;
CC1= W2.*DJ2;   CC2= W1.*J2;     CC= CC2+CC1;  CC_ = CC2+C1.*e3;
D1 = W2.*DY2;   D2 = W1.*Y2;     D = D2+D1;    D_  = D2+D1.*e3;
W  = (z2.*x2./x3+x3./x2).*K3;
G  = W.*J2;     H  = W.*Y2;

fm = (A.*D - H.*CC).*(A_.*D_ - B_.*CC_)./nU2 ...
    +(E.*H - F.*G).^2 .*nU2                 ...
    -(A.*H - B.*G).*(A_.*H  - B_.*G)        ...
    -(CC.*F - D.*E).*(CC_.*F  - D_.*E)       ...
  -2*(CC.*H - D.*G).*(A .*F  - B .*E);


F  = cx1*cx2*x2*x3*J1*Y2c*J2*K3;          
fc = (F*ab*gd)^2*HFC(...
n,c,ee,z1,z2,x1,x2,x3,J1,DJ1,J2c,DJ2c,Y2c,DY2c,J2,DJ2,Y2,DY2,K3,DK3);
%}
%_____________вариант HF Классический _____________________________________________________________
function HC = HFC( n, c, ee, z1,z2, x1,x2,x3,...
                   J1,DJ1, J2c,DJ2c, Y2c,DY2c, J2,DJ2, Y2,DY2, K3,DK3 )
e1  = ee(1);    e3  = ee(2); 
x12 = x1.^2;    cx1 = c*x1;    cx12 = cx1.^2;  z   = z1*z2;
x22 = x2.^2;    cx2 = c*x2;    cx22 = cx2.^2;  x32 = x3.^2;

x12z = x12*z1;            x22z = x22*z2;              
A1 = z2*DJ2c./(cx2.*J2c); B1 = z2*DY2c./(cx2.*Y2c); 
A2 = z1*DJ1./(cx1.*J1);   B2 = z1*DJ1./(cx1.*J1);  
C1 = z2*DJ2./(x2.*J2);    D1 = z2*DY2./(x2.*Y2);
C2 = DK3./(x3.*K3);       D2 = DK3./(x3.*K3);     
A  = A1 - A2;       B  = B1 - B2;       C  = C1 + C2;    D  = D1 + D2;
A_ = A1 - A2*e1;    B_ = B1 - B2*e1;    C_ = C1 + C2*e3; D_ = D1 + D2*e3;
    
E  = J2c.*Y2./(Y2c.*J2); 
s1 = 1/c^2*(1./x12z - 1./x22z);  s12 = s1.^2;  s1p = z1./cx12-z2./cx22;
s2 = 1./x22z + 1./x32;           s22 = s2.^2;  s2p = z2./x2.^2+1./x32;

if x1 > 1e-13 && x2 > 1e-13 && ...
   ( abs((s1-s1p)./s1) > 10*eps || abs((s2-s2p)./s2) > 100*eps )
   prie('Ош в выч S1, S2'); return,end

nU2 = n^2*(x12-z*x22*e1)./(x12-z*x22);
HC = (A.*D.*E-B.*C).*(A_.*D_.*E-B_.*C_)./nU2 + nU2.*s12.*s22.*(E-1).^2 - ...
     E.^2.*(s12.*D.*D_+s22.*A.*A_) - s12.*C.*C_ - s22.*B.*B_ + ...
     E.*(s12.*(C.*D_+C_.*D)-2*s1.*s2.*(A-B).*(C-D)+s22.*(A.*B_+A_.*B));
%{
F  = cx1*cx2*x2*x3*J1*Y2c*J2*K3;
fc = (F*ab*gd)^2*HC;                    
if abs((fc-f)/f) > 1e-7
   disp(sprintf('%s%s%3g %+10.3g %+10.3g %+10.3g %+13.5g %+13.5g',...
   AB,GD,ii,x12z,x22z,x32,f,fc)); end
%}
%________________________ХФ 3 сл СВ когда арг х - массив(ARray)__________
function [f stAB stGD] = HF3_ar( nT, n, c, c_s, ee, V_2, x)     

global Ieq1 Yeq1 Keq1 xRPI xRPK RPK
global J1 DJ1   J2c DJ2c   Y2c DY2c   J2 DJ2   Y2 DY2
%TSV={'1) e1 > 1 > e3','2) 1 > e1 > e3','3) e1 > e3 > 1','4) 1 > e3 > e1'};
[e1 e3] = matee(ee);
SZX  = size(x);  
SZAD = [SZX(1) 1];    
NCOL = 1;    % №(1-5) колонки матрицы х, по каждому х(i,NCOL) к-ой опр-ся 
             % ос-ть для всех x(i,1:5), соотв-х сетке L в i-й строке
u   = nan(SZX);   v    = u;
j1  = u;   j2   = u;   S1   = u;   S2  = u;   r1  = u;  r2 = u;  
a2  = u;   a1   = u;   b2   = u;   b1  = u;   t1  = u;  t2 = u;
C2  = u;   C1   = u;   d2   = u;   d1  = u;   w   = u;  w_ = u;  
J1  = u;   J2c  = u;   Y2c  = u;   J2  = u;   Y2  = u;   
DJ1 = u;   DJ2c = u;   DY2c = u;   DJ2 = u;   DY2 = u;

x_2         = x.^2; 
V_2_X       = V_2-x_2;  
xnan        = V_2_X < 0;
x(xnan)     = NaN;   
x_2(xnan)   = NaN;  
V_2_X(xnan) = NaN;  

if     nT == 1  % e1 > 1 > e3:  x12z > 0  x22z - любой
   x1   = x;           x12  = x_2;           x32 = V_2_X;     
   x22z = (( 1-e3).*x12 - (e1-1).*x32)./(e1-e3);  
   x22  = abs(x22z);   x2  = sqrt(x22);  
   cx1  = c*x1;        cx2 = c*x2;   
   z1   = 1;           JD1(n,cx1);   % JD1_ar(n,cx1,iT)    %- проверить
   p2   = x22z >= 0;   m2  = x22z < 0;
   
   if      all(all(m2)),      z2 =-1;        IKD2(n,cx2,x2);
   elseif  all(all(p2)),      z2 = 1;        JYD2(n,cx2,x2); 
   else    z2 = ones(SZX);    z2(m2) = -1;   z2(xnan) = NaN;
           JYD2_ar(n,cx2(p2),x2(p2),p2);  
           IKD2_ar(n,cx2(m2),x2(m2),m2); end
    
elseif nT == 2  % 1 > e1 > e3:  x12z - любой  x22z > 0  
   x2   = x;             x22  = x_2;         x32 = V_2_X; 
   x12z = ((e1-e3).*x22 + (e1-1).*x32)./(1-e3);  
   x12  = abs(x12z);     x1  = sqrt(x12);
   cx1  = c*x1;          cx2 = c*x2;      
   z2   = 1;             JYD2(n,cx2,x2);
   p1   = x12z >= 0;     m1  = x12z < 0;
   
   if      all(all(m1)),      z1 =-1;       ID1(n,cx1);
   elseif  all(all(p1)),      z1 = 1;       JD1(n,cx1);
   else    z1 = ones(SZX);    z1(m1) = -1;  z1(xnan) = NaN;
           JD1_ar(n,cx1(p1),p1); 
           ID1_ar(n,cx1(m1),m1); end
       
elseif nT == 3  % e1 > e3 > 1 :  x12z > 0       x22z < 0
   x1  = x;             x12 = x_2;      x22 = V_2_X; 
   x2  = sqrt(x22);
   x32 = ((1-e3).*x12 + (e1-e3).*x22)./(e1-1);
   m3 = x32 < 0;        x32(m3) = NaN;
   if any(any(m3))
      fprintf('HF_3: nT=3, x32<0\nx12=');   fprintf('%g',x12(m3)); 
      fprintf('\nx22='); fprintf('%g',x22(m3)); fprintf('\n');  end
      
   cx1 = c*x1;        cx2 = c*x2;
   z1  = 1;           JD1( n, cx1); 
   z2  =-1;           IKD2(n, cx2, x2);

else  %nT == 4  1 > e3 > e1:   x12z < 0        x22z > 0  
   x2  = x;             x22 = x_2;     x12 = V_2_X; 
   x1  = sqrt(x12);
   x32 = (-(1-e3).*x12 - (e1-e3).*x22)./(e1-1);
   m3 = x32 < 0;        x32(m3) = NaN;
   if any(any(m3))
      fprintf('HF_3: nT=4, x32<0\nx12=');   fprintf('%g',x12(m3)); 
      fprintf('\nx22='); fprintf('%g',x22(m3)); fprintf('\n');  end
  
   cx1 = c*x1;        cx2 = c*x2;
   z1  =-1;           ID1( n, cx1);
   z2  = 1;           JYD2(n, cx2, x2);  end

cx12 = cx1.^2;        cx22     = cx2.^2;
x3   = sqrt(x32);     [K3 DK3] = KD3(n,x3);
z    = z1.*z2;

                             % границы ос-тей б.ф
cGR    = c_s(1);     suz   = c_s(2);                               
Ieq1n  = Ieq1(n+1);  Yeq1n = Yeq1(n+1);  Keq1n = Keq1(n+1);
Iepsn  = suz*Ieq1n;  Yepsn = suz*Yeq1n;  Kepsn = suz*Keq1n;
KIepsn = min(Kepsn,Iepsn);               Jepsn = 0.1;    

if length(z1) == 1
   if z1 > 0,  JI = Jepsn;   else  JI = Iepsn;  end
   A = stup(cx1(:,NCOL),JI,z1,0);
else
   JI = nan(SZAD); 
   JI(p1(:,NCOL)) = Jepsn;  
   JI(m1(:,NCOL)) = Iepsn; 
   j = cx1(:,NCOL) > JI;            % cx1 > JI не мб на всем ин-ле
   if  all(~j),  A = 0;
   else
      A = zeros(SZAD);
      A(j) = z1(j,NCOL);  
      A(xnan(:,NCOL)) = NaN;
   end
end
               
if length(z2) == 1
   if z2 > 0,  YKI = Yepsn; 
   else        YKI = KIepsn;  end 
   
   G = stup(x2(:,NCOL),YKI,z2,0);
   
   if c > cGR,  B = G;  
   else         B = stup(cx2(:,NCOL),YKI,z2,0);  end
else    
   YKI = nan(SZAD);
   YKI(p2(:,NCOL)) = Yepsn; 
   YKI(m2(:,NCOL)) = KIepsn;   
   i = x2(:,NCOL) > YKI;  
   if  all(~i),   G = 0;  B = 0;
   else      
      G = zeros(SZAD); 
      G(i) = z2(i,NCOL);
      G(xnan(:,NCOL)) = NaN;
      if c > cGR,  B = G;    
      else
         B = zeros(SZAD);         B(xnan(:,NCOL)) = NaN;
         k = cx2(:,NCOL) > YKI;   B(k) = z2(k,NCOL);  end
   end
end

D = stup(x32(:,NCOL),Kepsn^2, 1, 0);

               %switch AB  % выч p=[a;b],r
stAB = zeros(2,2);
stGD = stAB;
ks   = 0;  % счетчик статистики

nos = 1;    i = os2(A,B,nos,SZX); 
if any(any(i))   % 1 case: [1,1] = '++'
   ks = ks+1;                  stAB(ks,:) = [nos sum(sum(i))];
   u(i)  = J1(i)./cx2(i);      v(i) = DJ1(i)./cx1(i); 
   S1(i) = J1(i)./cx12(i)-J1(i)./cx22(i);   
   a2(i) = u(i).*DJ2c(i);      a1(i) = v(i).*J2c(i);
   b2(i) = u(i).*DY2c(i);      b1(i) = v(i).*Y2c(i);         
   r1(i) = S1(i).*J2c(i);      r2(i) = S1(i).*Y2c(i);   end
%ab = 1./(cx1.*cx2);

nos = 2;     i = os2(A,B,nos,SZX); 
if any(any(i))    % 2 case: [-1,1] = '-+'
   ks = ks+1;                 stAB(ks,:) = [nos sum(sum(i))]; 
   i1bI = i & cx1 >  xRPI;    v(i1bI) = -1./cx1(i1bI); 
   i1mI = i & cx1 <= xRPI;    v(i1mI) = -DJ1(i1mI)./(cx1(i1mI).*J1(i1mI));
   S1(i) = -1./cx12(i)-1./cx22(i); 
   a2(i) = DJ2c(i)./cx2(i);      a1(i) = v(i) .*J2c(i);      
   r1(i) = S1(i).*J2c(i);        r2(i) = S1(i).*Y2c(i);                 
   b2(i) = DY2c(i)./cx2(i);      b1(i) = v(i) .*Y2c(i);  end
%ab = 1./(cx1.*J1.*cx2);

nos = 3;     i = os2(A,B,nos,SZX);
if any(any(i))    % 3 case: [0,1] =  '0+'
   ks = ks+1;                stAB(ks,:) = [nos sum(sum(i))]; 
   i1m = i & (cx1 < 1e-8);   j1(i1m) = scv(z,i1m)*n;  
   i1b = i & (cx1 >= 1e-8);  j1(i1b) = scv(z,i1b).*cx1(i1b).* ...
                                       DJ1(i1b)./J1(i1b);
   S1(i) = scv(z,i)-cx12(i)./cx22(i);     
   u(i)  = cx12(i)./cx2(i);          
   r1(i) = S1(i).*J2c(i);    r2(i) = S1(i).*Y2c(i);
   a2(i) = u(i).*DJ2c(i);    a1(i) = j1(i).*J2c(i);  
   b2(i) = u(i).*DY2c(i);    b1(i) = j1(i).*Y2c(i); end
%ab = cx1./(J1.*cx2);

nos = 4;     i = os2(A,B,nos,SZX);
if any(any(i))    % 4 case: [1,0] = '+0'
   ks = ks+1;                 stAB(ks,:) = [nos sum(sum(i))]; 
   i2m = i & cx2 < 1e-8;      b2(i2m) = -J1(i2m)*n; 
   i2b = i & cx2 >= 1e-8;     b2(i2b) = J1(i2b).*cx2(i2b).*DY2c(i2b)./...
                                        Y2c(i2b);
   w(i)  = J2c(i)./Y2c(i);    b1(i)   = scv(z,i).*cx22(i).*DJ1(i)./cx1(i);   
   r2(i) = J1(i).*(scv(z,i).*cx22(i)./cx12(i)-1);                   
   r1(i) = r2(i).*w(i);      
   a1(i) = b1(i).*w(i);       a2(i) = b2(i).*DJ2c(i)./DY2c(i);  end                  
%ab = cx2./(cx1.*Y2c);

nos = 5;    i = os2(A,B,nos,SZX); 
if any(any(i))   % 5 case: [-1,0] = '-0'
   ks = ks+1;               stAB(ks,:) = [nos sum(sum(i))]; 
   i1bI = i& cx1 >  xRPI;   b1(i1bI)= scv(z,i1bI).*cx22(i1bI)./cx1(i1bI); 
   i1mI = i& cx1 <= xRPI;   b1(i1mI)= scv(z,i1mI).*cx22(i1mI).* ...
                                      DJ1(i1mI)./(cx1(i1mI).*J1(i1mI));
   i2m = i & cx2 < 1e-8;    j2(i2m) = n;          b2(i2m) = -n;    
   i2b = i & cx2 >= 1e-8;   j2(i2b) = cx2(i2b).*DJ2c(i2b)./J2c(i2b);
                            b2(i2b) = cx2(i2b).*DY2c(i2b)./Y2c(i2b); 
   w(i)  = J2c(i)./Y2c(i); 
   a2(i) = w(i).*j2(i);                    a1(i) = w(i).*b1(i); 
   r2(i) = scv(z,i).*cx22(i)./cx12(i)-1;   r1(i) = r2(i).*w(i);  end                               
%ab = cx2./(cx1.*J1.*Y2c);

nos = 6;     i = os2(A,B,nos,SZX);
if any(any(i))    % 6 case: [0,0] = '00'
   ks = ks+1;                  stAB(ks,:) = [nos sum(sum(i))]; 
   i1m = i & (cx1 < 1e-8);     b1(i1m) = scv(z,i1m).*cx22(i1m)*n; 
   i1b = i & (cx1 >= 1e-8);    b1(i1b) = scv(z,i1b).*cx22(i1b).* ...
                                         cx1(i1b).*DJ1(i1b)./J1(i1b);
   i2m = i & (cx2 < 1e-8);     b2(i2m) = -cx12(i2m)*n;  
   i2b = i & (cx2 >= 1e-8);    b2(i2b) = cx12(i2b).*cx2(i2b).* ...
                                         DY2c(i2b)./Y2c(i2b);
   w(i)  = J2c(i)./Y2c(i);     
   a1(i) = w(i).*b1(i);                 a2(i) = b2(i).*DJ2c(i)./DY2c(i);                     
   r2(i) = scv(z,i).*cx22(i)-cx12(i);   r1(i) = r2(i).*w(i); end                         
   %ab = cx1.*cx2./(J1.*Y2c);
   
nos = 7;    i = os2(A,B,nos,SZX); 
if any(any(i))   % 7 case: [1,-1] = '+-'
   ks = ks+1;                  stAB(ks,:) = [nos sum(sum(i))]; 
   w_(i)= Y2c(i)./J2c(i);      u(i)     = J1(i)./cx2(i);
   i2bI = i & cx2 >  xRPI;     a2(i2bI) = u(i2bI);     
   i2mI = i & cx2 <= xRPI;     a2(i2mI) = u(i2mI).*DJ2c(i2mI)./J2c(i2mI);
   i2bK = i & cx2 >  xRPK(n);  b2(i2bK) = -w_(i2bK).*u(i2bK); 
   i2mK = i & cx2 <= xRPK(n);  b2(i2mK) =  w_(i2mK).*u(i2mK).* ...
                                          DY2c(i2mK)./Y2c(i2mK);
   r1(i) = -J1(i)./cx12(i)-J1(i)./cx22(i);   a1(i) = -DJ1(i)./cx1(i);                    
   r2(i) = r1(i).*w_(i);                     b1(i) = a1(i).*w_(i); end       
%ab = 1./(cx1.*cx2.*J2c);

nos = 8;     i = os2(A,B,nos,SZX); 
if any(any(i))    % 8 case: [-1,-1] = '--'
   ks = ks+1;                stAB(ks,:) = [nos sum(sum(i))]; 
   w_(i)  = Y2c(i)./J2c(i);
   i1bI = i & cx1 >  xRPI;   a1(i1bI) = 1./cx1(i1bI);  
   i1mI = i & cx1 <= xRPI;   a1(i1mI) = DJ1(i1mI)./(cx1(i1mI).*J1(i1mI));
   i2bI = i & cx2 >  xRPI;   a2(i2bI) = 1./cx2(i2bI);  
   i2mI = i & cx2 <= xRPI;   a2(i2mI) = DJ2c(i2mI)./(cx2(i2mI).*J2c(i2mI));
   i2bK = i & cx2 >  xRPK(n);  b2(i2bK) =-w_(i2bK)./cx2(i2bK); 
   i2mK = i & cx2 <= xRPK(n);  b2(i2mK) = w_(i2mK).*DY2c(i2mK)./ ...
                                          (cx2(i2mK).*Y2c(i2mK));
   r1(i) = 1./cx12(i)-1./cx22(i);         r2(i) = r1(i).*w_(i);  
   b1(i) = a1(i).*w_(i);  end        
%ab = 1./(cx1.*J1.*cx2.*J2c);

nos = 9;       i = os2(A,B,nos,SZX);
if any(any(i))      % 9 case: [0,-1] = '0-'
   ks = ks+1;                 stAB(ks,:) = [nos sum(sum(i))]; 
   u(i) = cx12(i)./cx2(i);    w_(i)   = Y2c(i)./J2c(i); 
   i1m = i & (cx1 < 1e-8);    a1(i1m) = scv(z,i1m)*n;   
   i1b = i & (cx1 >= 1e-8);   a1(i1b) = scv(z,i1b).*cx1(i1b).* ...
                                        DJ1(i1b)./J1(i1b); 
   i2bI= i & cx2 > xRPI;      a2(i2bI) = u(i2bI);     
   i2mI= i & cx2 <= xRPI;     a2(i2mI) = u(i2mI).*DJ2c(i2mI)./J2c(i2mI);        
   i2bK= i & cx2 > xRPK(n);   b2(i2bK) =-w_(i2bK).*u(i2bK); 
   i2mK= i & cx2 <= xRPK(n);  b2(i2mK) = w_(i2mK).*u(i2mK).* ...
                                         DY2c(i2mK)./Y2c(i2mK);
   r1(i) = scv(z,i)-cx12(i)./cx22(i);
   r2(i) = r1(i).*w_(i);          
   b1(i) = w_(i).*a1(i);
end                                                                            
%ab = cx1./(J1.*cx2.*J2c);
   
                  %switch GD  % выч q=[c;d],t
ks = 0;              
nos = 1;      i = os2(G,D,nos,SZX); 
if any(any(i))   % 1 case: [1,1] = '++'
   ks = ks+1;                  stGD(ks,:) = [nos sum(sum(i))]; 
   i3bK = i & x3 > xRPK(n);    v(i3bK) = RPK(n)./x3(i3bK); 
   i3mK = i & x3 <=xRPK(n);    v(i3mK) = DK3(i3mK)./(x3(i3mK).*K3(i3mK)); 
   S2(i) = 1./x32(i)+1./x22(i);   
   C2(i) = DJ2(i)./x2(i);      C1(i) = v(i).*J2(i);             
   d2(i) = DY2(i)./x2(i);      d1(i) = v(i).*Y2(i);   
   t1(i) = S2(i).*J2(i);       t2(i) = S2(i).*Y2(i); 
end
%gd = 1./(x3.*x2.*K3);

nos = 2;     i = os2(G,D,nos,SZX); 
if any(any(i))    % 2 case: [-1,1] = '-+'
   ks = ks+1;                 stGD(ks,:) = [nos sum(sum(i))];  
   w_(i) = Y2(i)./J2(i);
   i3bK = i & x3 > xRPK(n);   C1(i3bK) = -x22(i3bK).*xRPK(n)./x3(i3bK); 
   i3mK = i & x3 <=xRPK(n);   C1(i3mK) = -x22(i3mK).*DK3(i3mK)./ ...
                                         (x3(i3mK).*K3(i3mK));
   i2bI = i & x2 > xRPI;      C2(i2bI) = x2(i2bI);      
   i2mI = i & x2 <=xRPI;      C2(i2mI) = x2(i2mI).*DJ2(i2mI)./J2(i2mI);
   i2bK = i & x2 > xRPK(n);   d2(i2bK) = -w_(i2bK).*x2(i2bK);  
   i2mK = i & x2 <=xRPK(n);   d2(i2mK) = w_(i2mK).*x2(i2mK).* ...
                                         DY2(i2mK)./Y2(i2mK);
   t1(i) = -x22(i)./x32(i)+1;    t2(i) = t1(i).*w_(i);     
   d1(i) = C1(i).*w_(i);
end                    
%gd = x2./(x3.*J2.*K3);

nos = 3;     i = os2(G,D,nos,SZX); 
if any(any(i))    % 3 case: [0,1] = '0+'
   ks = ks+1;                stGD(ks,:) = [nos sum(sum(i))]; 
   i3bK= i & x3 > xRPK(n);   d1(i3bK) = scv(z2,i3bK).*x22(i3bK)./...
                                        x3(i3bK)*RPK(n);
   i3mK= i & x3 <=xRPK(n);   d1(i3mK) = scv(z2,i3mK).*x22(i3mK).* ...
                                        DK3(i3mK)./(x3(i3mK).*K3(i3mK));
   i2m = i & x2 < 1e-8;      d2(i2m)  = -n;  
   i2b = i & x2 >=1e-8;      d2(i2b)  = x2(i2b).*DY2(i2b)./Y2(i2b);
   w(i)  = J2(i)./Y2(i);  
   C2(i) = d2(i).*DJ2(i)./DY2(i);         C1(i) = d1(i).*w(i);  
   t2(i) = scv(z2,i).*x22(i)./x32(i)+1;   t1(i) = t2(i).*w(i);
end                         
%gd = x2./(x3.*Y2.*K3);

nos = 4;     i = os2(G,D,nos,SZX); 
if any(any(i))    % 4 case: [1,0] = '+0'
   ks = ks+1;                 stGD(ks,:) = [nos sum(sum(i))];  
   i3m = i & x3 < 1e-8;       v(i3m) = -n;  
   i3b = i & x3 >= 1e-8;      v(i3b) = x3(i3b).*DK3(i3b)./K3(i3b); 
   u(i)  = x32(i)./x2(i);     C2(i) = u(i).*DJ2(i);  C1(i) = v(i).*J2(i); 
   S2(i) = 1+x32(i)./x22(i);  d2(i) = u(i).*DY2(i);  d1(i) = v(i).*Y2(i);   
   t1(i) = S2(i).*J2(i);      t2(i) = S2(i).*Y2(i);   end                   
%gd = x3./(x2.*K3);

nos = 5;     i = os2(G,D,nos,SZX); 
if any(any(i))    % 5 case: [-1,0] = '-0'
   ks = ks+1;                 stGD(ks,:) = [nos sum(sum(i))]; 
   w_(i)  = Y2(i)./J2(i);     u(i)     = x32(i)./x2(i);
   i3m = i & x3 < 1e-8;       C1(i3m)  = n;      
   i3b = i & x3 >= 1e-8;      C1(i3b)  = -x3(i3b).*DK3(i3b)./K3(i3b);
   i2bI = i & x2 > xRPI;      C2(i2bI) = u(i2bI);      
   i2mI = i & x2 <=xRPI;      C2(i2mI) = u(i2mI).*DJ2(i2mI)./J2(i2mI);
   i2bK = i & x2 > xRPK(n);   d2(i2bK) = -w_(i2bK).*u(i2bK);  
   i2mK = i & x2 <=xRPK(n);   d2(i2mK) = w_(i2mK).*u(i2mK).* ...
                                         DY2(i2mK)./Y2(i2mK); 
   t1(i) = -1+x32(i)./x22(i);    t2(i) = t1(i).*w_(i);  
   d1(i) = C1(i).*w_(i); 
end                     
%gd = x3./(x2.*J2.*K3);

nos = 6;     i = os2(G,D,nos,SZX);
if any(any(i))   % 6 case: [0,0] = '00'
   ks = ks+1;               stGD(ks,:) = [nos sum(sum(i))]; 
   i3m = i & x3 < 1e-8;     d1(i3m) = -scv(z2,i3m).*x22(i3m)*n; 
   i3b = i & x3 >= 1e-8;    d1(i3b) = scv(z2,i3b).*x22(i3b).* ...
                                      x3(i3b).*DK3(i3b)./K3(i3b);  
   i2m = i & x2 < 1e-8;     d2(i2m) = -x32(i2m)*n;    
   i2b = i & x2 >= 1e-8;    d2(i2b) = x32(i2b).*x2(i2b).*DY2(i2b)./Y2(i2b); 
   w(i) = J2(i)./Y2(i);     
   C1(i) = d1(i).*w(i);                C2(i) = d2(i).*DJ2(i)./DY2(i); 
   t2(i) = scv(z2,i).*x22(i)+x32(i);   t1(i) = t2(i).*w(i); 
end    
%gd = x2.*x3./(Y2.*K3);

a = a2 - a1;       b = b2 - b1;      C = C2 + C1;      d  = d2 + d1;
a_= a2 - a1.*e1;   b_= b2 - b1.*e1;  C_= C2 + C1.*e3;  d_ = d2 + d1.*e3;
nU2 = n^2*(x12-z.*x22.*e1)./(x12-z.*x22);
f= (a.*d - b.*C ).*(a_.*d_ - b_.*C_)./nU2 + nU2.*(r1.*t2 - r2.*t1).^2 ...
 - (a.*t2 - b.*t1).*(a_.*t2 - b_.*t1) - (C.*r2-d.*r1).*(C_.*r2-d_.*r1)...
              - 2*(C .*t2 - d .*t1) .* (a.*r2 - b.*r1);
          
%________ХФ для 3-СВ, когда х - массив(ARray) с исп Номеров ОСобенностей__
function f = HF3_arN( nT, n, c, c_s, ee, V_2, x, nos)       
global  xRPI xRPK RPK
global J1 DJ1   J2c DJ2c   Y2c DY2c   J2 DJ2   Y2 DY2
%TSV={'1) e1 > 1 > e3','2) 1 > e1 > e3','3) e1 > e3 > 1','4) 1 > e3 > e1'};
[e1 e3] = matee(ee);
SZX  = size(x);    
SZAD = [SZX(1) 1];    
NCOL = 1;    % №(1-5) колонки матрицы х, по каждому х(i,NCOL) к-ой опр-ся 
             % ос-ть для всех x(i,1:5), соотв-х сетке L в i-й строке
u   = nan(SZX);   v    = u;
j1  = u;   j2   = u;   S1   = u;   S2  = u;   r1  = u;  r2 = u;  
a2  = u;   a1   = u;   b2   = u;   b1  = u;   t1  = u;  t2 = u;
C2  = u;   C1   = u;   d2   = u;   d1  = u;   w   = u;  w_ = u;  
J1  = u;   J2c  = u;   Y2c  = u;   J2  = u;   Y2  = u;   
DJ1 = u;   DJ2c = u;   DY2c = u;   DJ2 = u;   DY2 = u;

x_2 = x.^2;       V_2_X  = V_2-x_2;    xnan = V_2_X < 0;
x(xnan) = NaN;    x_2(xnan) = NaN;   V_2_X(xnan) = NaN;  
if     nT == 1  % e1 > 1 > e3:  x12z > 0  x22z - любой
   x1   = x;           x12  = x_2;           x32 = V_2_X;     
   x22z = (( 1-e3).*x12 - (e1-1).*x32)./(e1-e3);  
   x22  = abs(x22z);   x2  = sqrt(x22);  
   cx1  = c*x1;        cx2 = c*x2;   
   z1 = 1;             JD1(n,cx1);   % JD1_ar(n,cx1,iT)    %- проверить
   p2 = x22z >= 0;     m2  = x22z < 0;
   
   if      all(m2),  z2 =-1;  IKD2(n,cx2,x2);
   elseif  all(p2),  z2 = 1;  JYD2(n,cx2,x2); 
   else    z2 = ones(SZX);    z2(m2) = -1;   z2(xnan) = NaN;
           JYD2_ar(n,cx2(p2),x2(p2),p2);  
           IKD2_ar(n,cx2(m2),x2(m2),m2);
   end
    
elseif nT == 2  % 1 > e1 > e3:  x12z - любой  x22z > 0  
   x2   = x;             x22  = x_2;         x32 = V_2_X; 
   x12z = ((e1-e3).*x22 + (e1-1).*x32)./(1-e3);  
   x12  = abs(x12z);     x1  = sqrt(x12);
   cx1  = c*x1;          cx2 = c*x2;    
   p1   = x12z >= 0;     m1  = x12z < 0;
   
   if      all(m1),  z1 =-1;   ID1(n,cx1);
   elseif  all(p1),  z1 = 1;   JD1(n,cx1);
   else    z1 = ones(SZX);     z1(m1) = -1;  z1(xnan) = NaN;
           JD1_ar(n,cx1(p1),p1);   ID1_ar(n,cx1(m1),m1);
   end
   z2 = 1; JYD2(n,cx2,x2);
    
elseif nT == 3  % e1 > e3 > 1 :  x12z > 0       x22z < 0
   x1  = x;             x12 = x_2;      x22 = V_2_X; 
   x2  = sqrt(x22);
   x32 = ((1-e3).*x12 + (e1-e3).*x22)./(e1-1);
   m3 = x32 < 0;        x32(m3) = NaN;
   if any(m3)
      fprintf('HF_3: nT=3, x32<0\nx12=');   fprintf('%g',x12(m3)); 
      fprintf('\nx22='); fprintf('%g',x22(m3)); fprintf('\n'); 
   end
      
   cx1 = c*x1;          cx2 = c*x2;
   z1 = 1;              JD1(n,cx1); 
   z2 =-1;              IKD2(n,cx2,x2);

else  %nT == 4  1 > e3 > e1:   x12z < 0        x22z > 0  
   x2  = x;             x22 = x_2;     x12 = V_2_X; 
   x1  = sqrt(x12);
   x32 = (-(1-e3).*x12 - (e1-e3).*x22)./(e1-1);
   m3 = x32 < 0;        x32(m3) = NaN;
   if any(m3)
      fprintf('HF_3: nT=4, x32<0\nx12=');   fprintf('%g',x12(m3)); 
      fprintf('\nx22='); fprintf('%g',x22(m3)); fprintf('\n'); 
   end
  
   cx1 = c*x1;          cx2 = c*x2;
   z1 =-1;              ID1(n,cx1);
   z2 = 1;              JYD2(n,cx2,x2);  end

cx12 = cx1.^2;        cx22     = cx2.^2;
x3   = sqrt(x32);     [K3 DK3] = KD3(n,x3);
z = z1.*z2;

if     nos(1) == 1     % 1 case: [1,1] = '++'
   u  = J1./cx2;      v = DJ1./cx1; 
   S1 = J1./cx12-J1./cx22;   
   a2 = u.*DJ2c;      a1 = v.*J2c;
   b2 = u.*DY2c;      b1 = v.*Y2c;         
   r1 = S1.*J2c;      r2 = S1.*Y2c; 
   %ab = 1./(cx1.*cx2);
elseif nos(1) == 2    % 2 case: [-1,1] = '-+'
   i1bI = cx1 >  xRPI;    v(i1bI) = -1./cx1(i1bI); 
   i1mI = cx1 <= xRPI;    v(i1mI) = -DJ1(i1mI)./(cx1(i1mI).*J1(i1mI));
   S1 = -1./cx12-1./cx22; 
   a2 = DJ2c./cx2;      a1 = v .*J2c;      
   r1 = S1.*J2c;        r2 = S1.*Y2c;                 
   b2 = DY2c./cx2;      b1 = v .*Y2c;
   %ab = 1./(cx1.*J1.*cx2);
elseif nos(1) == 3    % 3 case: [0,1] =  '0+'
   i1m = cx1 <  1e-8;   j1(i1m) = z*n;    % в этой ф-ции scv(z,i1m) = z
   i1b = cx1 >= 1e-8;   j1(i1b) = z.*cx1(i1b).*DJ1(i1b)./J1(i1b);                                       
   S1 = z-cx12./cx22;     
   u  = cx12./cx2;          
   r1 = S1.*J2c;    r2 = S1.*Y2c;
   a2 = u.*DJ2c;    a1 = j1.*J2c;  
   b2 = u.*DY2c;    b1 = j1.*Y2c;
   %ab = cx1./(J1.*cx2);
elseif nos(1) == 4    % 4 case: [1,0] = '+0'
   i2m = cx2 < 1e-8;    b2(i2m) = -J1(i2m)*n; 
   i2b = cx2 >= 1e-8;   b2(i2b) = J1(i2b).*cx2(i2b).*DY2c(i2b)./Y2c(i2b);                                       
   w  = J2c./Y2c;       b1 = z.*cx22.*DJ1./cx1;   
   r2 = J1.*(z.*cx22./cx12-1);                   
   r1 = r2.*w;      
   a1 = b1.*w;          a2 = b2.*DJ2c./DY2c;                  
   %ab = cx2./(cx1.*Y2c);
elseif nos(1) == 5   % 5 case: [-1,0] = '-0'
   i1bI = cx1 > xRPI;    b1(i1bI)= z.*cx22(i1bI)./cx1(i1bI); 
   i1mI = cx1 <= xRPI;   b1(i1mI)= z.*cx22(i1mI).* ...
                                   DJ1(i1mI)./(cx1(i1mI).*J1(i1mI));
   i2m = cx2 < 1e-8;     j2(i2m) = n;          b2(i2m) = -n;    
   i2b = cx2 >= 1e-8;    j2(i2b) = cx2(i2b).*DJ2c(i2b)./J2c(i2b);
                         b2(i2b) = cx2(i2b).*DY2c(i2b)./Y2c(i2b); 
   w  = J2c./Y2c; 
   a2 = w.*j2;             a1 = w.*b1; 
   r2 = z.*cx22./cx12-1;   r1 = r2.*w;                                
   %ab = cx2./(cx1.*J1.*Y2c);
elseif nos(1) == 6    % 6 case: [0,0] = '0+'
   i1m = cx1 <  1e-8;    b1(i1m) = z.*cx22(i1m)*n; 
   i1b = cx1 >= 1e-8;    b1(i1b) = z.*cx22(i1b).* ...
                                   cx1(i1b).*DJ1(i1b)./J1(i1b);
   i2m = cx2 <  1e-8;    b2(i2m) = -cx12(i2m)*n;  
   i2b = cx2 >= 1e-8;    b2(i2b) = cx12(i2b).*cx2(i2b).* ...
                                   DY2c(i2b)./Y2c(i2b);
   w  = J2c./Y2c;     
   a1 = w.*b1;           a2 = b2.*DJ2c./DY2c;                     
   r2 = z.*cx22-cx12;    r1 = r2.*w;                         
   %ab = cx1.*cx2./(J1.*Y2c);
elseif nos(1) == 7   % 7 case: [1,-1] = '+-'
   w_= Y2c./J2c;      u = J1./cx2;
   i2bI = cx2 > xRPI;      a2(i2bI) = u(i2bI);     
   i2mI = cx2 <= xRPI;     a2(i2mI) = u(i2mI).*DJ2c(i2mI)./J2c(i2mI);
   i2bK = cx2 > xRPK(n);   b2(i2bK) = -w_(i2bK).*u(i2bK); 
   i2mK = cx2 <= xRPK(n);  b2(i2mK) =  w_(i2mK).*u(i2mK).* ...
                                       DY2c(i2mK)./Y2c(i2mK);
   r1 = -J1./cx12-J1./cx22;    a1 = -DJ1./cx1;                    
   r2 = r1.*w_;                b1 = a1.*w_;       
   %ab = 1./(cx1.*cx2.*J2c);
elseif nos(1) == 8    % 8 case: [-1,-1] = '--'
   w_  = Y2c./J2c;
   i1bI = cx1 >  xRPI;    a1(i1bI) = 1./cx1(i1bI);  
   i1mI = cx1 <= xRPI;    a1(i1mI) = DJ1(i1mI)./(cx1(i1mI).*J1(i1mI));
   i2bI = cx2 >  xRPI;    a2(i2bI) = 1./cx2(i2bI);  
   i2mI = cx2 <= xRPI;    a2(i2mI) = DJ2c(i2mI)./(cx2(i2mI).*J2c(i2mI));
   i2bK = cx2 >  xRPK(n);   b2(i2bK) = -w_(i2bK)./cx2(i2bK); 
   i2mK = cx2 <= xRPK(n);   b2(i2mK) = w_(i2mK).*DY2c(i2mK)./ ...
                                      (cx2(i2mK).*Y2c(i2mK));
   r1 = 1./cx12-1./cx22;    r2 = r1.*w_;  
   b1 = a1.*w_;        
   %ab = 1./(cx1.*J1.*cx2.*J2c);
elseif nos(1) == 9      % 9 case: [0,-1] = '0-'
   u = cx12./cx2;          w_ = Y2c./J2c; 
   i1m = cx1 <  1e-8;      a1(i1m) = z*n;   
   i1b = cx1 >= 1e-8;      a1(i1b) = z.*cx1(i1b).*DJ1(i1b)./J1(i1b);                                     
   i2bI= cx2 >  xRPI;      a2(i2bI) = u(i2bI);     
   i2mI= cx2 <= xRPI;      a2(i2mI) = u(i2mI).*DJ2c(i2mI)./J2c(i2mI);        
   i2bK= cx2 >  xRPK(n);   b2(i2bK) = -w_(i2bK).*u(i2bK); 
   i2mK= cx2 <= xRPK(n);   b2(i2mK) = w_(i2mK).*u(i2mK).* ...
                                      DY2c(i2mK)./Y2c(i2mK);
   r1 = z-cx12./cx22;      r2 = r1.*w_;            
   b1 = w_.*a1; 
end                                                                            
   %ab = cx1./(J1.*cx2.*J2c);
   
                  %switch GD  % выч q=[c;d],t
if nos(2) == 1       % 1 case: [1,1] = '++'
   i3bK = x3 > xRPK(n);    v(i3bK) = RPK(n)./x3(i3bK); 
   i3mK = x3 <=xRPK(n);    v(i3mK) = DK3(i3mK)./(x3(i3mK).*K3(i3mK)); 
   S2 = 1./x32+1./x22;   
   C2 = DJ2./x2;      C1 = v.*J2;             
   d2 = DY2./x2;      d1 = v.*Y2;   
   t1 = S2.*J2;       t2 = S2.*Y2;  
   %gd = 1./(x3.*x2.*K3);
elseif nos(2) == 2       % 2 case: [-1,1] = '-+'
   w_ = Y2./J2;
   i3bK = x3 > xRPK(n);   C1(i3bK) = -x22(i3bK).*xRPK(n)./x3(i3bK); 
   i3mK = x3 <=xRPK(n);   C1(i3mK) = -x22(i3mK).*DK3(i3mK)./ ...
                                     (x3(i3mK).*K3(i3mK));
   i2bI = x2 > xRPI;      C2(i2bI) = x2(i2bI);      
   i2mI = x2 <=xRPI;      C2(i2mI) = x2(i2mI).*DJ2(i2mI)./J2(i2mI);
   i2bK = x2 > xRPK(n);   d2(i2bK) = -w_(i2bK).*x2(i2bK);  
   i2mK = x2 <=xRPK(n);   d2(i2mK) = w_(i2mK).*x2(i2mK).* ...
                                     DY2(i2mK)./Y2(i2mK);
   t1 = -x22./x32+1;    t2 = t1.*w_;     
   d1 = C1.*w_;                     
   %gd = x2./(x3.*J2.*K3);
elseif nos(2) == 3       % 3 case: [0,1] = '0+'
   i3bK = x3 > xRPK(n);   d1(i3bK) = z2.*x22(i3bK)./x3(i3bK)*RPK(n);                                  
   i3mK = x3 <=xRPK(n);   d1(i3mK) = z2.*x22(i3mK).* ...
                                     DK3(i3mK)./(x3(i3mK).*K3(i3mK));
   i2m = x2 < 1e-8;       d2(i2m)  = -n;  
   i2b = x2 >=1e-8;       d2(i2b)  = x2(i2b).*DY2(i2b)./Y2(i2b);
   w  = J2./Y2;  
   C2 = d2.*DJ2./DY2;     C1 = d1.*w;  
   t2 = z2.*x22./x32+1;   t1 = t2.*w;                          
   %gd = x2./(x3.*Y2.*K3);
elseif nos(2) == 4       % 4 case: [1,0] = '+0'
   i3m = x3 < 1e-8;       v(i3m) = -n;  
   i3b = x3 >= 1e-8;      v(i3b) = x3(i3b).*DK3(i3b)./K3(i3b); 
   u  = x32./x2;     C2 = u.*DJ2;  C1 = v.*J2; 
   S2 = 1+x32./x22;  d2 = u.*DY2;  d1 = v.*Y2;   
   t1 = S2.*J2;      t2 = S2.*Y2;                   
   %gd = x3./(x2.*K3);
elseif nos(2) == 5       % 5 case: [-1,0] = '-0'
   w_  = Y2./J2;         u = x32./x2;
   i3m = x3 < 1e-8;      C1(i3m)  = n;      
   i3b = x3 >= 1e-8;     C1(i3b)  = -x3(i3b).*DK3(i3b)./K3(i3b);
   i2bI = x2 > xRPI;     C2(i2bI) = u(i2bI);      
   i2mI = x2 <=xRPI;     C2(i2mI) = u(i2mI).*DJ2(i2mI)./J2(i2mI);
   i2bK = x2 > xRPK(n);  d2(i2bK) = -w_(i2bK).*u(i2bK);  
   i2mK = x2 <=xRPK(n);  d2(i2mK) = w_(i2mK).*u(i2mK).*DY2(i2mK)./Y2(i2mK);                                          
   t1 = -1+x32./x22;     t2 = t1.*w_;  
   d1 = C1.*w_;                      
   %gd = x3./(x2.*J2.*K3);
elseif nos(2) == 6      % 6 case: [0,0] = '00'
   i3m = x3 < 1e-8;    d1(i3m) = -z2.*x22(i3m)*n; 
   i3b = x3 >= 1e-8;   d1(i3b) = z2.*x22(i3b).*x3(i3b).*DK3(i3b)./K3(i3b);                                   
   i2m = x2 < 1e-8;    d2(i2m) = -x32(i2m)*n;    
   i2b = x2 >= 1e-8;   d2(i2b) = x32(i2b).*x2(i2b).*DY2(i2b)./Y2(i2b); 
   w = J2./Y2;     
   C1 = d1.*w;         C2 = d2.*DJ2./DY2; 
   t2 = z2.*x22+x32;   t1 = t2.*w;      
   %gd = x2.*x3./(Y2.*K3);
else  f = sprintf('%g = nos(2) > 6',nos(2));  return
end

a = a2 - a1;       b = b2 - b1;      C = C2 + C1;      d  = d2 + d1;
a_= a2 - a1.*e1;   b_= b2 - b1.*e1;  C_= C2 + C1.*e3;  d_ = d2 + d1.*e3;
nU2 = n^2*(x12-z.*x22.*e1)./(x12-z.*x22);
f= (a.*d - b.*C ).*(a_.*d_ - b_.*C_)./nU2 + nU2.*(r1.*t2 - r2.*t1).^2 ...
 - (a.*t2 - b.*t1).*(a_.*t2 - b_.*t1) - (C.*r2-d.*r1).*(C_.*r2-d_.*r1)...
              - 2*(C .*t2 - d .*t1) .* (a.*r2 - b.*r1); 
          
%_____________СКаляр или Вектор___________________________________________
function sc = scv(z,i)  
if length(z) == 1,  sc = z;
else                sc = z(i);  end

%__________________обл-ти ос-ти ф-ции  HF для отсечки___________________________________
function [A B G] = ooHFot( nT, n, c, c_s, x, u3)
global Ieq1 Yeq1 Keq1
% A B G - в общем случае векторы, причем м.б неодновременно, =>
%         не м.б заменены одним классификатором ос-тей КО
% с_s = [cGR suz]
% сGR - сГРаничное: 0.1-0.5; в отсечке D опр-ть не нужно, тк D=0 всегда
% suz - к-т сужения ин-ла 0-особенности: 0.01-1: suz*(Ieq1n,Yeq1n,Keq1n)
 
cGR    = c_s(1);        suz   = c_s(2);
Ieq1n  = Ieq1(n+1);     Yeq1n = Yeq1(n+1);    Keq1n = Keq1(n+1);
Iepsn  = suz*Ieq1n;     Yepsn = suz*Yeq1n;    Kepsn = suz*Keq1n;
KIepsn = min(Kepsn,Iepsn);                    Jepsn = 0.1;
z1  = 1; 
JI  = Jepsn;
z2  = 1; 
YKI = Yepsn;
u3_ = 1./u3;          % u3   = (e1-e3)/(1-e3); 

if     nT == 1  % x12z > 0           x22z>0(в отсечке)
       cx1 = c*x;   x2  = sqrt(x.^2.*u3_);  cx2 = c*x2;   
           
elseif nT == 2  % x12z>0(в отсечке)  x22z > 0  
       x2  = x;     cx2 = c*x2;             cx1 = sqrt(cx2.^2.*u3);
           
elseif nT == 3  % x12z > 0           x22z < 0
       cx1 = c*x;   x2  = sqrt(-x.^2.*u3_); cx2 = c*x2;
       z2  = -1;    YKI = KIepsn;  
     
else  %nT == 4    x12z < 0           x22z > 0  
      x2  = x;      cx2 = c*x2;             cx1 = sqrt(-cx2.^2.*u3);
      z1  = -1;     JI  = Iepsn;
end

A = stup(cx1,JI, z1,0);
G = stup( x2,YKI,z2,0);
if c >= cGR,  B = G;
else          B = stup(cx2,YKI,z2,0);  end

%_____________ скалярная или векторная СТУПенька ____________________
function st = stup( X, G, a, b)  
% st = a, b или 0 на области определения X
% st = NaN     вне ее 
% G - скаляр или вектор той же размерности, что и Х
i = X > G;
if    all(i),  st = a;
else
   j = X < G;
   if all(j),  st = b;
   else
      k = X == G;
      if all(k),  st = 0;
      else
         st = X; 
         st(i) = a;
         st(j) = b;
         st(k) = 0;
      end
   end
end

%____________лог индекс от 2-х особенностей для HF3_ar_ (с исп tabNOS)
function i = os2( A, B, nos, SZX)     
global tabNOS    % ТАБлица Номеров ОСобенностей
a = tabNOS(nos,1);
b = tabNOS(nos,2);
lenB = length(B);                 %  означает i = (A == a) & (B == b); 
if length(A) == 1
   if  lenB == 1,  i = logical(  (A==a  &&   B==b)*ones(SZX) );
   else            i = logical( +(A==a)*diag(B==b)*ones(SZX) );
   end
   
elseif lenB == 1,  i = logical( +diag(A==a)*(B==b)*ones(SZX) );
else               i = logical(  diag(A==a & B==b)*ones(SZX) ); 
end

%____________лог индекс от 2-х ОСобенностей для HFot_ar_____________
function i = os2SR( A, B, a, b, SZX)     
lenB = length(B);                  %  означает i = A == a & B == b; 
if length(A) == 1
   if  lenB == 1,  i = logical( (A==a && B==b)*ones(SZX) );
   else            i = logical( +(A==a)*(B==b) );
   end
   
elseif lenB == 1,  i = logical( +(A==a)*(B==b) );
else               i = A==a & B==b; 
end

%____________лог индекс от одной ОСобенности__________________________
function i = osSR(G,g,SZX)       
if length(G) == 1, i = logical( (G==g)*ones(SZX));
else               i = G==g;   end    

%____________ХФ для отсечки____________________________________________
function f = HFot( nT, n, c, eew, x, u1,u2,u3, KO)
%б.правильно считать е1,е3 так: L = dva*pi*D/x; e1 = n_2kZ(L^2,KZ(:,1))
global  J1 DJ1  J2c Y2c   J2 Y2   DJ2c DY2c  xRPI xPZ
u3_ = 1./u3;                % u3   = (e1-e3)/(1-e3); 
e1  = eew(1);  
e3  = eew(2);
if     nT == 1              % x12z > 0      x22z > 0(в отсечке)
   cx1 = c*x;               x22z = x.^2.*u3_;% x12 = x.^2;
   x2  = sqrt(abs(x22z));   cx2  = c*x2;   
   JD1(n,cx1);              JYD2ot(n,cx2,x2);
   
elseif nT == 2              % x12z>0(в отсечке), x22z > 0  
   x2   = x;                cx2 = c*x2;
   x12z = x2.^2.*u3;        cx1 = c*sqrt(abs(x12z));
   JD1(n,cx1);              JYD2ot(n,cx2,x2);

elseif nT == 3              % x12z > 0     x22z < 0
   cx1 = c*x;   
   x2  = sqrt(-x.^2.*u3_);  cx2 = c*x2;
   JD1(n,cx1);              IKD2ot(n,cx2,x2);

else  %nT == 4              x12z < 0      x22z > 0  % u3 = (e1-e3)/(1-e3); 
   x2  = x;                 cx2 = c*x2;
   cx1 = sqrt(-cx2.^2.*u3);  
   ID1(n,cx1);              JYD2ot(n,cx2,x2);
end
 
                            % switch AB  % выч p=[a;b],r
if     KO(1:2) == [1 1],    % A == 1 && B == 1    % case '++'
   A2 = cx2.*J1;         A1 = cx1.*DJ1;
   if cx1(1) < cx2(1),   A2 = A2.*u3;    u  = J1.*u2;
   else                  A1 = A1.*u3_;   u  = J1.*u1;  end    
   a2 = A2.*DJ2c;  a1 = A1.*J2c;   r1 = u.*J2c;  
   b2 = A2.*DY2c;  b1 = A1.*Y2c;   r2 = u.*Y2c;
   %ab = 1./(cx1.*cx2);
   
elseif KO(1:2) == [1 -1],    % A == 1 && B == -1    % case '+-'
   wc_ = Y2c./J2c;      a1    = cx1.*DJ1; 
   
   j = find(cx2>xRPI);  a2    = J1.*cx2.*DJ2c./J2c;
   if ~isempty(j),      a2(j) = J1(j).*cx2(j);  end
   %if cx2 > xRPI,      a2    = J1.*cx2; 
   %else                a2    = J1.*cx2.*DJ2c./J2c; end 
   
   if cx1(1) < cx2(1),  a2 = a2.*u3;        r1 = J1.*u2; 
   else                 a1 = a1.*u3_;       r1 = J1.*u1;           end                   
   b2 = a2.*DY2c./DJ2c; b1 = a1.*wc_;       r2 = r1.*wc_; 
   %ab = 1./(cx1.*cx2.*J2c);

elseif KO(1:2) == [1 0],    % A == 1 && B == 0    % case '+0'
   wc = J2c./Y2c;         b1    = cx1.*DJ1./u3;
   
   j = find(cx2<xPZ(n));  b2    = J1.*cx2.*DY2c./Y2c;
   if ~isempty(j),        b2(j) = -J1(j)*n;  end
   %if cx2 < 1e-8,        b2    = -J1*n;
   %else                  b2    = J1.*cx2.*DY2c./Y2c; end
   
   a2 = b2.*DJ2c./DY2c; a1 = b1.*wc;        r2 = J1.*u1;   r1 = r2.*wc;                                
   %ab = cx2./(cx1.*Y2c);

elseif KO(1:2) == [-1 1],    % A == -1 && B == 1    % case '-+'
   i = find(cx1>xRPI);  j1    = -cx1.*DJ1./J1;
   if ~isempty(i),      j1(i) = -cx1(i);  end
   %if cx1 > xRPI,      j1    = -cx1; 
   %else                j1    = -cx1.*DJ1./J1;  end
   
   a2 = cx2.*DJ2c;     a1 = j1.*J2c;  b2 = cx2.*DY2c;  b1 = j1.*Y2c;
   if cx1(1) < cx2(1), a2 = a2.*u3;   b2 = b2.*u3;     u  = u2;  
   else                a1 = a1.*u3_;  b1 = b1.*u3_;    u  = u1;   end 
   r1 = u.*J2c;        r2 = u.*Y2c;     
   %ab = 1./(cx1.*J1.*cx2);

elseif KO(1:2) == [-1 -1],    % A == -1 && B == -1    % case '--'
   wc_ = Y2c./J2c;
   
   i = find(cx1>xRPI);  a1    = cx1.*DJ1./J1;
   if ~isempty(i),      a1(i) = cx1(i);  end
   %if cx1 > xRPI,      a1    = cx1;  
   %else                a1    = cx1.*DJ1./J1;   end
   
   j = find(cx2>xRPI);  a2    = cx2.*DJ2c./J2c;
   if ~isempty(j),      a2(j) = cx2(j);  end
   %if cx2 > xRPI,      a2    = cx2;  
   %else                a2    = cx2.*DJ2c./J2c; end
   
   if cx1(1) < cx2(1),  a2 = a2.*u3;        r1 = u2;                   
   else                 a1 = a1.*u3_;       r1 = u1;           end
   b2 = a2.*DY2c./DJ2c; b1 = a1.*wc_;       r2 = r1.*wc_;  
   %ab = 1./(cx1.*J1.*cx2.*J2c); 
   
elseif KO(1:2) == [-1 0],    % A == -1 && B == 0    % case '-0'
   wc = J2c./Y2c;
   
   i = find(cx1>xRPI); b1    = u3_.*cx1.*DJ1./J1;
   if ~isempty(i),     b1(i) = u3_(i).*cx1(i);  end
   %if cx1 > xRPI,     b1    = u3_.*cx1;
   %else               b1    = u3_.*cx1.*DJ1./J1; end
   
   j = find(cx2<xPZ(n));  b2    = cx2.*DY2c./Y2c; 
   if ~isempty(j),        b2(j) = -n;  end
   %if cx2 < 1e-8,        b2    = -n;    
   %else                  b2    = cx2.*DY2c./Y2c;   end
   
   a2 = b2.*DJ2c./DY2c;  a1 = b1.*wc;       r2 = u1;    r1 = r2.*wc;                                      
   %ab = cx2./(cx1.*J1.*Y2c);

elseif KO(1:2) == [0 1],    % A == 0 && B == 1    % case '0+'
   A2 = u3.*cx2; 
   
   i = find(cx1<xPZ(n));  j1    = cx1.*DJ1./J1;
   if ~isempty(i),        j1(i) = n;  end
   %if cx1 < 1e-8,        j1    = n;
   %else                  j1    = cx1.*DJ1./J1;  end      
   
   a2 = A2.*DJ2c;       a1 = j1.*J2c;       r1 = u2.*J2c;
   b2 = A2.*DY2c;       b1 = j1.*Y2c;       r2 = u2.*Y2c; 
   %ab = cx1./(J1.*cx2);

elseif KO(1:2) == [0 -1],    % A == 0 && B == -1    % case '0-'
   wc_ = Y2c./J2c;
   
   i = find(cx1<xPZ(n));   a1    = cx1.*DJ1./J1; 
   if ~isempty(i),         a1(i) = n;  end
   %if cx1 < 1e-8,         a1    = n;     
   %else                   a1    = cx1.*DJ1./J1;      end
   
   j = find(cx2>xRPI);   a2    = u3.*cx2.*DJ2c./J2c;
   if ~isempty(j),       a2(j) = u3(j).*cx2(j);  end
   %if cx2 > xRPI,       a2    = u3.*cx2;
   %else                 a2    = u3.*cx2.*DJ2c./J2c; end
   
   b2 = a2.*DY2c./DJ2c; b1 = a1.*wc_;       r1 = u2;    r2 = r1.*wc_; 
   %ab = cx1./(J1.*cx2.*J2c);
      
elseif KO(1:2) == [0 0],    % A == 0 && B == 0        % case '00'
   wc = J2c./Y2c; 
   
   i = find(cx1<xPZ(n));  b1    = cx1.*DJ1./J1;
   if ~isempty(i),        b1(i) =  n;  end
   %if cx1 < 1e-8,        b1    =  n;  
   %else                  b1    = cx1.*DJ1./J1;   end 
   
   j = find(cx2<xPZ(n));  b2    = cx2.*DY2c./Y2c;
   if ~isempty(j),        b2(j) = -n;  end
   %if cx2 < 1e-8,        b2    = -n;
   %else                  b2    = cx2.*DY2c./Y2c; end          
   
   if cx1(1) < cx2(1),   b2 = b2.*u3;       r2 = u2;
   else                  b1 = b1.*u3_;      r2 = u1; end                          
   a2 = b2.*DJ2c./DY2c;  a1 = b1.*wc;       r1 = r2.*wc;                           
   %ab = cx1.*cx2./(J1.*Y2c);  
end
                                        %switch G  % выч Z 
if     KO(3) == 1, Z1 = J2;      Z2 = Y2;       % '+' gd = x3/(x2*K3)=0;
elseif KO(3) ==-1, Z1 = 1;       Z2 = Y2./J2;   % '-' gd = x3/(x2*J2*K3)=0;   
else              Z1 = J2./Y2;  Z2 = 1;  end   % '0' gd = x2*x3/(Y2*K3)=0;

a = a2-a1;  b = b2-b1;    a_= a2-a1.*e1;   b_= b2-b1.*e1;
f = ( a.*Z2 - b.*Z1 ).*(a_.*Z2 - b_.*Z1) - n^2.*e3.*(r1.*Z2 - r2.*Z1).^2;

%____________ХФ для отсечки и массива(ARr)(новый вар-т, маткад 9 лист)____
function f = HFot_ar( nT, n, c, eew, x, u1,u2,u3, A, B, G) 
% Исп-ся только для векторов. 
% поэтому выражения типа a2(i) = A2.*DJ2c(i) вычисляются правильно.
% здесь: eew = [ e1 e3 ]
% Для 2-мерных массивов не исп-ся и работать будет неверно

global  xRPI
global  J1 DJ1  J2c Y2c J2 Y2 DJ2c DY2c
u3_ = 1./u3;          % u3   = (e1-e3)/(1-e3); 
SZX = size(x);
e1  = eew(1);  e3 = eew(2);
if     nT == 1        % x12z > 0      x22z > 0, тк это отсечка
   cx1 = c*x;    x2  =  sqrt(x.^2.*u3_);   cx2  = c*x2;                
   JD1(n,cx1);   JYD2ot(n,cx2,x2);
   
elseif nT == 2  % x12z>0(в отсечке), x22z > 0  
   x2   = x;     cx2 = c*x2;               cx1 = c*sqrt(x2.^2.*u3);
   JD1(n,cx1);   JYD2ot(n,cx2,x2);

elseif nT == 3  % x12z > 0     x22z < 0
   cx1 = c*x;    x2  = sqrt(-x.^2.*u3_);   cx2 = c*x2;
   JD1(n,cx1);   IKD2ot(n,cx2,x2);

else  %nT == 4     x12z < 0        x22z > 0  % u3   = (e1-e3)/(1-e3); 
   x2  = x;      cx2 = c*x2;               cx1 = sqrt(-cx2.^2.*u3);  
   ID1(n,cx1);   JYD2ot(n,cx2,x2); 
end
 
                           % switch AB  % выч p=[a;b],r
i = os2SR(A,B,1,1,SZX);     % A == 1 & B == 1;                           
if any(i)    % case '++'
   A2 = cx2(i).*J1(i);   A1 = cx1(i).*DJ1(i);
   if any(cx1 < cx2),    A2 = A2.*u3;          u  = J1(i).*u2;
   else                  A1 = A1.*u3_;         u  = J1(i).*u1;    end
   
   a2(i) = A2.*DJ2c(i);  a1(i) = A1.*J2c(i);   r1(i) = u.*J2c(i);  
   b2(i) = A2.*DY2c(i);  b1(i) = A1.*Y2c(i);   r2(i) = u.*Y2c(i);
end     %ab = 1./(cx1.*cx2);
   
i = os2SR(A,B,1,-1,SZX);    % i = A == 1 & B == -1;   
if any(i)    % case '+-'
   wc_ = Y2c(i)./J2c(i);  a1(i) = cx1(i).*DJ1(i);
   s   = cx2>xRPI;
   j   = i& s;            a2(j) = J1(j).*cx2(j);
   k   = i&~s;            a2(k) = J1(k).*cx2(k).*DJ2c(k)./J2c(k);
   
   if any(cx1 < cx2),     a2(i) = a2(i).*u3;      r1(i) = J1(i).*u2; 
   else                   a1(i) = a1(i).*u3_;     r1(i) = J1(i).*u1; end                   
   b2(i) = a2(i).*DY2c(i)./DJ2c(i); b1(i) = a1(i).*wc_; 
   r2(i) = r1(i).*wc_; 
end      %ab = 1./(cx1.*cx2.*J2c);

i = os2SR(A,B,1,0,SZX);    % i = A == 1 & B == 0;  
if any(i)     % case '+0'
   wc = J2c(i)./Y2c(i);   b1(i) = cx1(i).*DJ1(i)./u3;
   s  = cx2 < 1e-8;
   j  = i& s;             b2(j) = -J1(j)*n;
   k  = i&~s;             b2(k) = J1(k).*cx2(k).*DY2c(k)./Y2c(k);
   
   a2(i) = b2(i).*DJ2c(i)./DY2c(i); a1(i) = b1(i).*wc; 
   r2(i) = J1(i).*u1;     r1(i) = r2(i).*wc; 
end   %ab = cx2./(cx1.*Y2c);

i = os2SR(A,B,-1,1,SZX);    % i = A == -1 & B == 1;
if any(i)     % case '-+'
   s = cx1 > xRPI; 
   j = i& s;            j1(j) = -cx1(j);    
   k = i&~s;            j1(k) = -cx1(k).*DJ1(k)./J1(k);
   
   a2(i) = cx2(i).*DJ2c(i);      a1(i) = j1.*J2c(i);  
   b2(i) = cx2(i).*DY2c(i);      b1(i) = j1.*Y2c(i);
   
   if any(cx1<cx2), a2(i) = a2(i).*u3;   b2(i) = b2(i).*u3;  u(i)= u2;  
   else             a1(i) = a1(i).*u3_;  b1(i) = b1(i).*u3_; u(i)= u1; end 
   r1(i) = u.*J2c(i);                    r2(i) = u.*Y2c(i); 
end     %ab = 1./(cx1.*J1.*cx2);

i = os2SR(A,B,-1,-1,SZX);    % i = A == -1 & B == -1;
if any(i)     % case '--'
   wc_ = Y2c(i)./J2c(i);
   s = cx1 > xRPI;
   j = i& s;            a1(j) = cx1(j);    
   k = i&~s;            a1(k) = cx1(k).*DJ1(k)./J1(k);
   
   s = cx2 > xRPI; 
   j = i& s;            a2(j) = cx2(j); 
   k = i&~s;            a2(k) = cx2(k).*DJ2c(k)./J2c(k);
   
   if any(cx1 < cx2),   a2(i) = a2(i).*u3;        r1(i) = u2;                   
   else                 a1(i) = a1(i).*u3_;       r1(i) = u1; end
   
   b2(i) = a2(i).*DY2c(i)./DJ2c(i);   b1(i) = a1(i).*wc_;
   r2(i) = r1(i).*wc_; 
end         %ab = 1./(cx1.*J1.*cx2.*J2c); 

i = os2SR(A,B,-1,0,SZX);    % i = A == -1 & B == 0;    
if any(i)      % case '-0'
   wc = J2c(i)./Y2c(i);
   s = cx1 > xRPI; 
   j = i& s;            b1(j) = u3_.*cx1(j);  
   k = i&~s;            b1(k) = u3_.*cx1(k).*DJ1(k)./J1(k);
   
   s = cx2 < 1e-8;
   j = i& s;            b2(j) = -n;  
   k = i&~s;            b2(k) = cx2(k).*DY2c(k)./Y2c(k);
   
   a2(i) = b2(i).*DJ2c(i)./DY2c(i);  a1(i) = b1(i).*wc; 
   r2(i) = u1;                       r1(i) = r2(i).*wc;                            
end          %ab = cx2./(cx1.*J1.*Y2c);

i = os2SR(A,B,0,-1,SZX);    % i = A == 0 & B == 1;
if any(i)   % case '0+'
   A2 = u3.*cx2(i);
   s = cx1 < 1e-8;
   j = i& s;            j2(j) = n;
   k = i&~s;            j2(k) = cx1(k).*DJ1(k)./J1(k);
   
   a2(i) = A2.*DJ2c(i);  a1(i) = j2.*J2c(i);   r1(i) = u2.*J2c(i);
   b2(i) = A2.*DY2c(i);  b1(i) = j2.*Y2c(i);   r2(i) = u2.*Y2c(i);
end   %ab = cx1./(J1.*cx2);

i = os2SR(A,B,0,-1,SZX);    % i = A == 0 & B == -1;
if any(i)       % case '0-'
   wc_ = Y2c(i)./J2c(i);
   s = cx1 < 1e-8;
   j = i& s;             a1(j) = n; 
   k = i&~s;             a1(k) = cx1(k).*DJ1(k)./J1(k);
   
   s = cx2 > xRPI;
   j = i& s;             a2(j) = u3.*cx2(j);          
   k = i&~s;             a2(k) = u3.*cx2(k).*DJ2c(k)./J2c(k);
                    
   b2(i) = a2(i).*DY2c(i)./DJ2c(i); b1(i) = a1(i).*wc_;
   r1(i) = u2;           r2(i) = r1.*wc_;   
end   %ab = cx1./(J1.*cx2.*J2c);

i = os2SR(A,B,0,0,SZX);    % i = A == 0 & B == 0;   
if any(i)         % case '00'
   wc = J2c(i)./Y2c(i);
   s = cx1 < 1e-8;
   j = i& s;             b1(j) =  n; 
   k = i&~s;             b1(k) = cx1(k).*DJ1(k)./J1(k);
   
   s = cx2 < 1e-8; 
   j = i& s;             b2(j) = -n;          
   k = i&~s;             b2(k) = cx2(k).*DY2c(k)./Y2c(k); 
   
   if any(cx1 < cx2),    b2(i) = b2(i).*u3;       r2(i) = u2;
   else                  b1(i) = b1(i).*u3_;      r2(i) = u1; end                          
   a2(i) = b2(i).*DJ2c(i)./DY2c(i);  
   a1(i) = b1(i).*wc;                             r1(i) = r2(i).*wc; 
end   %ab = cx1.*cx2./(J1.*Y2c);
                                        %switch G  % выч Z
i = osSR(G,1,SZX);  j = osSR(G,-1,SZX);  k = osSR(G,0,SZX);  
% i = G == 1;       j = G ==-1;          k = G == 0;  
if any(i), Z1(i)=J2(i);        Z2(i)=Y2(i);       end %+ gd=x3/(x2*K3)=0
if any(j), Z1(j)=1;            Z2(j)=Y2(j)./J2(j);end %- gd=x3/(x2*J2*K3)=0
if any(k), Z1(k)=J2(k)./Y2(k); Z2(k)=1;           end %0 gd=x2*x3/(Y2*K3)=0

a = a2-a1;  b = b2-b1;    a_= a2-a1.*e1;   b_= b2-b1.*e1;
f = ( a.*Z2 - b.*Z1 ).*(a_.*Z2 - b_.*Z1) - n^2.*e3.*(r1.*Z2 - r2.*Z1).^2;

%__________________Опред Особенностей ХФ для дальнего(FAr) режима________
function [A B G] = ooHFfa( nT, n, c, c_s, x, u3)
% c_s = [cGR suzh]
% сGR - cГраничное
% suz - коэфф_сужения интервала 0-особенности( Yn(0))
global Yeq1   %  A, u3 - не исп
A = NaN; 
if nT == 1 || nT == 3,  B = NaN;  G = NaN;  return,end

Yepsn = Yeq1(n+1) * c_s(2);            % здесь x = x2;                           
G     = stup( x, Yepsn, 1, 0);
if c > c_s(1),  B = G;  
else            B = stup( c*x, Yepsn, 1, 0);  end

% ___________новый вар-т HF для far_____________________________________
function f = HFfa(  nT, n, c, eew, x, u1,u2,u3, KO)
% KO = [A B G]      
% nT, eew, u1,u2,u3, KO(1)- не исп 
% global Yeq1
if isnan(KO(2)) % nT == 1 || nT == 3, x12z > 0      x22z - любой
   cx1 = c*x;         % x=x1
   f = DBF(1,@besselj,n,cx1).^2-(n*besselj(n,cx1)./cx1).^2; 
   % fc = HFfa1(n,c,x,[]); 
   return
end

x2 = x;                cx2 = c*x2;      % x12z - любой  x22z > 0  
Jc = besselj(n,cx2);   DJc = DBF(1,@besselj,n,cx2);
Yc = bessely(n,cx2);   DYc = DBF(1,@bessely,n,cx2);
J  = besselj(n,x2);    DJ  = DBF(1,@besselj,n,x2); 
Y  = bessely(n,x2);    DY  = DBF(1,@bessely,n,x2);
%Yeq1n = Yeq1(n+1);% ос-ти бесс. ф-ций

if KO(2) == 0,    Jc_ = cx2.*DJc./Jc;  Yc_ = cx2.*DYc./Yc; %cx2<Yeq1n, B = 0
   if KO(3) == 0, J_  =  x2.*DJ./J;    Y_  =  x2.*DY./Y;   %x2 <Yeq1n, G = 0
                 L1  = 1./(Jc.*Y);    L2  = 1./(J.*Yc);
      % r = 1/(Jc*Yc*J*Y);  % r - регулятор
      f = (n*(L1-L2)).^2 - (L1.*Yc_-L2.*Jc_).^2 - (L1.*J_-L2.*Y_).^2 +...
         ((L1.*J_.*Yc_-L2.*Jc_.*Y_)/n).^2 + 2*L1.*L2.*(Y_-J_).*(Yc_-Jc_);     
   else
      JJ = DJ./Jc;   YY = DY./Yc;                         % G = +
      L1 =  J./Jc;   L2 =  Y./Yc;
      % r = 1/(Jc*Yc);    
      f = (n*(L1-L2)).^2 - (L1.*Yc_-L2.*Jc_).^2  - (x2.*(JJ-YY)).^2 + ...
          (x2.*(JJ.*Yc_-YY.*Jc_)/n).^2 + ...
          2./(Jc.*Yc).*x2.*(J.*DY-DJ.*Y).*(Yc_-Jc_);
   end
else  % r = 1;                                            % B = +, G = +
      cx2x2 = cx2.*x2; 
      f = (n*(J.*Yc-Jc.*Y)).^2-(cx2.*(J.*DYc-DJc.*Y)).^2 - ...
          (x2.*(Jc.*DY-DJ.*Yc)).^2 + (cx2x2.*(DJ.*DYc-DJc.*DY)/n).^2 ...
          + 2*cx2x2.*(J.*DY-DJ.*Y).*(Jc.*DYc-DJc.*Yc);
end
%{ 
% R = cx2*x2/(cx1*J1*x3*K3);  F = cx1*cx2*x2*x3*J1*Y2c*J2*K3;
RF   = (cx2*x2)^2*Yc*J;
HFC  = HFCfar(n,c,x2,Jc,DJc,Yc,DYc,J,DJ,Y,DY);
fc   = (r*RF)^2*HFC;
 %}
      
 % __________ХФ для режима far(дальнего), когда х - массив(ARray) _______
function f = HFfa_ar( nT, n, c, eew, x, u1,u2,u3, A, B, G) 
% nT, eew, u1,u2,u3, A - не исп
if isnan(B) % nT == 1 || nT == 3, x12z > 0      x22z - любой
   cx1 = c*x;         % x=x1
   f = DBF(1,@besselj,n,cx1).^2-(n*besselj(n,cx1)./cx1).^2; 
   % fc = HFfa1(n,c,x,[]); 
   return
end

x2 = x;                cx2 = c*x2;   % x12z - любой  x22z > 0  
Jc = besselj(n,cx2);   DJc = DBF(1,@besselj,n,cx2);
Yc = bessely(n,cx2);   DYc = DBF(1,@bessely,n,cx2);
J  = besselj(n,x2);    DJ  = DBF(1,@besselj,n,x2); 
Y  = bessely(n,x2);    DY  = DBF(1,@bessely,n,x2);

SZX = size(x);
s = osSR(G,0,SZX);   j = osSR(B,1,SZX);   k = ~s &~j;
% s = G==0;          j = B==1;    
if any(s)   
   Jc_= cx2(s).*DJc(s)./Jc(s);  Yc_= cx2(s).*DYc(s)./Yc(s);%cx2<Yeq1n,B=0
   J_ =  x2(s).*DJ(s)./J(s);    Y_ =  x2(s).*DY(s)./Y(s);  %x2 <Yeq1n,G=0
   L1 = 1./(Jc(s).*Y(s));       L2 = 1./(J(s).*Yc(s));
   % r = 1/(Jc*Yc*J*Y);  % r - регулятор
   f(s) = (n*(L1-L2)).^2 - (L1.*Yc_-L2.*Jc_).^2 - (L1.*J_-L2.*Y_).^2 +...
        ((L1.*J_.*Yc_-L2.*Jc_.*Y_)/n).^2 + 2*L1.*L2.*(Y_-J_).*(Yc_-Jc_); 
end
     
if any(k)     
   Jc_= cx2(k).*DJc(k)./Jc(k);  Yc_= cx2(k).*DYc(k)./Yc(k); %cx2<Yeq1n,B=0
   JJ = DJ(k)./Jc(k);   YY = DY(k)./Yc(k);                  % G = +
   L1 =  J(k)./Jc(k);   L2 =  Y(k)./Yc(k);
   % r = 1/(Jc*Yc);    
   f(k) = (n*(L1-L2)).^2 - (L1.*Yc_-L2.*Jc_).^2 - (x2(k).*(JJ-YY)).^2 ...
       + (x2(k).*(JJ.*Yc_-YY.*Jc_)/n).^2 + ...
       2./(Jc(k).*Yc(k)).*x2(k).*(J(k).*DY(k)-DJ(k).*Y(k)).*(Yc_-Jc_); 
end

if any(j)                       % B = +, G = +
   cx2x2 = cx2(j).*x2(j); 
   f(j) = (n*(J(j).*Yc(j)-Jc(j).*Y(j))).^2-...
      (cx2(j).*(J(j).*DYc(j)-DJc(j).*Y(j))).^2 - ...
      (x2(j).*(Jc(j).*DY(j)-DJ(j).*Yc(j))).^2 + ...
      (cx2x2.*(DJ(j).*DYc(j)-DJc(j).*DY(j))/n).^2 +...
      2*cx2x2.*(J(j).*DY(j)-DJ(j).*Y(j)).*(Jc(j).*DYc(j)-DJc(j).*Yc(j));
end   

%_________________ группа бесселевых ф-ций _________________
%________________________________________________________________
function JD1(n,cx1)
global J1 DJ1
J1 =  besselj(n,cx1);    DJ1 = DBF(1,@besselj,n,cx1);
%________________________________________________________________
function JD1_ar(n,cx1i,i)
global J1 DJ1
J1(i) =  besselj(n,cx1i);    DJ1(i) = DBF(1,@besselj,n,cx1i);
%______________________________________________________
function ID1(n,cx1)
global J1 DJ1
J1 = besseli(n,cx1);     DJ1 = DBF(1,@besseli,n,cx1);
%______________________________________________________
function ID1_ar(n,cx1i,i)
global J1 DJ1
J1(i) = besseli(n,cx1i);     DJ1(i) = DBF(1,@besseli,n,cx1i);
%______________________________________________________
function JYD2(n,cx2,x2)
global J2c Y2c J2 Y2 DJ2c DY2c DJ2 DY2
J2c =  besselj(n,cx2);     DJ2c = DBF(1,@besselj,n,cx2);
Y2c =  bessely(n,cx2);     DY2c = DBF(1,@bessely,n,cx2);
J2  =  besselj(n,x2);      DJ2  = DBF(1,@besselj,n,x2);
Y2  =  bessely(n,x2);      DY2  = DBF(1,@bessely,n,x2);
%______________________________________________________
function  JYD2_ar(n,cx2i,x2i,i)
global J2c Y2c J2 Y2 DJ2c DY2c DJ2 DY2
J2c(i) =  besselj(n,cx2i);     DJ2c(i) = DBF(1,@besselj,n,cx2i);
Y2c(i) =  bessely(n,cx2i);     DY2c(i) = DBF(1,@bessely,n,cx2i);
J2(i)  =  besselj(n,x2i);      DJ2(i)  = DBF(1,@besselj,n,x2i);
Y2(i)  =  bessely(n,x2i);      DY2(i)  = DBF(1,@bessely,n,x2i);
%______________________________________________________
function JYD2ot(n,cx2,x2)
global J2c Y2c J2 Y2 DJ2c DY2c
J2c =  besselj(n,cx2);     DJ2c = DBF(1,@besselj,n,cx2);
Y2c =  bessely(n,cx2);     DY2c = DBF(1,@bessely,n,cx2);
J2  =  besselj(n,x2);      
Y2  =  bessely(n,x2);   
%______________________________________________________
function IKD2(n,cx2,x2)
global J2c Y2c J2 Y2 DJ2c DY2c DJ2 DY2
J2c = besseli(n,cx2);     DJ2c = DBF(1,@besseli,n,cx2);
Y2c = besselk(n,cx2);     DY2c = DBF(1,@besselk,n,cx2);
J2  = besseli(n,x2);      DJ2  = DBF(1,@besseli,n,x2);
Y2  = besselk(n,x2);      DY2  = DBF(1,@besselk,n,x2);
%______________________________________________________
function  IKD2_ar(n,cx2i,x2i,i)
global J2c Y2c J2 Y2 DJ2c DY2c DJ2 DY2
J2c(i) = besseli(n,cx2i);     DJ2c(i) = DBF(1,@besseli,n,cx2i);
Y2c(i) = besselk(n,cx2i);     DY2c(i) = DBF(1,@besselk,n,cx2i);
J2(i)  = besseli(n,x2i);      DJ2(i)  = DBF(1,@besseli,n,x2i);
Y2(i)  = besselk(n,x2i);      DY2(i)  = DBF(1,@besselk,n,x2i);
%______________________________________________________
function IKD2ot(n,cx2,x2)
global J2c Y2c J2 Y2 DJ2c DY2c
J2c = besseli(n,cx2);     DJ2c = DBF(1,@besseli,n,cx2);
Y2c = besselk(n,cx2);     DY2c = DBF(1,@besselk,n,cx2);
J2  = besseli(n,x2);      
Y2  = besselk(n,x2);  
%______________________________________________________
function [K DK] = KD3(n,x3)
K =  besselk(n,x3);     DK = DBF(1,@besselk,n,x3); 

%_________________________________________________________________
% _____________________ ГОРИЗОНТАЛЬНОЕ МЕНЮ (Menu Bar) _____________
function Pokaz_Callback( ~, ~, ~)

% ______ показать эксп.к.Зельмаера ______________________
function pokeKZ_Callback(~, ~, ~)
global teKZ
msgbox( teKZ, 'Эксперимент к-ты Зельмаера' ); 

% ______________________________________________________________________
function pokKZ_Callback(~, ~, ~)
global tKZ
msgbox( tKZ, 'К-ты Зельмаера cветовода' ); 

%________Графики Показателей преломления ___________________________
function pokGPP_Callback(~, ~, ~)
global QS pvB pvZ PGB LZ KZ
global ScreenSize
hh = findobj( 'Enable', 'on');
set( hh, 'Enable', 'off');

while true
    switch menu({''},{ 'Профили слоев+состав',...
                       'Профили баз: Si, Ge, Bor',...
                       'Выход'})
                 
    case 1, KRUP = menu('Расположение',...
                   'На одном экране - все слои',...
                   'На одном экране - один слой') == 2;
            if ~KRUP
               fig1 = figure('Position', ScreenSize, 'MenuBar','none',...
                      'Name','Профили ПП + профили состава');
            end
            showProf( QS, pvZ, PGB, LZ, KZ, 1, KRUP ); 
            if ~KRUP && menu('График','Оставить','Убрать') == 2
                delete(fig1);
            end
            
    case 2, fig2 = figure('Position', ScreenSize, 'MenuBar','none',...
                   'Name','Профили баз');
            showProfBas( pvB, LZ, 1:3);   
            if menu('График','Оставить','Убрать') == 2, delete(fig2); end
    case 3, break
    end   
end
set( hh, 'Enable', 'on');

%_______ Профили ПП + профили состава ____________________________
function showProf( QS, pvZ, PGB, LZ, KZ, sost, KRUP ) 
% Показ ПП без состава( sost=0 ) в последней версии не исп.
% => всегда sost=1
SL = [LZ 100];
SL = inpN('Задать сетку L и размер графика', SL,...
     {'\lambda_L' '\lambda_R' 'к-во' }, [5 3 5],...
     [LZ; LZ; 5 1000], 3, 'I(1)<=I(2)', NaN);

L  = setK(SL(1:3))'; 
for i = 1:QS
   % if i == 3, prib('Переход к 3 слою'); end
   showProfsl( QS,pvZ, PGB, L, KZ, sost, '', i, KRUP );
end

%______________________________________________________________________
function showProfsl( QS, pvZ, PGB, L, KZ, sost, T, sl, KRUP )
global ScreenSize
global eKZ
% sl <= QS
% sost = (0)1 - (не) показ состав
% KZ-матр к-тов Зельм
% pvZ-№№ пар строк из eKZ, на к-х основана KZ

if all( KZ(1:6, sl ) == 0)
   prie('Профиль не задан в слое %g',sl);  return,end

% sls     = [1 2 1];
% modsl   = sls(sl);
[ps vs] = pvZ{:,sl};
nsl     = sqrt(n_2kZ(L.^2,KZ(1:6,sl)));
tit = [sprintf('n%g. Ge=%g%%, B=%g%%.  ',sl,PGB(:,sl))...
   'Cтроки: ' ps '; веса: ' vs ...
   sprintf('\n%5s%13s%13s%13s%13s%13s\n','A1','A2','A3','L1','L2','L3')...
   sprintf('%9.5f',KZ(1:6,sl)) ];

if sost == 0
   if KRUP, subplot( 1, 1, 1 );
   else     subplot( 1,QS,sl ); end
   
   plot(L,nsl,'r');
   title(tit,'FontSize',8);
   xlabel(['\lambda ' T]);   grid on 
else
   p    = str2num(ps);      
   rp   = size(p,1);             %v=0.01*str2num(vs);
   spGB = 0.01*PGB(:,sl); 
   pG   = spGB(1);  
   pB   = spGB(2);
   nQu  = sqrt(n_2kZ(L.^2,eKZ(3:end,1)));
   np   = zeros(length(L),rp);   %np(lL,k)=пок прел (на L) k-й пары строк
   dp   = np; 
   
   for k = 1:rp
      Tk = p(k,1);
      if Tk == p(k,2),   np(:,k) = sqrt(n_2kZ(L.^2,eKZ(3:end,Tk)));
      else
         Tk = p(k,:);    
         GB = 0.01*eKZ(1:2,Tk);
         f  = eKZ(3:end,Tk)-eKZ(3:end,1)*(1-sum(GB));
         np(:,k) = sqrt(n_2kZ(L.^2,(1-pG-pB)*eKZ(3:end,1)+(f/GB)*spGB));
      end
   end
     
   for k = 1:rp, dp(:,k) = nQu-np(:,k);  end 
   
   if KRUP, fig = figure('Position', ScreenSize, 'MenuBar','none',...
                  'Name',sprintf('%d-й слой: Профили ПП и состава',sl));
            subplot(2,1,1);  
   else     subplot(2,QS,sl);
   end

   [AX,H1,H2] = plotyy( L, [nQu nsl np],  L, [nQu-nsl dp]);
   
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
         nZ(:,ii)  = sqrt( n_2kZ(L.^2, eKZ(3:end,no(k))) );
         dZ(:,ii)  = nQu-nZ(:,ii);
         Le3(ii,:) = sprintf('%2s',nos(k,:));
         Le4(ii,:) = ['Qu-' Le3(ii,:)];
      end
   end
  
   if exist('nZ','var')
      if KRUP, subplot(2,1,2);
      else     subplot(2,QS,sl+QS); end  

      [AX,H3,H4] = plotyy(L,[nQu nZ],L,dZ);
      
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
L  = setK(SL)';
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

% ______________________________________________________________________
function pokGX_Callback(~, ~, ~)
global tGX
msgbox(tGX, 'границы Х')

% ______________________________________________________________________
function statFZ_Callback(~, ~, ~)
% ______________________________________________________________________
function showStatFZ_Callback(~, ~, ~)
statFZ
% ______________________________________________________________________
function ObnulStat_Callback(~, ~, ~)
global stat
stat = zeros(5,1);

%________ Выход из пр-мы SvetoV______________
function Exit_Callback(~, ~, handles )
Exit(handles.SvetoV)

%_______________________________________________________________________
function Exit(h)
statFZ
delete(h); 

% __________________TOOLS______________________________________________
function Tools_Callback(~, ~, ~) 
function Tools_CreateFcn(~, ~, ~)

% ________________ Установка станд меню ________________________________
function stmen_Callback(hObject, ~, ~)
if onoffP(hObject,'Checked'), mb = 'figure'; else mb = 'none'; end
set(gcbf,'MenuBar',mb);

% ______________________________________________________
function ono = onoffP(h,P) %onn/off Property
if strcmp(get(h,P),'on'),set(h,P,'off'); ono = 0;
else                     set(h,P,'on');  ono = 1; end

% ______________________________________________________
function ono = onoffPU(h,P) %onn/off Property
if strcmp(get(h,P),'on'),set(h,P,'off','UserData',0); ono = 0;
else                     set(h,P,'on' ,'UserData',1); ono = 1; end


% _____________________ГРУППА Графики БФ______________________________
function FB_Callback(~, ~, ~)
%________Опр(DEF) БФ_________________________________________________
function DefBF_Callback(~, ~, ~)
txt={'Bessel functions are solutions to diff.equation of order n',...
'        x^2 * y'''' +  x * y'' + (x^2 - n^2 ) * y = 0',...
'   There are several functions available to produce solutions to',...
'              Bessel''s equations.  These are:',...
'  besselj (n,z)     Bessel function of the first kind',...
'  bessely (n,z)    Bessel function of the second kind',...
'  besseli (n,z)      Modified Bessel function of the first kind',...
'  besselk (n,z)     Modified Bessel function of the second kind',...
'  besselh (n,k,z)  Hankel function',...
'  airy (k,z)            Airy function'};
%l=length(txt); hy=0.5/l;
%for i=1:l, text(0.05,1-i*hy,txt{i}); end
msgbox(txt,'Определение бесс.ф-ций','none','replace');

% _______Графики БФ______________________________________________________
function GBF_Callback(~, ~, ~)
im  = {{'n'}; {'x1' 'x2' 'k'}};
wid = {10  [6 6 6 ] };
G   = {[0 20]; [0 500; 0 500; 10 900]}; 
I   = {  1     [1 10 100] };
BF  = {@besselj @besseli @bessely @besselk @besselh @airy};
na = {'Jn - бф 1 р','In - мбф 1 р','Yn - бф 2 р',...
      'Kn - ф.Макдональда,мбф 2 р','Hn - ф.Ханкеля,бф 3 р','An: ф.Airy'};
fig = figure;
kPl = 0;
while true
   nF = menu('Бесселевы функции',na);
   F  = BF{nF};
   I  = inpU( na{nF}, I, im, wid, G,...
        '~mod(I{1},1) && ~mod(I{2}(3),1) && I{2}(1)<I{2}(2)');
   if ischar(I), break,end
   n   = I{1};         X = setK(I{2});
   kPl = mod(kPl,4)+1;
   subplot(2,2,kPl)
   plot(X,F(n,X)); grid on
   title(sprintf('%s_{%g}(x)',na{nF}(1),n));
   if ~MEN, break,end
end
prib('Построение графиков закончено')
delete(fig)

% _______Выч QN Нулей б.ф-ции F(x)_Callback_____________________________
function vnBF_Callback(~, ~, ~)
im  = {{'n'}; {'k'}};
wid = {10  10};
G   = {[0 20]; [1 100]}; 
I   = {  1     20};
BF  = {@besselj @bessely};
na = {'Jn: 1 рода','Yn: 2 рода'};
while true
   nF = menu('Нули бессел. функций',na);
   F  = BF{nF};
   I  = inpU(na{nF},I,im,wid,G,'~mod(I{1},1) && ~mod(I{2},1)');
   if ischar(I), return,end
   n = I{1};     QN = I{2};
   nu = vnBF(F,n,QN);
   tit = sprintf('Нули %s_%g',na{nF}(1),n);
   f1  = sprintf('%16g',1:5);
   f2  = sprintf('%11.4f   %10.4f  %10.4f  %10.4f  %10.4f\n',nu(1:5));
   f3  = sprintf('%10.4f  %10.4f  %10.4f  %10.4f  %10.4f\n',nu(6:end));
   f4  = sprintf('%s\n%s%s',f1(7:end),f2,f3);
   pribz(tit,f4);
   if ~MEN, return,end
end

% ____________Выч QN Нулей б.ф-ции F(x)__________________________________
function nu = vnBF( F, n, QN)
nu = zeros(QN,1);    h   = 1;
xb = 1;              Fb  = F(n,xb); 
i  = 1;              Qit = 20;                    
while i <= QN
   Fa = Fb;    xb = xb+h;    Fb = F(n,xb);
   if     Fa == 0, nu(i) = xb-h;  continue
   elseif Fb == 0, nu(i) = xb;    continue,end 
   
   while Fa * Fb > 0,   Fa = Fb;   xb = xb+h;   Fb = F(n,xb); end
   
   try [nu(i) fv FL out] = fzero(@(x) F(n,x),[xb-h xb]);
   catch ME,  AT = sprintf('%s\nпри поиске %g-го корня',ME.message,i);
      if exist('fv','var')
         AT = [AT sprintf('\nf = %g, FL = %g\n%s',fv,FL,out.message)];end
      prie(AT);  return
   end  
  
   if FL < 0,  it = it+1;
   else        it = 0;    i = i+1;  end                 
   if it > Qit
      prie('Найдено %g корней из %g',i-1,QN);
      nu(i:end) = [];  return
   end
end

% _______Выч уровней б.ф-ции F(x) Callback_______________________________
function vuBF_Callback(~, ~, ~)
global Ieq1 Yeq1 Keq1
BF  = {@besseli @bessely @besselk};
na  = {'In - мбф 1 р','Yn - ф.Неймана(бф 2 р)',...
       'Kn - ф.Макдональда(мбф 2 р)'};
man = length(Ieq1)-1;
ti  = sprintf(['На диске хр-ся точки уровня=1 для первых\n'...
      '%g-ти бф, имеюших ос-ти: In,Yn - в 0, Kn - в Inf\n'...
      'Yeq1 = {x: Yn(x)=1, n = 0,1,...nMax=%g}, аналог Ieq1, Keq1'],...
      man,man);
while true
  switch menu(ti,'Посмотреть существующие т.уровня=1',...
      'Анализ точек уровня = 1 для разл n(без замены)',...
      'Выч-е nMax+1 точек уровня=1 (nMax - max пор фб)','Выход')
  case 1, priMaCo('Сущ-е т.уровня=1','%11.4f',5,{'Ieq1' 'Yeq1' 'Keq1'},...
          [Ieq1 Yeq1 Keq1]);
  case 2
    im  = {{'Max_n'};{'Level'}};   wid = {10 10};    
    I   = { man 1}; G   = {[0 20];[-Inf Inf]}; 
    while true
      nF  = menu('Уровни бессел. функций',na);
      F   = BF{nF};             G{2}    = [-Inf Inf];
      
      if nF == 2,  I{2} = -1;   G{2}(2) = 0;
      else         I{2} =  1;   G{2}(1) = 0; end
      
      I   = inpU(na{nF},I,im,wid,G,'~mod(I{1},1)');
      if ischar(I), return,end
      man = I{1}; 
      Lev = I{2};
      nu  = vuBF(F,man,Lev);
      naZ = na{nF}(1:2);
      tit = sprintf('Уровни %s, n=1...%g',naZ,man);
      priMaCo(tit,'%11.4f',5,na(nF),nu);
      if ~MEN, break,end
    end
  case 3
    man = inpN('Т.уровня для I,Y,K',man,{'nMax'},5,[0 30],1);
    if ischar(man), return,end
    eq1 = zeros(man+1,3);
    Lev = 1;
    for i = 1:3 
       try   eq1(:,i) = vuBF(BF{i},man,Lev); 
             Lev = -Lev;
       catch ME, prie('Точки уровня = 1\n для %s\n%s',na{i},ME.message);
             return
       end
    end
    Ieq1 = eq1(:,1);
    Yeq1 = eq1(:,2); 
    Keq1 = eq1(:,3);
    priMaCo('Новые т.уровня=1','%11.4f',5,{'In=1' 'Yn=1' 'Kn=1'},eq1);
    save('Zeq1','Ieq1', 'Yeq1', 'Keq1');
  case 4, return
  end
end      

% ____________Выч уровней б.ф-ции F(x)___________________________________
function nu = vuBF( F, man, Lev)
nu = zeros(man+1,1);  xa = eps;         
h  = 1;               AT = '';                                 
for n = 1:man+1,       j = 0;    
   ZL = @(x) F(n-1,x)-Lev;
   Fa = ZL(xa);    xb = xa+h;    Fb = ZL(xb);
   if     Fa == 0, nu(n) = xa;  continue
   elseif Fb == 0, nu(n) = xb;  continue,end
   
   while  Fa * Fb > 0,   j = j+1; 
      if j > 700, prie('Fa*Fb = %g*%g >0\n700 раз!\n',Fa,Fb); return,end
      Fa = Fb;   xb = xb+h;   Fb = ZL(xb);
   end      
   try [nu(n) fv FL out] = fzero(ZL,[xb-h xb]);
   catch ME, AT = sprintf('%s\nn = %g,  уровень = %g',ME.message,n,Lev);
      if exist('FL','var')
         AT = [AT sprintf('\nf=%g, FL=%g\n%s',fv,FL,out.message)];end
   end
 
   if ~exist('FL','var') || FL < 0
      prie('Авост\nНайдено %g корней из %g\n%s',n-1,man,AT);
      nu(n:end) = [];  return
   end
   xa = nu(n); 
end

% _______печать МАтрицы по СтОлбцам(СOlon)_____________________________
function priMaCo(tit,frm,col,im,M) 
Lim = length(im);                  % каждый столбец в виде таблицы
if Lim ~= size(M,2), prie('Несоотв имен и столбцов м-цы'); return,end
F  = '';
for i = 1:col, F = [F frm]; end
F  = [F '\n'];
f  = '\n              %s\n';
FM = '';    % Формат Матрицы
for i = 1:Lim,  FM = [FM  sprintf(f,im{i})  ];  
                FM = [FM  sprintf(F,M(:,i)) ];  end
f  = sprintf('%%%dg', length(sprintf(frm,11.1111111111))+3);
fc = sprintf(f,1:col);            
pribz(tit,sprintf('%s%s', fc, FM));

% _______ОТСечка для n >= 2___________________________________________
function ots_nGE2_Callback(~, ~, ~)
nam = {'Unger' 'Marcuse'};
sfun = {'J_{n-2}(x)+J_{n-1}(x)*(\epsilon-1)/(\epsilon+1)' ...
          'J_{n-1}(x)/x-J_n(x)/((n-1)(\epsilon+1))'};
QN = 20;         e  = 1.01;
ti = 'Порядок Интервал Крупно';
im  = {{'n'}; {'x1' 'x2' 'k'}};
wid = {10  [6 6 6 ] };
G   = {[2 20]; [0 500; 0 500; 10 900]}; 
I   = {  2     [1 10 100] };
fig = figure;
kPl = 0;
while true
   I  = inpU(ti,I,im,wid,G,...
   '~mod(I{1},1) && ~mod(I{2}(3),1) && I{2}(1)<I{2}(2)');
   if ischar(I), break,end
   n     = I{1};         X = setK(I{2});   
   tit = 'Отсечка для n>=2';
   se  = '\epsilon = n_1^2/n_2^2';       
   e   = inpN(tit,e,{se},4,[1 2]);
   if isempty(e), break,end
   if ischar(e),  prie(e); break,end

   del  = [(e-1)/(e+1) 1/((n-1)*(e+1))]; 
   kPl = mod(kPl,4)+1;
   subplot(2,2,kPl)
   plot(X,[JJXU(n,X,del(1));JJXM(n,X,del(2))]); grid on
   title(sprintf('%s: f(x) = %s\n%s: f(x) = %s, n=%g',...
       nam{1},sfun{1},nam{2},sfun{2},n));
   xlabel('x'); ylabel('f(x)');
   XT = get(gca,'XTick');  
   YT = get(gca,'YTick');
   text('Position',[XT(2),(YT(end-1)+YT(end))/2],'Interpreter','latex',...
   'String',sprintf('$$%s = %g$$',se,e),...
   'FontSize',12,'Color',[0 0 1]);

   QN = inpN('Кол-во нулей',QN,{'QN'},4,[1,100],1);
   if isempty(QN), break,end
   XotU  = vnJJX(n,QN,@JJXU,del(1));  %(n,QR,hf,del)
   XotM  = vnJJX(n,QN,@JJXM,del(2));

   f1 = sprintf('%30s\n','Xots Ung');
   f2 = sprintf('%8.4f %8.4f %8.4f %8.4f %8.4f\n',XotU);
   f3 = sprintf('%30s\n','Xots Marc');
   f4 = sprintf('%8.4f %8.4f %8.4f %8.4f %8.4f\n',XotM);
   pribz('Critical values',[f1 f2 f3 f4]);
   if ~MEN, break,end
end
prib('Работа пр-мы закочена')
delete(fig)

% ___________Jn-2+Jn-1*(e1-1)/(e1+1)_________________________________________________________
function f = JJXU(n,x,del,varargin) 
f = besselj(n-2,x)+besselj(n-1,x)*del;    % устр ос-ти Jn-1=0 Унгер
%f  = besselj(n-2,x)./besselj(n-1,x)+nn12;

% ___________Jn-1-Jn/[(n-1)(e1+1)]_______________________________________
function f = JJXM(n,x,del,varargin)
f = besselj(n-1,x)./x-besselj(n,x)*del;   % устр ос-ти Jn=0 Маркузе

% _______график Z*=Zn' /(xZn)____________________________________________
function zBF_Callback(~, ~, ~) 
ti  = 'Порядок Интервал Крупно';
im  = {{'n'}; {'x1' 'x2' 'k'}};
wid = {10  [6 6 6 ] };
G   = {[2 20]; [0 500; 0 500; 10 900]}; 
I   = {  2     [1 10 100] };
BF  = {@besselj @bessely @besseli @besselk};
na  = {'J''n/(xJn)','Y''n/(xYn)','I''n/(xIn)','K''n/(xKn)'};
fig = figure;
kPl = 0;
while true
   nF = menu('Z''n/(xZn)',na);
   Z  = BF{nF};    S = na{nF}(1);
   I  = inpU(ti,I,im,wid,G,...
   '~mod(I{1},1) && ~mod(I{2}(3),1) && I{2}(1)<I{2}(2) && ~mod(I{3},1)');
   if ischar(I), break,end
   n  = I{1};      X = setK(I{2}); 
   kPl = mod(kPl,4)+1;
   subplot(2,2,kPl)
   plot(X,zBF(Z,n,X));
   title(sprintf('%s* = %s''_%g(x) / (x%s_%g)',S,S,n,S,n))
   xlabel('x'); ylabel([S '^*(x)']);  grid on
   XT  = get(gca,'XTick');  
   YT  = get(gca,'YTick');
   XT0 = [XT(2) XT(round(0.75*end))];
   XG  = [X(1) X(end)];
   T   = {sprintf(...
     '$$%s^*(x) = \\frac{%s''_n(x)}{x%s_n(x)},\\quad %s^*$$',S,S,S,S)...
     sprintf('$$%s^*$$',S)};
 
   for i = 1:2
      text(...   
     'Position',[XT0(i),(YT(end-1)+YT(end))/2],'Interpreter','latex',...
     'String',sprintf('%s(%g) = %g',T{i},XG(i),zBF(Z,n,XG(i))),...
     'FontSize',12,'Color',[0 0 1]);
   end
   if ~MEN, break,end
end
prib('Построение графиков Zn'' /(xZn) закончено')
delete(fig)

% _______выч ф-ции Z*=Zn' / (xZn)_______________________________________________________
function ZX = zBF(Z,n,X)
ZX = DBF(1,Z,n,X)./(X.*Z(n,X));

% ____________выч произв бесс.ф-ции Z'n(x)_________________________________________________
function DZ = DBF(k,Z,n,X) 
switch func2str(Z)
case {'besselj','bessely'}
    if     k == 1, DZ =  0.5*(Z(n-1,X)-Z(n+1,X));
    elseif k == 2, DZ = 0.25*(Z(n-2,X)-2*Z(n,X)+Z(n+2,X));
    elseif k == 0, DZ = Z(n,X); 
    else           DZ = NaN;
    end
case 'besseli'
    if     k == 1, DZ =  0.5*(Z(n-1,X)+Z(n+1,X));
    elseif k == 2, DZ = 0.25*(Z(n-2,X)+2*Z(n,X)+Z(n+2,X));
    elseif k == 0, DZ = Z(n,X); 
    else           DZ = NaN;
    end
case 'besselk'
    if     k == 1, DZ = -0.5*(Z(n-1,X)+Z(n+1,X));
    elseif k == 2, DZ = 0.25*(Z(n-2,X)+2*Z(n,X)+Z(n+2,X));
    elseif k == 0, DZ = Z(n,X); 
    else           DZ = NaN; 
    end
end

% _______Комбинация БФ_________________________________________________
function IKZ_Callback(~, ~, ~)
FS = 'D1Z./Z(n,x)'; 
ti = 'Порядок Интервал Крупно';
im  = {{'n'}; {'x1' 'x2' 'k'}};
wid = {10  [6 6 6 ]};
G   = {[2 20]; [0 500; 0 500; 10 900]}; 
I   = {  2     [1 10 100]  };
fig = figure;
kPl = 0;
while true
   FC = inputdlg('Func mb Z(n,X)','Комбинация БФ',1,{FS});
   if isempty(FC), break,end
   FS = FC{1};
   try D1Z = 0;  Z = @besselk;  x = 1;
       eval(FS)
   catch ME, prie('Неправ задана ф-ция\n%s',ME.message);
         continue
   end

   I  = inpU(ti,I,im,wid,G,...
    '~mod(I{1},1) && ~mod(I{2}(3),1) && I{2}(1)<I{2}(2) && ~mod(I{3},1)');
   if ischar(I), break,end
   n     = I{1};         x = setK(I{2}); 
 
   switch menu('Тип БФ','1) J','2) N','3) I','4) K')
   case 0,  break  
   case 1,  Z = @besselj;  z = 'J';  A =  1;  B = -1;
   case 2,  Z = @bessely;  z = 'N';  A =  1;  B = -1;    
   case 3,  Z = @besseli;  z = 'I';  A =  1;  B =  1;
   case 4,  Z = @besselk;  z = 'K';  A = -1;  B = -1;
   end   
   D1Z = 0.5*( A*Z(n-1,x) + B*Z(n+1,x));
   FZ  = eval(FS);
   kPl = mod(kPl,4)+1;
   subplot(2,2,kPl)
   plot(x,FZ);   grid on
   title( strrep( strrep(FS, 'Z', z),  'n',num2str(n) ));
   if ~MEN,  break,end
end
prib('Построение графиков комбинаций БФ закончено')
delete(fig)

% _______Разное_______________________________________________________
function Raznoe_Callback(~, ~, ~) 
% ______________________________________________________________________
function otladka_Callback(~, ~, handles)
switch MEN('ОТЛАДКА','РС','Группа inp','Х.ф-я HF','Результ Произв','HFfa')
case 1, prib(testRSD12(handles)) %РС
case 2, otl2  %Группа inp
case 3, otl3
case 4, otl4   
case 5, otl5
case 0, return
end

% ______________________________________________________________________
function AT = testRSD12
AT = 'Программа testRSD12(handles) находится в архиве';

% ______________________________________________________________________
function TempFigT_Callback(~, ~, handles)
t = 'Проверка';
kxy = [2 2];
kxy = inpN('К-ты сжатия фигуры',kxy,{'kx' 'ky'},[4 4],[1 100;1 100]);
hF  = TempFig(t,kxy(1),kxy(2),handles);
if ischar(hF), prie(hF); 
else           prib(sprintf('Указатель тек фиг = %g',hF)); end

%_____________Временная фигура_________________________________________________
function hF = TempFig(t,kx,ky,handles) 
Pos = get(handles.SvetoV,'Position');
pSS = get(0,'ScreenSize');
if kx<1 || ky<1 || kx>100 || ky>100
   hF = 'Неверно заданы коэфф сжатия фигуры';   return,end
wSV = 1;   
x   = Pos(1)+wSV;   w = pSS(3)- x;  wk = w/kx;
y   = pSS(2)+33;    h = pSS(4)-55;  hk = h/ky;
hF  = figure('Name',t, 'NumberTitle','off','MenuBar','none',...
             'Position',[x+(w-wk)/2 y+(h-hk)/2 wk hk]);

% ______________________________________________________________________
function Help_Callback(~, ~, ~)
%_______________________________________________________________________
function Autor_Callback(~, ~, ~)
msgbox({'Солопов В.М.','каф.физики МГУПИ',...
        'т.(499)781-4156, 8-90-55-88-4105',...
        'факс. 734-5442'},'','help','replace');
    

