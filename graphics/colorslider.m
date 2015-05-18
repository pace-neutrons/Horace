function colorslider(varargin)
% Add a color slider to a plot
%
%   >> colorslider                  % add to current figure
%   >> colorslider (fig)            % add to named or numbered figure
%   >> colorslider ('delete')       % delete colorslider from current figure
%   >> colorslider ('update')       % update colorslider on current figure
%                                    (use if resize the figure, to reshape slider boxes)
%   >> colorslider (fig,'delete')   % delete colorslider from named or numbered figure
%   >> colorslider (fig,'update')   % update colorslider on named or numbered figure

% Adapted from script by Radu Coldea 02-Oct-1999, by Dean Whittaker 2-2-2007, and then Toby Perring

% Parse arguments
if nargin>=1 && isstringmatchi(varargin{end},'delete')
    option='delete';
    narg=nargin-1;
elseif nargin>=1 && isstringmatchi(varargin{end},'update')
    option='update';
    narg=nargin-1;
else
    option='create';
    narg=nargin;
end
if narg==0
    fig='';
elseif narg==1
    fig=varargin{1};
else
    error('Check number and type of input arguments')
end

% Determine which figure to get handles
if ~exist('fig','var')||(isempty(fig)),
    if isempty(findall(0,'Type','figure'))
        error('No current figure exists - no ranges can be returned.')
    else
        fig=gcf;
    end
else
    [fig,ok,mess]=genie_figure_handle(fig);
    if ~ok, error(mess), end
    if isempty(fig)
        error('No figure with given name or figure number - no ranges can be returned.')
    elseif numel(fig)>1
        error('Can return ranges for one figure only.')
    end
end

% Get various handles for the figure
[fig_handle, axes_handle] = genie_figure_all_handles (fig);

% Check for current sliders and boxes (if handle is empty, then delete does not cause error)
curr_colorbar = findobj(fig_handle,'tag','Colorbar');
curr_slider_min = findobj(fig_handle,'tag','color_slider_min');
curr_slider_max = findobj(fig_handle,'tag','color_slider_max');
curr_slider_min_val = findobj(fig_handle,'tag','color_slider_min_value');
curr_slider_max_val = findobj(fig_handle,'tag','color_slider_max_value');

if ~isempty(curr_slider_min)||~isempty(curr_slider_max)||~isempty(curr_slider_min_val)||~isempty(curr_slider_max_val)
    colorslider_exist=true;
else
    colorslider_exist=false;
end

% Switch on options (note:delete is silent if object does not exist)
if verLessThan('matlab','8.4')
    delete(curr_colorbar, curr_slider_min, curr_slider_max, curr_slider_min_val, curr_slider_max_val);
else
    curr_colorbar=[];curr_slider_min=[]; curr_slider_max=[];curr_slider_min_val=[];curr_slider_max_val=[];
end

switch option
    case 'create'
        %do nothing
    case 'update'
        if ~colorslider_exist
            return  % no colorslider to update
        end
    case 'delete'
        return % already deleted above
    otherwise
        error('incorrect option given')
end

% Create colorslider
i_min = [];
i_max = [];
for i = 1:length(axes_handle)
    irange = get(axes_handle(i),'clim');
    i_min = min([irange(1), i_min]);
    i_max = max([irange(2), i_max]);
end
range = i_max-i_min;

cbar_handle = colorbar;
pos_h = get(cbar_handle,'position');    % get position of the colorbar

% Get text size and font of colorbar annotations, and size of box that will take height of that text
% (do this by plotting some text, and enquiring the extent)
txtFont=get(cbar_handle,'FontName');
txtSize=get(cbar_handle,'FontSize');
htmp=text(0.9,0.9,'1234567890','FontName',txtFont,'FontSize',txtSize,'units','normalized');
tmp=get(htmp,'Extent');         % in units normalised to graph having height 0->1
delete(htmp);
box_height=0.7*(tmp(4)/pos_h(4));     % normalised to same units as window itself, reduce as box is very generous
slider_height=pos_h(4)/20;

% bottom slider
pos_lo_ed=[pos_h(1)+pos_h(3), pos_h(2), pos_h(3)*2.5, box_height];
pos_lo_sl=[pos_h(1)+pos_h(3)*2, pos_h(2)+box_height, pos_h(3)*1.5, slider_height];
hh=uicontrol(fig_handle,'Style','slider',...
    'Units',get(cbar_handle,'Units'),'Position',pos_lo_sl,...
    'Min',i_min-range/2,'Max',i_max-range*0.1,...
    'SliderStep',[0.01/1.4*2 0.10/1.4],'Value',i_min,'Tag','color_slider_min','Callback','colorslider_command(gcf,''slider_min'')');
% the SliderStep is adjusted such that in real terms it is [0.02 0.10] of the displayed intensity range

val = get(hh,'Value');
val = truncdig(val,3);

hh_value=uicontrol(fig_handle,'Style','edit',...
    'Units',get(cbar_handle,'Units'),'Position',pos_lo_ed,...
    'String',num2str(val),'Tag','color_slider_min_value',...
    'FontName',txtFont,'FontSize',txtSize,'HorizontalAlignment','left',...
    'Callback','colorslider_command(gcf,''min'')');


% top slider
pos_hi_ed=[pos_h(1)+pos_h(3), pos_h(2)+pos_h(4)-box_height, pos_h(3)*2.5, box_height];
pos_hi_sl=[pos_h(1)+pos_h(3)*2, pos_h(2)+pos_h(4)-box_height-slider_height, pos_h(3)*1.5, slider_height];
hh=uicontrol(fig_handle,'Style','slider',...
    'Units',get(cbar_handle,'Units'),'Position',pos_hi_sl,...
    'Min',i_min+range*0.1,'Max',i_max+range/2,...
    'SliderStep',[0.01/1.4*2 0.10/1.4],'Value',i_max,'Tag','color_slider_max','Callback','colorslider_command(gcf,''slider_max'')');

val = get(hh,'Value');
val = truncdig(val,3);

hh_value=uicontrol(fig_handle,'Style','edit',...
    'Units',get(cbar_handle,'Units'),'Position',pos_hi_ed,...
    'String',num2str(val),'Tag','color_slider_max_value',...
    'FontName',txtFont,'FontSize',txtSize,'HorizontalAlignment','left',...
    'Callback','colorslider_command(gcf,''max'')');
