function wout=point2hist(win)
% Convert point dataset(s) to histogram datasets.
%
%   >> wout=point2hist(win)
%
% Leaves histogram datasets unchanged.

wout=win;
for iw=1:numel(win)
    if numel(win(iw).x)==numel(win(iw).signal)
        if numel(win(iw).x)>0
            wout(iw).x=bin_boundaries_simple(win(iw).x);
        else
            wout(iw).x=0;   % need to give a single value
        end
    end
end
