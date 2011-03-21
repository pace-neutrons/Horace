function ok = isrow(var)
% True if array is a row vector i.e. 1 x n array, n>=0.
%
%   >> ok = isrow(var)
%
% Note: if var is empty but has size 0x1 then will return true

ok = numel(size(var))==2 & size(var,1)==1;
