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
pos_cbar = get(cbar_handle, 'position');   % get position of the colorbar

% Get color scale limits
irange = get(axes_handle, 'clim');
i_min = irange(1);
i_max = irange(2);
range = i_max-i_min;

% Get text size and font of colorbar annotations, and size of box that will take
% height of that text (do this by plotting some text, and enquiring the extent).
% The sample text is the largest expected for 'g' format with three significant
% figures for double precision. The extent is normalised in terms of the axes
% width and height.
txtFont = get(cbar_handle, 'FontName');
txtSize = get(cbar_handle, 'FontSize');
htmp = text(0.9, 0.9, '-8.88e+888', 'FontName', txtFont, 'FontSize', txtSize,...
    'units', 'normalized');
box_extent = get(htmp, 'Extent');  % in units normalised to axes
delete(htmp);

% Get size of axes in the units of the figure size.
axes_position = get(axes_handle, 'Position');
xscale = axes_position(3);  % width of axes in normalised figure coordinates
yscale = axes_position(4);  % height of axes in normalised figure coordinates

% Get box height; normalised to figure size
box_width = xscale*box_extent(3);
box_height = yscale*box_extent(4);

% Define slider dimensions as proportions of box dimensions
slider_width = 0.5*box_width;
slider_height = box_height;


% Bottom slider
% -------------
% Positions for editbox and slider
pos_lo_editbox = [pos_cbar(1) + pos_cbar(3), pos_cbar(2) - box_height/2, box_width, box_height];
pos_lo_slider = [pos_cbar(1) + pos_cbar(3) + box_width - slider_width, ...
    pos_cbar(2) + box_height/2, slider_width, slider_height];

% Create slider
% (The SliderStep is adjusted such that in real terms it is [0.02 0.10] of the
% displayed intensity range)
h_slider_min = uicontrol(fig_handle, 'Style', 'slider',...
    'Units', get(cbar_handle, 'Units'), 'Position', pos_lo_slider,...
    'SliderStep', [0.01/1.4*2 0.10/1.4],...
    'Tag', 'color_slider_min',...
    'Value', i_min, 'Min', i_min-range/2, 'Max', i_max-range*0.1,...
    'Callback', @(src,event)colorslider_command(axes_handle, 'slider_min'));

% Create edit box
h_value_min = uicontrol(fig_handle, 'Style', 'edit',...
    'Units', get(cbar_handle, 'Units'), 'Position', pos_lo_editbox,...
    'FontName', txtFont, 'FontSize', txtSize, 'HorizontalAlignment', 'left',...
    'Tag', 'color_slider_min_value',...
    'String', num2str(i_min,'%10.3g'),...
    'Callback', @(src,event)colorslider_command(axes_handle, 'min'));


% Top slider
% ----------
% Positions for editbox and slider
pos_hi_editbox = [pos_cbar(1) + pos_cbar(3), pos_cbar(2) + pos_cbar(4) - box_height/2, ...
    box_width, box_height];
pos_hi_slider = [pos_cbar(1) + pos_cbar(3) + box_width - slider_width, ...
    pos_cbar(2) + pos_cbar(4) - box_height/2 - slider_height, ...
    slider_width, slider_height];

% Create slider
h_slider_max=uicontrol(fig_handle, 'Style', 'slider',...
    'Units', get(cbar_handle,'Units'), 'Position', pos_hi_slider,...
    'SliderStep', [0.01/1.4*2 0.10/1.4],...
    'Tag', 'color_slider_max',...
    'Value', i_max, 'Min', i_min+range*0.1, 'Max', i_max+range/2,...
    'Callback', @(src,event)colorslider_command(axes_handle, 'slider_max'));

% Create edit box
h_value_max = uicontrol(fig_handle, 'Style', 'edit',...
    'Units', get(cbar_handle, 'Units'), 'Position', pos_hi_editbox,...
    'FontName', txtFont, 'FontSize', txtSize, 'HorizontalAlignment', 'left',...
    'Tag', 'color_slider_max_value',...
    'String', num2str(i_max,'%10.3g'),...
    'Callback', @(src,event)colorslider_command(axes_handle, 'max'));

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
