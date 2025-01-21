function colorslider_create (axes_handle)
% Create colorslider on the input axes
%
%   >> colorslider_create (axes_handle)
%
% Create a colorslider on the axes object with handle axes_handle. On a figure
% with multiple subplots, each with theor own axes, independent colorsliders for
% each subplot can be created.
%
% This is a utility function used by the public function colorslider.


fig_handle = ancestor(axes_handle, 'figure');

% Plot colorbar
cbar_handle = colorbar(axes_handle);
pos_h = get(cbar_handle, 'position');   % get position of the colorbar

% Get color scale limits
irange = get(axes_handle, 'clim');
i_min = irange(1);
i_max = irange(2);
range = i_max-i_min;

% Get text size and font of colorbar annotations, and size of box that will take
% height of that text (do this by plotting some text, and enquiring the extent)
txtFont = get(cbar_handle, 'FontName');
txtSize = get(cbar_handle, 'FontSize');
htmp = text(0.9, 0.9, '1234567890', 'FontName', txtFont, 'FontSize', txtSize,...
    'units', 'normalized');
tmp = get(htmp, 'Extent');  % in units normalised to graph having height 0->1
delete(htmp);
% Get box height; normalised to same units as window itself, reduce as box is
% very generous
box_height = 0.7*(tmp(4)/pos_h(4));
slider_height = pos_h(4)/20;


% Bottom slider
% -------------
% Positions for editbox and slider
pos_lo_editbox = [pos_h(1)+pos_h(3), pos_h(2), pos_h(3)*2.5, box_height];
pos_lo_slider = [pos_h(1)+pos_h(3)*2, pos_h(2)+box_height, pos_h(3)*1.5, slider_height];

% Create slider
% (The SliderStep is adjusted such that in real terms it is [0.02 0.10] of the
% displayed intensity range)
h_slider_min = uicontrol(fig_handle, 'Style', 'slider',...
    'Units', get(cbar_handle, 'Units'), 'Position', pos_lo_slider,...
    'SliderStep', [0.01/1.4*2 0.10/1.4],...
    'Tag', 'color_slider_min',...
    'Value', i_min, 'Min', i_min-range/2, 'Max', i_max-range*0.1,...
    'Callback', @(src,event)colorslider_command(fig_handle, 'slider_min'));

% Create edit box
val = truncdig(i_min,3);
h_value_min = uicontrol(fig_handle, 'Style', 'edit',...
    'Units', get(cbar_handle, 'Units'), 'Position', pos_lo_editbox,...
    'FontName', txtFont, 'FontSize', txtSize, 'HorizontalAlignment', 'left',...
    'Tag', 'color_slider_min_value',...
    'String', num2str(val),...
    'Callback', @(src,event)colorslider_command(fig_handle, 'min'));


% Top slider
% ----------
% Positions for editbox and slider
pos_hi_editbox = [pos_h(1)+pos_h(3), pos_h(2)+pos_h(4)-box_height,...
    pos_h(3)*2.5, box_height];
pos_hi_slider = [pos_h(1)+pos_h(3)*2, pos_h(2)+pos_h(4)-box_height-slider_height,...
    pos_h(3)*1.5, slider_height];

% Create slider
h_slider_max=uicontrol(fig_handle, 'Style', 'slider',...
    'Units', get(cbar_handle,'Units'), 'Position', pos_hi_slider,...
    'SliderStep', [0.01/1.4*2 0.10/1.4],...
    'Tag', 'color_slider_max',...
    'Value', i_max, 'Min', i_min+range*0.1, 'Max', i_max+range/2,...
    'Callback', @(src,event)colorslider_command(fig_handle, 'slider_max'));

% Create edit box
val = truncdig(i_max,3);
h_value_max = uicontrol(fig_handle, 'Style', 'edit',...
    'Units', get(cbar_handle, 'Units'), 'Position', pos_hi_editbox,...
    'FontName', txtFont, 'FontSize', txtSize, 'HorizontalAlignment', 'left',...
    'Tag', 'color_slider_max_value',...
    'String', num2str(val),...
    'Callback', @(src,event)colorslider_command(fig_handle, 'max'));

% Set the UserData property of each of the sliders and edit boxes to the 
% associated colorbar handle. This will enable us to keep track of the
% uicontrol objects that are the sliders and edit boxes ssociated with the
% colorbar. For example, if the colorbar is deleted using >> colorbar('off')
% the UserData will become a handle to a deleted object, and this can be tested
% for.
h_slider_min.UserData = cbar_handle;
h_value_min.UserData = cbar_handle;
h_slider_max.UserData = cbar_handle;
h_value_max.UserData = cbar_handle;
