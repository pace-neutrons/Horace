function wout = rebunch (win,varargin)
% Rebunch method - gataway to dnd object rebunching only.

% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)

% Only applies to dnd datasets at the moment. Check all elements before rebunching (avoids possibly costly wasted computation if error)
for i=1:numel(win)
    if is_sqw_type(win(i))
        error('No rebunching of sqw data implemented. Convert to corresponding dnd object and rebunch that.')
    end
end

wout = copy(win);   % initalise the output
for i=1:numel(win)
    wout(i).data = rebunch_dnd(win(i).data,varargin{:});
end

