function status = adjust_aspect(w)
% Determine if the sqw object desires that the aspect ratio is adjusted

% Toby Perring 10 August 2015

status = w.data.axes.changes_aspect_ratio;
