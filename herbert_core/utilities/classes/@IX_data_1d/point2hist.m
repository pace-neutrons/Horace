function wout=point2hist(win)
% Convert point IX_dataset_1d (or an array of them) to histogram dataset(s).
%
%   >> wout=point2hist(win)
%
% Leaves histogram datasets unchanged.
%
% Point datasets are converted to distributions as follows:
%       Point distribution => Histogram distribution;
%                             Signal numerically unchanged
%
%         non-distribution => Histogram distribution;
%                             Signal numerically unchanged
%                     *** Signal caption will be plotted incorrectly if units
%                         are given in the axis description of the point data
%
% Point data is always converted to a distribution: it is assumed that point
% data represents the sampling of a function at a series of points, and only
% a histogram as a distribution is consistent with that.

wout=win;
for iw=1:numel(win)
    if numel(win(iw).x)==numel(win(iw).signal)
        if numel(win(iw).x)>0
            [wout(iw).x,ok,mess]=bin_boundaries_simple(win(iw).x);
            if ~ok, error(['Cannot convert to histograms: ',mess]), end
        else
            wout(iw).x=0;   % need to give a single value
        end
        if ~win(iw).x_distribution, wout(iw).x_distribution=true; end   % always convert into distribution
    end
end
