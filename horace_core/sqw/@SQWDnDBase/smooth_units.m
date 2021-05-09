function wout = smooth_units(win, varargin)
% Smooth method - gataway to dnd object smoothing only.

% Only applies to dnd datasets at the moment. Check all elements before smoothing (avoids possibly costly wasted computation if error)
if any(arrayfun(@(w) has_pixels(w), win))
    error('HORACE:smooth:invalid_arguments', ...
        'No smoothing of sqw data implemented. Convert to corresponding dnd object and smooth that.')
end

wout = copy(win);   % initalise the output
for i=1:numel(win)
    wout(i).data_ = smooth_dnd(win(i).data_, true, varargin{:});
end

