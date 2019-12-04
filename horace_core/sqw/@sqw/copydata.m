function wout = copydata (win,varargin)
% copydata method - gataway to dnd object copydata only.

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

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
