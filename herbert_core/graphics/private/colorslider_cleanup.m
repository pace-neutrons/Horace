function colorslider_cleanup (fig_handle)
% Delete any orphaned sliders and edit boxes on a figure
%
%   >> colorslider_cleanup (fig_handle)
%
% Deletes any orphaned sliders and edit boxes from the entire figure (i.e. all
% axes) that could have been left over if the Matlab function >> colorbar('off')
% was used. This will have deleted the colorbar component of a colorslider, but
% not the sliders and edit boxes.
%
% This is a utility function used by the public function colorslider.


tags = {'color_slider_min', 'color_slider_max', ...
    'color_slider_min_value', 'color_slider_max_value'};

for i = 1:numel(tags)
    for h = make_row(findobj(fig_handle, 'Tag', tags{i}))
        userdata = get(h, 'UserData');
        if isa(userdata,'handle') && ~isgraphics(userdata)
            % The UserData is not a longer a valid graphics object, so the
            % associated colorbar has been deleted. Therefore delete the widget.
            delete(h)
        end
    end
end
