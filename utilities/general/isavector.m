function ok = isavector(var)
% True if array is a column or row vector i.e. 1 x n or n x 1 array, n>=0.
%
%   >> ok = isavector(var)
%
% Note: If var is empty but has size 1x0 then will return true
%       Has same behaviour as Matlab intrinsic function isvector

ok = numel(size(var))==2 && (size(var,1)==1||size(var,2)==1);
