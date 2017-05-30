function wout=dist2cnt(win)
% Convert histogram dataset(s) from counts per unit x to counts per bin
%
%   >> wout=dist2cnt(win)
%
% Leaves unchanged histogram data that is already in counter per bin, and point datasets

wout=win;
for iw=1:numel(win)
    % Note: ignore case where histogram data but empty signal array
    if numel(win(iw).x)~=numel(win(iw).signal) && numel(win(iw).x)>1 && win(iw).x_distribution
        dx=win(iw).x(2:end)-win(iw).x(1:end-1);
        wout(iw).signal = dx'.*wout(iw).signal;
        wout(iw).error = dx'.*wout(iw).error;
        wout(iw).x_distribution = false; 
    end
end
