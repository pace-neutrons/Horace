function wout=hist2point(win)
% Convert histogram IX_dataset_1d (or an array of them) to point dataset(s).
%
%   >> wout=hist2point(win)
%
% Leaves point datasets unchanged.
%
% Histogram datasets are converted to distribution as follows:
%       Histogram distribution => Point data distribution;
%                                 Signal numerically unchanged
%
%             non-distribution => Point data distribution;
%                                 Signal converted to signal per unit axis length
%
% Histogram data is always converted to a distribution: it is assumed that point
% data represents the sampling of a function at a series of points, and histogram
% non-distribution data is not consistent with that.


wout=win;
for iw=1:numel(win)
    if numel(win(iw).x)>numel(win(iw).signal)
        if numel(win(iw).x)>1
            wout(iw).x=0.5*(win(iw).x(2:end)+win(iw).x(1:end-1));
        else
            wout(iw).x=[];  % can have a histogram dataset with only one bin boundary and empty signal array
        end
        if ~win(iw).x_distribution
            if numel(win(iw).x)>1           % don't need tconsider case of one bin, as signal is [] anyway.
                dx=diff(win(iw).x);
                wout(iw).signal=win(iw).signal./dx';
            end
            wout(iw).x_distribution=true;   % always convert into distribution
        end
    end
end
