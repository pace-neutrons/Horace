function [val, n] = data_bin_limits (obj)
% Get limits of the data in an n-dimensional dataset, that is,
% find the coordinates along each of the axes of the smallest
% cuboid that contains bins with non-zero values of
% contributing pixels.
%
% Syntax:
%   >> [val, n] = data_bin_limits (din)
%
[val,n] = obj.data.data_bin_limits();
end
