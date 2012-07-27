function ok = iscolvector(var)
% True if array is a column vector i.e. n x 1 array with n>=0
%
%   >> ok = iscolumn(var)
%
% Note: If var is empty but has size 0x1 then will return true
%       Has same behaviour as isrow introduced in Matlab 2010b

ok = numel(size(var))==2 && size(var,2)==1;
