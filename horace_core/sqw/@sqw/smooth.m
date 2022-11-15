function wout = smooth(win, varargin)
% Smooth method - gataway to dnd object smoothing only.
%
% Only applies to SQW datasets without pixels at the moment.
%
% Original author: T.G.Perring
%

% Check all elements before smoothing (avoids possibly costly wasted computation if error)
if any(has_pixels(win))
    error('HORACE:sqw:invalid_argument', ...
        'No smoothing of sqw data implemented. Convert to corresponding dnd object and smooth that.')
end

% return cellarray of corresponding dnd objects
wout_dnd = dnd(win,'-cell');
wout = copy(win);

for i=1:numel(win)
    wout(i).data = smooth(wout_dnd{i}, varargin{:});
end
