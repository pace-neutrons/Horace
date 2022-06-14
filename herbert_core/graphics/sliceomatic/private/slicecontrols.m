function slicecontrols(fig,onoff)
% Convert figure to contain controls for manipulating slices.

d = getappdata(fig, 'sliceomatic');
if onoff
    
    set(0,'currentfigure',fig);
    set([d.axx d.axy d.axz] ,'handlevisibility','on');
    %
    % X-Axis
    set(fig,'currentaxes',d.axx);
    set(d.axx, 'xlim',d.xlim,...
        'ylim',[1 5]);
    set(d.pxx, 'vertices',[ d.xlim(1) 1 -1; d.xlim(2) 1 -1; d.xlim(2) 5 -1; d.xlim(1) 5 -1],...
        'faces',[ 1 2 3 ; 1 3 4]);
    
    %uicontrol('Style','text','String',d.xlabel,...
    %    'Units','normalized','Position',[0.15 0.905 0.05 0.05]);
    annotation(fig,'textbox',[0.15 0.905 0.05 0.05],'String',d.xlabel,'LineStyle','none');
    %
    % Y-Axis
    set(fig,'currentaxes',d.axy);
    set(d.axy, 'xlim',[1 5],...
        'ylim',d.ylim);
    set(d.pxy, 'vertices',[ 1 d.ylim(1) -1; 1 d.ylim(2) -1; 5 d.ylim(2) -1; 5 d.ylim(1) -1],...
        'faces',[ 1 2 3 ; 1 3 4]);
    %uicontrol('Style','text','String',d.ylabel,...
    %    'Units','normalized','Position',[.05 0.8 .05 .05]);
    annotation(fig,'textbox',[.05 0.8 .05 .05],'String',d.ylabel,'LineStyle','none');
    %
    % Z-Axis
    set(fig,'currentaxes',d.axz);
    set(d.axz, 'xlim',[1 5],...
        'ylim',d.zlim);
    set(d.pxz, 'vertices',[ 1 d.zlim(1) -1; 1 d.zlim(2) -1; 5 d.zlim(2) -1; 5 d.zlim(1) -1],...
        'faces',[ 1 2 3 ; 1 3 4]);
    %uicontrol('Style','text','String',d.zlabel,...
    %    'Units','normalized','Position',[.9 0.8 .05 .05]);
    annotation(fig,'textbox',[.9 0.8 .05 .05],'String',d.zlabel,'LineStyle','none');
    
    set([d.axx d.axy d.axz] ,'handlevisibility','off');
else
    
    % Disable these controls.  Perhaps hide all slices?
    
end

