function wout=hist2point(win)
% Convert histogram dataset(s) to point datasets.
%
%   >> wout=hist2point(win)
%
% Leaves point datasets unchanged.

wout=win;
for iw=1:numel(win)
    if numel(win(iw).x)>numel(win(iw).signal)
        if numel(win(iw).x)>1
            wout(iw).x=0.5*(win(iw).x(2:end)+win(iw).x(1:end-1));
        else
            wout(iw).x=[];  % can have a histogram dataset with only one bin boundary and empty signal array
        end
    end
end
