function ok = iscolumn(var)
% True if array is a column vector i.e. n x 1 array with n>=0
%
%   >> ok = iscolumn(var)
%
% Note: if var is empty but has size 1x0 then will return true

ok = numel(size(var))==2 & size(var,2)==1;
