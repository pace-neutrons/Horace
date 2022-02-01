function  [any_within,is_within]=bins_in_1Drange_(bins,minmax)
% get bins which lie within the given range in one dimension
%
% No checks of arguments validity due to specifics of the usage within axes_block.
% If usage is expanded, the check should be performed
%
% Inputs:
% bins --  equally spaced increasing array of values,
%          representing bin edges.
% minmax  -- 2 element vector of min/max values which should
%          surround contributing range
% Output:
% any_within -- true if any input bin contribute into the
%               selected range and false otherwise
% is_within  -- logical array of size numel(bins), containing true for bins
%               within the given ranges and false for others. leftmost bin
%               edge, where minmax(1) value belongs to, also considered as
%               belonging to range due to the binning algorithm.
%
%
step = (bins(2)-bins(1));
is_within = false(1,numel(bins));
ind_min = floor((minmax(1)-bins(1))/step)+1;
ind_max = floor((minmax(2)-bins(1))/step)+1;
if ind_min<1
    if ind_max<1
        any_within = false;
        return;
    elseif ind_max == 1 % account for partial bin in the beginning
        if minmax(2)<= bins(1) && minmax(1) <= bins(1)
            any_within = false;
            return;
        end
    end
    ind_min = 1;
end
n_bins = numel(bins);
if ind_max >= n_bins
    if ind_min>n_bins
        any_within = false;
        return;
    elseif ind_min == n_bins
        if minmax(2)> bins(end) && minmax(1)>=bins(end)
            any_within = false;
            return;
        end
    end
    % last bin is always false due to the specifics of usage is_within
    % array for dE binning
    ind_max  = n_bins-1;
    if ind_min>ind_max; ind_min=ind_max; end
end
any_within = true;
is_within(ind_min:ind_max) = true;
