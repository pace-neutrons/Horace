function appdata=sliceomaticfigure(d)
% FIG=SLICEOMATICFIGURE (D) -
% Create the figure window to be used by the sliceomatic GUI.
% D is the app data to attach to the figure

%------------------------------------------------------------------------------
% === TGP 4 Feb 2014: replaced:

% % Init sliceomatic
% fig = gcf;
% clf(fig,'reset')

% === with:

% If existing Sliceomatic figure, reset; otherwise create a new figure
if isfield(d,'name')
    name = d.name;
else
    name = 'Sliceomatic';
end
fig=findobj('name',name,'type','figure');
if ~isempty(fig)
    cm = colormap;
    clf(fig,'reset')
    colormap(cm);
    fig.Name = name;
    set(0,'CurrentFigure',fig);
else
    fig=figure('Position',[5, 30, 800, 600],'name',name);
end
%------------------------------------------------------------------------------

set (fig,'MenuBar','none','Resize','on',...
    'NumberTitle','off',...
    'units','normal',...
    'PaperPositionMode','auto');
%modified by srikanth on 9thmay 2003

% --- section modified by DJW 18th June 2007
uicontrol(fig,'style','edit','string','0',...
    'units','normal','pos',[.8 .905 .05 .05],'Tag','slice_u1','Callback',{@textbox_axis, 'XNew'});
uicontrol(fig,'style','edit','string','0',...
    'units','normal','pos',[.05 0.005 .05 .035],'Tag','slice_u2','Callback',{@textbox_axis, 'YNew'});
uicontrol(fig,'style','edit','string','0',...
    'units','normal','pos',[.9 0.005 .05 .035],'Tag','slice_u3','Callback',{@textbox_axis, 'ZNew'});
uicontrol(fig,'style','edit','string',round_gen(d.clim(1,2),2),...
    'units','normal','pos',[.70 0.02 .1 .035],'Tag','iso_2','Callback',{@textbox_axis, 'ISONew2'});
uicontrol(fig,'style','edit','string',round_gen(d.clim(1,1),2),...
    'units','normal','pos',[.20 0.02 .1 .035],'Tag','iso_1','Callback',{@textbox_axis, 'ISONew1'});
% --- end of DJW mod

lim=[min(min(min(d.data))) max(max(max(d.data)))];
if lim(1)==lim(2)
    lim(1) = lim(1)-1;
    lim(2) = lim(2)+1;
end
%  d.axmain = axes('units','normal','pos',[.2  .2 .6 .6],'box','on',...
%                  'ylim',[1 size(d.data,1)],...
%                  'xlim',[1 size(d.data,2)],...
%                  'zlim',[1 size(d.data,3)],...
%                  'clim',lim,...
%                  'alim',lim);
%Modified by sri
if verLessThan('matlab','8.4')
    d.axmain = axes(fig,'units','normal','pos',[.1  .1 .8 .8],'box','on',...
        'ylim',d.ylim,...
        'xlim',d.xlim,...
        'zlim',d.zlim,...
        'clim',d.clim,...
        'alim',lim);
    view(3);
    axis tight vis3d;
    hold on;
    grid on;
else
    d.axmain = axes(fig,'units','normal','Position',[.1  .1 .8 .8],'box','on',...
        'CLim',d.clim,...
        'ALim',lim);

    view(3);
    axis(d.axmain,'tight','vis3d');
    hold on;
    grid on;
    axis(d.axmain,[d.xlim(:);d.ylim(:);d.zlim(:)])
    aspect=[max(d.xlim)-min(d.xlim),max(d.ylim)-min(d.ylim),max(d.zlim)-min(d.zlim)];
    daspect(aspect);
end
set(get(d.axmain,'XLabel'),'String',d.xaxis)
set(get(d.axmain,'YLabel'),'String',d.yaxis)
set(get(d.axmain,'ZLabel'),'String',d.zaxis)


% Set up the four controller axes.
d.axx    = axes('units','normal','pos',[.2  .905 .6 .05],'box','on',...
    'ytick',[],'xgrid','on','xaxislocation','top',...
    'zlim',[-2 1 ],...
    'layer','top',...
    'color','none');
d.pxx    = patch('facecolor',[1 1 1],...
    'facealpha',.6,...
    'edgecolor','none',...
    'hittest','off');
setappdata(d.axx,'motionpointer','SOM bottom');
d.axy    = axes('units','normal','pos',[.05 .05 .05  .75],'box','on',...
    'xtick',[],'ygrid','on',...
    'zlim',[-2 1 ],...
    'layer','top',...
    'color','none');
d.pxy    = patch('facecolor',[1 1 1],...
    'facealpha',.6,...
    'edgecolor','none',...
    'hittest','off');
setappdata(d.axy,'motionpointer','SOM right');
d.axz    = axes('units','normal','pos',[.9 .05 .05 .75],'box','on',...
    'xtick',[],'ygrid','on','yaxislocation','right',...
    'zlim',[-2 1 ],...
    'layer','top',...
    'color','none');
d.pxz    = patch('facecolor',[1 1 1],...
    'facealpha',.6,...
    'edgecolor','none',...
    'hittest','off');
setappdata(d.axz,'motionpointer','SOM left');
d.axiso  = axes('units','normal','pos',[0.3 .01 .4 .05],'box','on',...
    'ytick',[],'xgrid','off','ygrid','off',...
    'xaxislocation','bottom',...
    'zlim',[-1 1],...
    'color','none',...
    'layer','top');
setappdata(d.axiso,'motionpointer','SOM top');
%
set([d.axx d.axy d.axz d.axiso],'handlevisibility','off');
setappdata(fig,'sliceomatic',d);

% Set up the default sliceomatic controllers
slicecontrols(fig,1);
isocontrols(fig,1);

% Button Down Functions
set(d.axx,'buttondownfcn','sliceomatic Xnew');
set(d.axy,'buttondownfcn','sliceomatic Ynew');
set(d.axz,'buttondownfcn','sliceomatic Znew');
set(d.axiso,'buttondownfcn','sliceomatic ISO');

% Set up our motion function before cameratoolbar is active.
d.motionmetaslice = [];

set(fig,'windowbuttonmotionfcn',@sliceomaticmotion);

% Try setting up the camera toolbar

%    modified by I.Bustinduy =============================== <<<<<<<<
cameratoolbar(fig,'show');
cameratoolbar(fig,'togglescenelight');
%cameratoolbar(fig,'setmode','orbit');
figure(fig)

d = figmenus(d);

% Color and alph maps
uicontrol(fig,'style','text','string','ColorMap',...
    'units','normal','pos',[0 .9 .1 .1]);
uicontrol(fig,'style','popup','string',...
    {'jet','hsv','cool','hot','pink','bone','copper','flag','prism','rand','custom'},...
    'callback','sliceomatic colormap',...
    'units','normal','pos',[0 .85 .1 .1]);
colormap('jet');

uicontrol(fig,'style','text','string','AlphaMap',...
    'units','normal','pos',[.9 .9 .1 .1]);
uicontrol(fig,'style','popup','string',{'rampup','rampdown','vup','vdown','rand'},...
    'callback','sliceomatic alphamap',...
    'units','normal','pos',[.9 .85 .1 .1]);

% Data tip thingydoo
d.tip = text('visible','off','fontname','helvetica','fontsize',10,'color','white');
% Try R13 new feature
set(d.tip,'backgroundcolor',[.5 .5 .5],'edgecolor',[.5 .5 .5],'margin',5);
appdata = d;

end
