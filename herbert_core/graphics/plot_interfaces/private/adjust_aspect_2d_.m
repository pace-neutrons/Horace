function adjust_aspect_2d_(w)
% Set aspect ratio
%
adjust_aspect = w(1).axes.changes_aspect_ratio;
if adjust_aspect
    pax = w(1).pax;
    dax = w(1).dax;                  % permutation of projection axes to give display axes
    ulen = w(1).axes.ulen(pax(dax)); % unit length in order of the display axes
    energy_axis = 4;    % by convention in Horace
    if pax(dax(1))~=energy_axis && pax(dax(2))~=energy_axis    % both plot axes are Q axes
        aspect(ulen(1), ulen(2));
    end
    colorslider;        % redraw in case of aspect ratio change
end
