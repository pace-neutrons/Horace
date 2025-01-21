function colorslider_command (axes_handle, cmd)
% Perform callback operations with colorslider
%
%   >> colorslider_command (fig_handle, cmd)
%
% This is a utility function used by the public function colorslider.
% Based on the mslice function color_slider_ms.m


% Get the handles to colorslider widgets that correspond to this particular axis
h = get_colorbar_handle (axes_handle);
slider_min = colorslider_get_widget (h, 'color_slider_min');
slider_min_value = colorslider_get_widget (h, 'color_slider_min_value');
slider_max = colorslider_get_widget (h, 'color_slider_max');
slider_max_value = colorslider_get_widget (h, 'color_slider_max_value');

i_min = get(slider_min, 'Value');
i_max = get(slider_max, 'value');

switch cmd
    case 'slider_max'
        % Slider move, top
        
    case 'slider_min'
        % Slider move, bottom
        
    case 'min'
        % Only change i_min if numeric value entered and would not make range=0
        temp = str2double(get(slider_min_value, 'String'));
        if isscalar(temp) && isfinite(temp) && isreal(temp) && temp < i_max
            i_min = temp;
        end
        
    case 'max'
        % Only change i_max if numeric value entered and would not make range=0
        temp = str2double(get(slider_max_value, 'String'));
        if isscalar(temp) && isfinite(temp) && isreal(temp) && temp > i_min
            i_max = temp;
        end
        
    otherwise
        error ('Unknown slider command. Contact developers.');
        
end

% Set color limits (and changes the displayed limits on the colorbar)
if ~isnumeric([i_min i_max])
    disp('Deary me')
end
caxis(axes_handle, [i_min i_max]);

% Set value and min/max values in slider and edit boxes
range = abs(i_max-i_min);

set(slider_min, 'Value', i_min, 'Min', i_min-range/2, 'Max', i_max-range*0.1);
i_min_round = truncdig(i_min,3);
set(slider_min_value,'String',num2str(i_min_round));

set(slider_max, 'Value', i_max, 'Min', i_min+range*0.1, 'Max', i_max+range/2);
i_max_round = truncdig(i_max,3);
set(slider_max_value,'String',num2str(i_max_round));


%-------------------------------------------------------------------------------
function widget_handle = colorslider_get_widget (colorbar_handle, tag)
% Get the handle to a colorslider slider or edit box. These uicontrol objects
% will have had their UserData property set to the handle of the colorbar to
% which they are associated.

fig_handle = ancestor(colorbar_handle, 'figure');
for widget_handle = make_row(findobj(fig_handle, 'Tag', tag))
    userdata = get(widget_handle, 'UserData');
    if isa(userdata,'handle') && isgraphics(userdata) && ...
            isequal(userdata, colorbar_handle)
        return  % widget handle associated with colorbar has been found
    end
end
