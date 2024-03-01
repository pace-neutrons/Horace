function [frac,n_points] = calc_cont_frac_(obj)
% Calculate the fraction of continuous areas of plot
% not containing NaNs, so to be displayed on a plot.
% e.g:
% if signal = [1,NaN,2,3,NaN,4] the continuious plot area would
% be 2,3, and points 1 and 4 are not displaying if you are
% plotting a line. Such dataset contains 4 points, only two
% would be plotted by pl, so the function returns frac = 2/4 = 0.5;
%
% Returns:
% frac  -- fraction of the points to be plotted out of all valid points (not-NaN)
% n_points -- number of points containing information (not NaN-s)

sig = obj.signal_;
isn = isnan(sig);
if ~any(isn) % no nans
    frac = 1;
    n_points = numel(sig);
    return;
end
n_points = sum(~isn);
if n_points == 0
    frac = 0;
    return;
end
% calculate number of continuous points
ic=2:numel(sig)-1;
not_nan = ~isn;
continuous= arrayfun(@(i)(not_nan(i)&&(not_nan(i-1)||not_nan(i+1))),ic);
n_continuous = sum(continuous);
% first point belongs to continuious if first element of continous arry is
% true
if not_nan(1) && continuous(1)
    n_continuous = n_continuous +1;
end
% last point is continuous if the previous is not nan
if not_nan(end) && continuous(end)
    n_continuous = n_continuous +1;
end

frac = n_continuous/n_points;