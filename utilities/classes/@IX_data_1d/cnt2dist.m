function wout=cnt2dist(win)
% Convert histogram dataset(s) from counts per bin to counts per unit x
%
%   >> wout=cnt2dist(win)
%
% Leaves unchanged histogram data that is already in counts per unit x, and point datasets

wout=win;
for iw=1:numel(win)
    % Note: ignore case where histogram data but empty signal array
    if numel(win(iw).x)~=numel(win(iw).signal) && numel(win(iw).x)>1 && ~win(iw).x_distribution
        dx=win(iw).x(2:end)-win(iw).x(1:end-1);
        wout(iw).signal = wout(iw).signal./dx';
        wout(iw).error = wout(iw).error./dx';
        wout(iw).x_distribution = true; 
    end
end
