function wout = rebunch (win,varargin)
% Rebunch method - gataway to dnd object rebunching only.

% Original author: T.G.Perring
%
% $Revision: 1524 $ ($Date: 2017-09-27 15:48:11 +0100 (Wed, 27 Sep 2017) $)

% Only applies to dnd datasets at the moment. Check all elements before rebunching (avoids possibly costly wasted computation if error)
for i=1:numel(win)
    if is_sqw_type(win(i))
        error('No rebunching of sqw data implemented. Convert to corresponding dnd object and rebunch that.')
    end
end

wout=win;   % initalise the output
for i=1:numel(win)
    wout(i).data = rebunch_dnd(win(i).data,varargin{:});
end
