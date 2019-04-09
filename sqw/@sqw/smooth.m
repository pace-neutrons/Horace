function wout = smooth (win,varargin)
% Smooth method - gataway to dnd object smoothing only.

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)

% Only applies to dnd datasets at the moment. Check all elements before smoothing (avoids possibly costly wasted computation if error)
for i=1:numel(win)
    if is_sqw_type(win(i))
        error('No smoothing of sqw data implemented. Convert to corresponding dnd object and smooth that.')
    end
end

wout=win;   % initalise the output
for i=1:numel(win)
    wout(i).data = smooth_dnd(win(i).data,false,varargin{:});
end
