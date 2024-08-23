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
