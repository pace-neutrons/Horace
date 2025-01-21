function colorslider_delete (axes_handle)
% Delete the colorslider, if any, on the input axes.
%
%   >> colorslider_delete (axes_handle)
%
% Deletes a colorslider on the axes object with handle axes_handle. On a figure
% with multiple subplots, each with theor own axes, independent colorsliders for
% each subplot can be deleted.
%
% This function does *not* delete a colorbar that does not have associated
% colorslider widgets, that is, the associated sliders and edit value boxes.
%
% This is a utility function used by the public function colorslider.


% I don't think there can be more than one colorbar on the axes, but just in
% case allow for it with a loop.
tags = {'color_slider_min', 'color_slider_max', ...
    'color_slider_min_value', 'color_slider_max_value'};
fig_handle = ancestor(axes_handle, 'figure');

for colorbar_handle = make_row(get_colorbar_handle (axes_handle))
    colorslider_delete_private (fig_handle, colorbar_handle, tags)
end


%-------------------------------------------------------------------------------
function colorslider_delete_private (fig_handle, colorbar_handle, tags)
% Delete colorslider sliders and edit boxes. These uicontrol objects will have
% had their UserData property set to the handle of the colorbar to which they
% are associated.

colorbar_is_colorslider = false;
for i = 1:numel(tags)
    for h = make_row(findobj(fig_handle, 'Tag', tags{i}))
        userdata = get(h, 'UserData');
        if isa(userdata,'handle') && isgraphics(userdata) && ...
                isequal(userdata, colorbar_handle)
            delete(h)
            colorbar_is_colorslider = true;
        end
    end
end
if colorbar_is_colorslider
    delete(colorbar_handle)
end
