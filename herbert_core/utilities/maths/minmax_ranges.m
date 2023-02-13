function min_max = minmax_ranges(range1,range2)
% Function accepts two ranges defined by 2xN matrices containing min/max
% values, and returns common min/max of these two ranges
%
% Input:
% range1     -- 2xN martix with each column containing [min1;max1] value
% range1     -- another 2xN martix with each column containing [min2;max2] value
%
% Returns:
% min_max   -- 2xN matrix with each colum containing
% [min(min1,min2);max(max1,max2)];
if isempty(range1)
    min_max = range2;
    return;
end
if isempty(range2)
    min_max = range1;
    return;
end

min_max = [min([range1(1,:);range2(1,:)]);...
    max([range1(2,:);range2(2,:)])];
