function colorbar_h = colorbar_get_handle (axes_handle)
% Retrieve the handle of colorbar(s), if any, associated with an axes handle
%
%   >> colorbar_h = colorbar_get_handle (axes_handle)
%
% Uses the hidden property Axes of a colorbar that contains the axes handle
% associated with that colorbar. This hidden property has been present since at
% least R2014b (which was when Matlab released a major restructuring of the 
% graphics.
%
% Alternatively, there is a hidden property Colorbar of an axes handle that does
% gives the handle of an associated colorbar, if there is one. However, this
% appeared after R2014b (not been isolated when) and so to ensure compatibility
% of the graphics utilities for R2014b onwards it has not been used here.


if numel(axes_handle)~=1
    error('HERBERT:graphics:invalid_argument', ...
        'Input argument axes_handle must be scalar.')
end

fig_handle = ancestor(axes_handle, 'figure');
colorbar_h = findobj(fig_handle, 'Type', 'ColorBar');
if isempty(colorbar_h)
    return  % no colorbar on the axes, so return
end

% Get axes handle property of all the colorbars
axes_h = get(colorbar_h, 'Axes');

% Find the colorbar for which the axes handle equals the input axes handle.
% Annoyingly, the output above is a cell array of (scalar) handles if there is
% more than one axes handle with a colorbar. There will be at least one axes
% handle because a colorbar always has an Axes property
if isscalar(axes_h)
    colorbar_h = colorbar_h(axes_handle==axes_h);
else
    N = numel(axes_h);
    ok = false(N,1);
    for i=1:N
        ok(i) = (axes_handle==axes_h{i});
    end
    colorbar_h = colorbar_h(ok);
end
