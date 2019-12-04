function status = adjust_aspect(w)
% Determine if the sqw object desires that the aspect ratio is adjusted
% Isolate a function that is part of on-going developments for
% non-orthogonal axes, but which works with non-trunk Horace

% Toby Perring 10 August 2015

try
    status = w.data.axis_caption.changes_aspect_ratio;
catch
    status = true;
end
