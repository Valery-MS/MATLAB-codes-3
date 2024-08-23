
function varargout = SvetoVod(varargin)
% Last Modified by GUIDE v2.5 21-Oct-2011 17:28:09
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
global CALC ...   % ������ ���������� �� ������ ����������
       RVh RVDh RVbh ... % ������ ���������� �� ������� ������ RV(������) 
       RVon 
global clr1 clr2 clr3 ScreenSize

CALC = [handles.zagr ...    % 1
        handles.B2O3 ...    % 2
        handles.KZ   ...    % 3    
        handles.vGX  ...    % 4
        handles.TDG  ...    % 5
        handles.DVAX ...    % 6
        handles.GDH  ...    % 7
        handles.SUI ];      % 8
    
RVDh = [handles.GrS1 ...     % 1
        handles.Lev2a ...    % 2
        handles.q2a ];       % 3
                      
RVbh = [handles.OK    ...  
        handles.Canc ];   

RVh  = [RVDh RVbh handles.textq2a];
RVon = [];    
clr1 = [ 1    0.8  0.8 ];   % light red
clr2 = [ 0.8  1    0.8 ];   % light green
clr3 = [ 0.8  0.8  1   ];   % light blue

ScreenSize = get(0,'ScreenSize');

%Units = get( hObject, 'Units');
%%P = get( hObject, 'Pos');
%set(hObject, 'Position',P0);  % ���� [0,32,-30,-80] 
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
global clr2 teKZ tKZ tGX

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
          handles.textXnkH;  handles.XnkH;], 'Enable', 'off');
end

set( CALC, 'Enable', 'on',  'BackgroundColor', clr2)
     % �-��� �������� ������ � �����
teKZ = eKZ_t;
tKZ  = KZ_t;
tGX  = GX_t;

% ______ Executes during object creation, after setting all properties.
function zagr_CreateFcn(hObject, ~, ~)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%___________ ������� ��������� ����� ���� �2�3  _______________________
function B2O3_Callback(~, ~, ~)
global CALC eKZ   QS  KZBU  LZ    % read only
global pvB  pvBS KZB teKZ         % edit
global clr1 
h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

me = menu('������ �������',...
          '�� ���������',  ...
          '�������',  ...
          '�� ������ ����� � �2�3'); 
if me <= 1             % �� ���������
   pvB = {'Default'; '�.����� ������ �� �����'}; 
   Z = KZBU;
elseif me == 2         % �������
   Z = eKZ( 3:end, 3 );
   Z = inpN('������ �.����� �/����� ���� �� 100% B2O3', Z, ...
       {'A1' 'A2' 'A3' 'L1' 'L2' 'L3'}, [4 5 6 6 6 6],...
       [0.3 0.9; 0.2 0.8; 0.5 1.3; 0.03 0.1; 0.05 0.3; 8 15],...
       'I(2)<I(1) && I(1)<I(3) && I(4)<I(5)');   
   if isnumeric(Z),   pvB = {'Handly'; '�.����� ������ �������'}; end    
else                   % �� ������ ����� � �2�3
   % msgbox(eKZ_t,'������������ ���������'); 
   NePok('��������� � ������� ���� �2�3', 4,...
     sprintf(['       � ���� �-��� ��������� ' ...
     '7-� ������ �����  0.1%% Ge � 5.4%% B2O3,  ' ...
     '8-� ������ - 4.03%% Ge � 9.7%% B2O3.\n' ...
     '    ������ ������� ���� �2�3 �� ������, ��������, ����� '...
     '7 � 8 ������ - ��������� �-�� ��������� ������� ���� �����, '...
     '��� �������� ���������� ���� ������� �����: 2-� (Ge�2) � '...
     '����������� (�2�3) � ����������  0.1 � 5.4 ���� 7-� ������,'...
     '� ���������� 4.03 � 9.7 - 8-�.\n' ...
     '    ����� ���. ���������� � ����������, �� ������ ' ...
     '���������� �� ��������� 0.1 - 4.03  �  5.4 - 9.7 ���� ' ...
     '�.��������� � ������ �������� �������� 7 � 8-� �����.']),...
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

% __________����-�� ��������� -> txt _____________________________
function s = eKZ_t
global eKZ
f  = '    %7.3f %7.3f %7.3f %7.3f %7.3f  %7.3f';
f1 = ['\n %2.0f)  %6.0f    %6.0f' f];
f2 = ['\n %2.0f)  %6.2f    %6.2f' f];
f3 = ['\n%2.0f)  %6.2f    %6.2f' f];
f0 = ['    %GeO2  %B2O3     A1        A2       A3        '...
     'L1        L2         L3'];
s = [f0 sprintf('\n%60s','����: 1 - SiO2;  2 - GeO2;  3 - B2O3')];
s = [s sprintf(f1,[1:3; eKZ(:,1:3)])];
s = [s sprintf('\n%50s','�������') sprintf(f2, [4: 9; eKZ(:,4:9)])];
s = [s sprintf('\n%50s','�������') sprintf(f3,[10:17; eKZ(:,10:17)])];

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

CONT = get(hObject,'Data');   % ���������, ����������
PGBn = cell2mat( CONT )';
          
if    ~isempty( eventD.Error ),  ER = eventD.Error;  
elseif isnan( eventD.NewData ),  ER = '������� �� �����';                       i = 2;
elseif QS == 3 && all( PGBn(:,1) == PGBn(:,2) ) || ...
                  all( PGBn(:,1) == PGBn(:,3) ) || ...
                  all( PGBn(:,2) == PGBn(:,3) )
                                 ER = '��� ���� ���������, �.� 2-�� ��'; 
elseif any( sum(PGBn) > 100 ),   ER = '����� %% ��������� 100';
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
   % ��������� ��� ���-������ ����� ���������
   set( CALC(4:8), 'Enable', 'off', 'BackgroundC', clr1); 
end

% _______ Executes when selected cell(s) is changed in PGB __________
function PGB_CellSelectionCallback(~, ~, ~)
% eventdata  structure with the following fields (see UITABLE)
% Indices: row and column indices of the cell(s) currently selecteds
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
function KZ_Callback( ~, ~, handles )
global CALC QS  PGB LZ hL  iNAs  TSV    % read only
global pvZ  KZ  nT  n_290  tKZ   eew % edit
global clr1 clr2 
h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

[pvZn KZn nTn] = KoZLiC( QS, KZ, LZ, pvZ, PGB );
set( h_on,    'Enable', 'on');

if ischar(nTn),  prie(nTn); return, end
pvZ = pvZn;  KZ = KZn;  nT = nTn;  
set( handles.Tip,  'String', TSV{nT})

tKZ = KZ_t;
iNA = iNAs(:,nT); 

L_2   = setH( [LZ hL] ).^2;
n_290 = [ n_2kZ( KZ(:,iNA(1)), L_2) n_2kZ( KZ(:,iNA(2)), L_2) ];
eew   = e13(KZ);

set( CALC(4),   'Enable', 'on', 'BackgroundColor',  clr2);
set( CALC(5:8), 'Enable', 'off','BackgroundColor',  clr1); 

% ______ ������ ������� �-��� ��������� _________________________
function KZ_ButtonDownFcn(hObject, eventdata, handles)
% If Enable == 'on', executes on mouse press in 5 pixel border.
% Otherwise, executes on mouse press in 5 pixel border or over KZ.
global tKZ
msgbox( tKZ, '������������ ���������' ); 

%_______________________________________________________________________
function Lw_Callback( hObject, ~, ~)
global CALC LZ KZ % read only
global Lw   eew % edit
global clr1
Lwn  = str2num(get(hObject,'String'));
if ProV( hObject, Lw, Lwn, 1, LZ),  return,end

if Lw ~= Lwn
   Lw  = Lwn;
   eew = e13(KZ);
   set( CALC(5:8),'Enable', 'off','BackgroundColor', clr1 );
end
% ______ Executes during object creation, after setting all properties.
function Lw_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end

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

%________________________________________________________
function XnkH_Callback( hObject, ~, ~)
global CALC clr1    % read only
global XnkH        % edit
XnkHn  = str2num( get( hObject, 'String'));

if     isempty(XnkHn),               ER = '������� �� �����';
elseif numel(XnkHn) ~= 3,            ER = '����� �� ����� 3';              
elseif XnkHn(1) > XnkHn(2) ,         ER = 'X� �.� < ��';
elseif XnkHn(1)<0  || XnkHn(2)>500 , ER = '����� � �� ������� [0 500]';
elseif XnkHn(3)<1e-10 || XnkHn(3)>2, ER = '����� H �� ������� [1e-10 2]';
else                                 ER = NaN;
end 

if ischar(ER)
   prie(ER)
   set( hObject, 'String', num2str(XnkH) );
   return
end

if any( XnkH ~= XnkHn )
   XnkH = XnkHn;
   set( CALC(5:8), 'Enable', 'off', 'BackgroundColor', clr1 );
end
% ______ Executes during object creation, after setting all properties.
function XnkH_CreateFcn(hObject, ~, ~)
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
       prib(['������� m_max < �m2 - ������� ������� m\n' ...
             '������� �������� �m2, �-�� �m2 < m_max'])
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
global QS KZ nT Lw c n  XnkH  m_max % read only
global GX tGX                          % edit
global CALC clr1 clr2

h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

if QS == 3,  GXn = vGX( nT,n,c, XnkH, m_max);             
else 
   try       GXn = GraniX_12 ( KZ, n, Lw^2, m_max);  
   catch ME, GXn = ['�����: GraniX_12-�.3\n' ME.message];               
   end 
end

set( h_on,    'Enable', 'on'); 
if ischar(GXn),  prie(GXn), return,end  

GX  = GXn;
tGX = GX_t;
set( CALC(5:6), 'Enable', 'on',  'BackgroundColor', clr2 );
set( CALC(7:8), 'Enable', 'off', 'BackgroundColor', clr1 );

% _______ ����� ������ � by right click mouse
function vGX_ButtonDownFcn(hObject, eventdata, handles)
global tGX
msgbox( tGX, '������� �')

%___________________________________________________________
function m1_Callback( hObject, ~, ~)
global CALC clr1
global mm
m1 = get( hObject, 'Value' );
if m1 > mm(2)
   prie('m ��� �� < m ���'); 
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
if     m9 < mm(1), prie('m ��� �� < m ���'); 
                   set( hObject, 'Value', mm(2) );
elseif m9 > m_max, prie('m ��� �� <= m_max'); 
                   set( hObject, 'Value', mm(2) );
elseif m9~= mm(2), mm(2) = m9;
                   set( CALC(7:8),'Enable','off','BackgroundColor',clr1);
end
% ______ Executes during object creation, after setting all properties.
function m9_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%________________________________________________________
function qX_Callback(hObject, ~, ~)
global  qX CALC clr1
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

%________ �������� ����� ��� 1-�� ��� 2-� ����� _________________
function IER = ProV( hObject, gloD, D, qD, GD, varargin)
% gloD - ���������� �������� D ( ����� ���������� � global)
% D    - ��������� ������ D
% qD   - ����� ��������� D
% GD   - ������� D
% varargin -  ������� U
%    U = ����� ~= 0 - �������� �� ��������������� D
%    U = string - ������������ ������� �� D 
ER = NaN;
if     isempty(D) || isnan(D),     ER = '������� �� �����';
elseif numel(D) ~= qD,             ER = sprintf('����� �� ����� %d',qD);           
elseif qD == 2 && D(1) > D(2),     ER = '����� �� < �������';     
elseif D(1)<GD(1) || D(end)>GD(2), ER = sprintf(...
                                       '����� �� �������  [%g  %g]',GD); 
elseif nargin == 6
   U = varargin{1};
   if isnumeric(U) 
      if numel(U) ~= 1,            ER = '������ ���� �� ��� �� ����';
      elseif mod( D(U~=0),1) ~= 0, ER = '������� �����';     end
   elseif ischar(U)
      try if feval(U),  ER = ['�� ��� ���: ' U];  end 
      catch ME,         ER = [U ' : ���� ��������� ���\n' ME.message];
      end 
   else  ER = '������� �� ������ ��� ������� ��������';
   end
end
IER = ischar(ER);
if IER
   prie(ER)
   set( hObject, 'String', sprintf('%g  %g',gloD) );
end

%________�������� ����� 3-� ����� ___________________________________
function IER = ProV3( hObject, gloD, D, G1, G2, varargin)

ER = NaN;
if     isempty(D),                ER = '������� �� �����';
elseif numel(D) ~= 3,             ER = '����� �� ����� 3';              
elseif D(1) > D(2) ,              ER = '��� �.� < ���';
elseif D(1)<G1(1) || D(2)>G1(2) , ER = '����� �� ������� 1 ��� 2-�� ���';
elseif D(3)<G2(1) || D(3)>G2(2) , ER = '����� �� ������� 3-�� ���';
elseif nargin == 6
   U = varargin{1};
   if isnumeric(U)     
      if     numel(U) ~= 3,             ER = '������� ���� �� ��� �� 3';
      elseif any( mod(D(U~=0),1) ~= 0), ER = '��� - �������';    end   
   elseif ischar(U)        
      try if ~feval(U), ER = ['�� ��� ���: ' U];  end
      catch ME,         ER = [U ' : ���� ��������� ���\n' ME.message];
      end     
   else ER = '������� �� �������� ����� ��� ������� ��������';
   end   
end 
IER = ischar(ER);
if IER
   prie(ER)
   set( hObject, 'String', sprintf('%g  %g  %g',gloD) );
end

% ______ Executes on button press in TDG.
function TDG_Callback(~, ~, ~)
global QS LZ hL KZ nT n c GX mm qX n_290 dvaX   % read only
qL  = 50;
qSV = sprintf('%d-��',QS);
nm_ = [n mm(1)];          % ��������� �������� �-���
NAma  = sqrt( max( n_290(:,1)-n_290(:,2) ));
while true
   nm_ = inpN( qSV, nm_, {'n' 'm'}, [5 5], [1 20;  mm], 1:2);
   if ischar(nm_), prib('�����\n%s',nm_);  break,end
   n_ = nm_(1);     
   m_ = nm_(2); 
   a2 = sqrt(dvaX( 4, m_-mm(1)+1, 1))/pi;       % �����, ���� mm ��� �� � 1
   a2 = inpA('', a2, '2a', 10, [0.1 1000], NaN);
   dva_ = (a2*pi)^2;
   TDG( 1,    QS,  ...
        LZ,   hL,     KZ, nT, n_, c, ...
        GX(m_,:), m_, qX, ...
        dva_, qL,     NAma );
end

%________������ ����� ���������� ____________________________________
% ______ Executes on button press in GrS1.
function GrS1_Callback(hObject, ~, ~)
% Hint: get(hObject,'Value') returns toggle state of GrS1
global RVDn  RVon 
if isempty(RVon),  RVon = RVonoff;  end
RVDn(1) = get(hObject,'Value');

% ______ ��������� ��� ����� ������ RV
function RVon = RVonoff
global RVh
RVon = findobj( 'Enable', 'on');
set( RVon, 'Enable', 'off');
set( RVh,  'Enable', 'on');

% ______ 
function RVoffon
global  RVbh RVon
set( RVon, 'Enable', 'on');
set( RVbh, 'Enable', 'off');
RVon = [];
%{
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
%}
% ______ Executes on button press in Lev2a.
function Lev2a_Callback(hObject, ~, ~)
global RVDn  RVon
if isempty(RVon),  RVon = RVonoff;  end
RVDn(2) = get(hObject,'Value');

%________________________________________________________
function q2a_Callback( hObject, ~, ~)
global RVD RVDn  RVon
if isempty(RVon),  RVon = RVonoff;  end
RVDn(3) = str2double( get( hObject, 'String'));
if ProV( hObject, RVD(3), RVDn(3), 1, [9 1000], 1),  return,end 

% ______ Executes during object creation, after setting all properties.
function q2a_CreateFcn( hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ______ Executes on button press in OK.
function OK_Callback(~, ~, ~)
global CALC clr1 RVD RVDn
if any( RVD ~= RVDn )
   RVD = RVDn;  
   set( CALC(7:8), 'Enable', 'off', 'BackgroundColor', clr1 );  
end
RVoffon

% ______ Executes on button press in Canc.
function Canc_Callback(~, ~, ~)
global RVD
RVoffon
iniRV(RVD)


% ______ Executes on button press in DVAX.
function DVAX_Callback(~, ~, ~)
global UsPath
global QS  pvB pvBS pvZ  KZB PGB ...
       LZ  hL  KZ   nT   Lw  eew ...
       c   n        XnkH...
       m_max GX  mm   qX    RVD  n_290   % read only
global DxHF dvaX dvaX1                        % edit
global ETim

h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

tic
[dvaX dvaX1 AV] = DVAX( LZ, hL, KZ, nT, Lw, c, n, GX, mm, qX, RVD);                       
ETim = toc;  

if isempty(dvaX),  prie(AV);  return,end
if ischar(AV),     prie(AV);  end

rm = dvaX(1,:);
rm = rm(~isnan(rm));    % mm: ������ ��������� mm (range found)

if rm(end) == mm(2);
   mm_ = mm;
   save( [UsPath 'daSV\Last'], ...  
     'QS',  'pvB',  'pvBS', 'pvZ', 'KZB', 'PGB',  ...
     'LZ',  'hL',   'KZ',   'nT',  'Lw',  'eew',  ...
     'c',   'n',            'XnkH','m_max',...
     'GX',  'mm',   'qX',   'RVD',   ...
     'DxHF','n_290','dvaX', 'dvaX1' );     
else
   m9  = mm(2);
   mm_ = rm([1 end]);
   prib('�������� ���-�� ��� m = %d...%d �� %d\n%s',mm_,m9,AV);
   qm = numel(rm);
   dvaX = dvaX(:, 1:qm, :);
end

% ����� ����� ���������� �� ������ ����������� 
% ���������� ������� � ��������� ���-�� ��� � ��� ���������� ������
UTO = S123( QS, LZ, hL, KZ, nT, n,c, GX(rm,:), mm_, n_290,  dvaX, dvaX1);  
set( h_on, 'Enable', 'on');        
if prich(UTO),  return,end
if UTO
      % �������� ���������
end 

if menu('��������� ���-�� ��� ���� ������?','��','���') == 1  
   cl  = clock;
   tim = sprintf('%g_%g_%g_%g',cl(1:4));
   mm  = mm_;
   save([UsPath 'daSV\' sprintf(...
      '1%d %s %g %g_%g_%g %g_%g_%g.mat', ...
      QS,  tim, Lw, PGB')], ...
     'QS',  'pvB',  'pvBS', 'pvZ', 'KZB', 'PGB',  ...
     'LZ',  'hL',   'KZ',   'nT',  'Lw',  'eew',  ...
     'c',   'n',            'XnkH','m_max',...
     'GX',  'mm',   'qX',   'RVD',   ...
     'DxHF','n_290','dvaX', 'dvaX1' );     
end

% ______ ������� ���� �-� _______________________________________________
function GDH_Callback(~, ~, ~)
global QS  LZ   hL    KZ   nT n c GX  mm  n_290 dvaX dvaX1

h_on = findobj( 'Enable', 'on');
set( h_on, 'Enable', 'off');

rm  = dvaX(1,:);                 % ������ �� ����� m
UTO = S123( QS, LZ, hL, KZ, nT, n,c, GX(rm,:), mm, n_290,  dvaX, dvaX1);  
set( h_on, 'Enable', 'on');                
if prich(UTO),  return,end 
if UTO
      % �������� ���������
end 

% ______ ��������� ���-�� ��� ���� ������ ( ������ SUI)
function SUI_Callback(~, ~, ~)
global QS   pvB   pvBS pvZ  KZB  PGB ...
       LZ   hL    KZ   nT   Lw   eew ...
       c    n          XnkH m_max ...
       GX   mm    qX   RVD   ...
       DxHF n_290 dvaX dvaX1  
   
cl  = clock;
tim = sprintf('%g_%g_%g_%g',cl(1:4));
save([UsPath 'daSV\' sprintf(...
   '1%d %s %g %g_%g_%g %g_%g_%g.mat', ...
   QS,  tim, Lw, PGB')],...
  'QS',  'pvB',  'pvBS', 'pvZ', 'KZB', 'PGB',  ...
  'LZ',  'hL',   'KZ',   'nT',  'Lw',  'eew',  ...
  'c',   'n',            'XnkH','m_max',...
  'GX',  'mm',   'qX',   'RVD',   ...
  'DxHF','n_290','dvaX', 'dvaX1' );   


% _____________________ �������������� ���� (Menu Bar) _____________
%_________________________________________________________________
function Pokaz_Callback( ~, ~, ~)

% ______ �������� ����.�.��������� ______________________
function pokeKZ_Callback(~, ~, ~)
global teKZ
msgbox( teKZ, '����������� �-�� ���������' ); 

% ______________________________________________________________________
function pokKZ_Callback(~, ~, ~)
global tKZ
msgbox( tKZ, '�-�� ��������� c��������' ); 

%________������� ����������� ����������� ___________________________
function pokGPP_Callback(~, ~, ~)
global QS pvB pvZ PGB LZ KZ
global ScreenSize
hh = findobj( 'Enable', 'on');
set( hh, 'Enable', 'off');

while true
    switch menu({''},{ '������� �����+������',...
                       '������� ���: Si, Ge, Bor',...
                       '�����'})
                 
    case 1, KRUP = menu('������������',...
                   '�� ����� ������ - ��� ����',...
                   '�� ����� ������ - ���� ����') == 2;
            if ~KRUP
               fig1 = figure('Position', ScreenSize, 'MenuBar','none',...
                      'Name','������� �� + ������� �������');
            end
            showProf( QS, KZ, LZ, pvZ, PGB, 1, KRUP ); 
            if ~KRUP && menu('������','��������','������') == 2
                delete(fig1);
            end
            
    case 2, fig2 = figure('Position', ScreenSize, 'MenuBar','none',...
                   'Name','������� ���');
            showProfBas( pvB, LZ, 1:3);   
            if menu('������','��������','������') == 2, delete(fig2); end
    case 3, break
    end   
end
set( hh, 'Enable', 'on');

% ______________________________________________________________________
function pokGX_Callback(~, ~, ~)
global tGX
msgbox(tGX, '������� �')

% ______________________________________________________________________
function statFZ_Callback(~, ~, ~)
% ______________________________________________________________________
function showStatFZ_Callback(~, ~, ~)
statFZ
% _______ ���� �������� _________________________________________________
function ObnulStat_Callback(~, ~, ~)
%global   m_max stat 
%stat = zeros(18,m_max);  

%________ ����� �� ��-�� SvetoV______________
function Exit_Callback(~, ~, handles )
Exit(handles.SvetoV)

%_______________________________________________________________________
function Exit(h)
%statFZ
delete(h); 

% __________________TOOLS______________________________________________
function Tools_Callback(~, ~, ~) 
function Tools_CreateFcn(~, ~, ~)

% ________________ ��������� ����� ���� ________________________________
function stmen_Callback(hObject, ~, ~)
if onoffP(hObject,'Checked'), mb = 'figure'; else mb = 'none'; end
set(gcbf,'MenuBar',mb);

% ______________________________________________________
function ono = onoffP(h,P) %onn/off Property
if strcmp(get(h,P),'on'),set(h,P,'off'); ono = 0;
else                     set(h,P,'on');  ono = 1; end

% _____________________������ ������� ��______________________________
function FB_Callback(~, ~, ~)
%________���(DEF) ��_________________________________________________
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
msgbox(txt,'����������� ����.�-���','none','replace');

% _______������� ��______________________________________________________
function GBF_Callback(~, ~, ~)
im  = {{'n'}; {'x1' 'x2' 'k'}};
wid = {10  [6 6 6 ] };
G   = {[0 20]; [0 500; 0 500; 10 900]}; 
I   = {  1     [1 10 100] };
BF  = {@besselj @besseli @bessely @besselk @besselh @airy};
na = {'Jn - �� 1 �','In - ��� 1 �','Yn - �� 2 �',...
      'Kn - �.�����������,��� 2 �','Hn - �.�������,�� 3 �','An: �.Airy'};
fig = figure;
kPl = 0;
while true
   nF = menu('��������� �������',na);
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
prib('���������� �������� ���������')
delete(fig)

% _______��� QN ����� �.�-��� F(x)_Callback_____________________________
function vnBF_Callback(~, ~, ~)
im  = {{'n'}; {'k'}};
wid = {10  10};
G   = {[0 20]; [1 100]}; 
I   = {  1     20};
BF  = {@besselj @bessely};
na = {'Jn: 1 ����','Yn: 2 ����'};
while true
   nF = menu('���� ������. �������',na);
   F  = BF{nF};
   I  = inpU(na{nF},I,im,wid,G,'~mod(I{1},1) && ~mod(I{2},1)');
   if ischar(I), return,end
   n = I{1};     QN = I{2};
   nu = vnBF(F,n,QN);
   tit = sprintf('���� %s_%g',na{nF}(1),n);
   f1  = sprintf('%16g',1:5);
   f2  = sprintf('%11.4f   %10.4f  %10.4f  %10.4f  %10.4f\n',nu(1:5));
   f3  = sprintf('%10.4f  %10.4f  %10.4f  %10.4f  %10.4f\n',nu(6:end));
   f4  = sprintf('%s\n%s%s',f1(7:end),f2,f3);
   pribz(tit,f4);
   if ~MEN, return,end
end

% _______��� ������� �.�-��� F(x) Callback_______________________________
function vuBF_Callback(~, ~, ~)
global Ieq1 Yeq1 Keq1
BF  = {@besseli @bessely @besselk};
na  = {'In - ��� 1 �','Yn - �.�������(�� 2 �)',...
       'Kn - �.�����������(��� 2 �)'};
man = length(Ieq1)-1;
ti  = sprintf(['�� ����� ��-�� ����� ������=1 ��� ������\n'...
      '%g-�� ��, ������� ��-��: In,Yn - � 0, Kn - � Inf\n'...
      'Yeq1 = {x: Yn(x)=1, n = 0,1,...nMax=%g}, ������ Ieq1, Keq1'],...
      man,man);
while true
  switch menu(ti,'���������� ������������ �.������=1',...
      '������ ����� ������ = 1 ��� ���� n(��� ������)',...
      '���-� nMax+1 ����� ������=1 (nMax - max ��� ��)','�����')
  case 1, priMaCo('���-� �.������=1','%11.4f',5,{'Ieq1' 'Yeq1' 'Keq1'},...
          [Ieq1 Yeq1 Keq1]);
  case 2
    im  = {{'Max_n'};{'Level'}};   wid = {10 10};    
    I   = { man 1}; G   = {[0 20];[-Inf Inf]}; 
    while true
      nF  = menu('������ ������. �������',na);
      F   = BF{nF};             G{2}    = [-Inf Inf];
      
      if nF == 2,  I{2} = -1;   G{2}(2) = 0;
      else         I{2} =  1;   G{2}(1) = 0; end
      
      I   = inpU(na{nF},I,im,wid,G,'~mod(I{1},1)');
      if ischar(I), return,end
      man = I{1}; 
      Lev = I{2};
      nu  = vuBF(F,man,Lev);
      naZ = na{nF}(1:2);
      tit = sprintf('������ %s, n=1...%g',naZ,man);
      priMaCo(tit,'%11.4f',5,na(nF),nu);
      if ~MEN, break,end
    end
  case 3
    man = inpN('�.������ ��� I,Y,K',man,{'nMax'},5,[0 30],1);
    if ischar(man), return,end
    eq1 = zeros(man+1,3);
    Lev = 1;
    for i = 1:3 
       try   eq1(:,i) = vuBF(BF{i},man,Lev); 
             Lev = -Lev;
       catch ME, prie('����� ������ = 1\n ��� %s\n%s',na{i},ME.message);
             return
       end
    end
    Ieq1 = eq1(:,1);
    Yeq1 = eq1(:,2); 
    Keq1 = eq1(:,3);
    priMaCo('����� �.������=1','%11.4f',5,{'In=1' 'Yn=1' 'Kn=1'},eq1);
    save('Zeq1','Ieq1', 'Yeq1', 'Keq1');
  case 4, return
  end
end      

% _______������� ��� n >= 2___________________________________________
function ots_nGE2_Callback(~, ~, ~)
nam = {'Unger' 'Marcuse'};
sfun = {'J_{n-2}(x)+J_{n-1}(x)*(\epsilon-1)/(\epsilon+1)' ...
          'J_{n-1}(x)/x-J_n(x)/((n-1)(\epsilon+1))'};
QN = 20;         e  = 1.01;
ti = '������� �������� ������';
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
   tit = '������� ��� n>=2';
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

   QN = inpN('���-�� �����',QN,{'QN'},4,[1,100],1);
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
prib('������ ��-�� ��������')
delete(fig)

% ___________Jn-2+Jn-1*(e1-1)/(e1+1)_________________________________________________________
function f = JJXU(n,x,del,varargin) 
f = besselj(n-2,x)+besselj(n-1,x)*del;    % ���� ��-�� Jn-1=0 �����
%f  = besselj(n-2,x)./besselj(n-1,x)+nn12;

% ___________Jn-1-Jn/[(n-1)(e1+1)]_______________________________________
function f = JJXM(n,x,del,varargin)
f = besselj(n-1,x)./x-besselj(n,x)*del;   % ���� ��-�� Jn=0 �������

% _______������ Z*=Zn' /(xZn)____________________________________________
function zBF_Callback(~, ~, ~) 
ti  = '������� �������� ������';
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
prib('���������� �������� Zn'' /(xZn) ���������')
delete(fig)

% _______��� �-��� Z*=Zn' / (xZn)_______________________________________________________
function ZX = zBF(Z,n,X)
ZX = DBF(1,Z,n,X)./(X.*Z(n,X));

% _______���������� ��_________________________________________________
function ComBF_Callback(~, ~, ~)
FS = 'D1Z./Z(n,x)'; 
ti = '������� �������� ������';
im  = {{'n'}; {'x1' 'x2' 'k'}};
wid = {10  [6 6 6 ]};
G   = {[2 20]; [0 500; 0 500; 10 900]}; 
I   = {  2     [1 10 100]  };
fig = figure;
kPl = 0;
while true
   FC = inputdlg('Func mb Z(n,X)','���������� ��',1,{FS});
   if isempty(FC), break,end
   FS = FC{1};
   try D1Z = 0;  Z = @besselk;  x = 1;
       eval(FS)
   catch ME, prie('������ ������ �-���\n%s',ME.message);
         continue
   end

   I  = inpU(ti,I,im,wid,G,...
    '~mod(I{1},1) && ~mod(I{2}(3),1) && I{2}(1)<I{2}(2) && ~mod(I{3},1)');
   if ischar(I), break,end
   n     = I{1};         x = setK(I{2}); 
 
   switch menu('��� ��','1) J','2) N','3) I','4) K')
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
prib('���������� �������� ���������� �� ���������')
delete(fig)

% _______������_______________________________________________________
function Raznoe_Callback(~, ~, ~) 
% ______________________________________________________________________
function otladka_Callback(~, ~, handles)
switch MEN('�������','��','������ inp','�.�-� HF','������� ������','HFfa')
case 1, prib('��������� testRSD12(handles) ��������� � ������') %��
case 2, otl2  %������ inp
case 3, otl3
case 4, otl4   
case 5, otl5
case 0, return
end

% ______________________________________________________________________
function TempFigT_Callback(~, ~, handles)
t = '��������';
kxy = [2 2];
kxy = inpN('�-�� ������ ������',kxy,{'kx' 'ky'},[4 4],[1 100;1 100]);
hF  = TempFig(t,kxy(1),kxy(2),handles);
if ischar(hF), prie(hF); 
else           prib(sprintf('��������� ��� ��� = %g',hF)); end

% ______________________________________________________________________
function Help_Callback(~, ~, ~)
%_______________________________________________________________________
function Autor_Callback(~, ~, ~)
msgbox({'������� �.�.','���.������ �����',...
        '�.(499)781-4156, 8-90-55-88-4105',...
        '����. 734-5442'},'','help','replace');
