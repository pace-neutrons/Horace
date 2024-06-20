function  [any_within,is_within]=bins_in_1Drange_(edges,minmax_val)
% get bins which lie within the given range in one dimension
%
% No checks of arguments validity due to specifics of the usage within AxesBlockBase.
% If usage is expanded, the check should be performed
%
% Inputs:
% edges       -- equally spaced increasing array of values,
%                representing bin edges.
% minmax_val  -- 2 element vector of min/max values which should
%                surround contributing range
% Output:
% any_within -- true if any input bin contribute into the
%               selected range and false otherwise
% is_within  -- logical array of size numel(bins), containing true for bins
%               within the given ranges and false for others. leftmost bin
%               edge for the bin, where minmax_val(1) value contributes to, also
%               considered as being in the range due to the binning algorithm.
%
%
wk        = edges<minmax_val(1);
all_low   = wk(1:end-1)&wk(2:end);
wk        = edges>minmax_val(2);
all_high  = wk(1:end-1)&wk(2:end);
is_within = ~(all_low|all_high);
any_within= any(is_within);
