function wout = copydata (win,varargin)
% copydata method - gataway to dnd object copydata only.

% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)

% Only applies to dnd datasets at the moment. Check all elements before operation (avoids possibly costly wasted computation if error)
for i=1:numel(win)
    if is_sqw_type(win(i))
        error('No copydata for sqw data implemented.')
    end
end

wout=win;   % initalise the output
for i=1:numel(win)
    wout(i).data = copydata_dnd(win(i).data,varargin{:});
end
