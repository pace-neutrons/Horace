function ok = isrowvector(var)
% True if array is a row vector i.e. 1 x n array, n>=0.
%
%   >> ok = isrow(var)
%
% Note: If var is empty but has size 1x0 then will return true
%       Has same behaviour as isrow introduced in Matlab 2010b

ok = numel(size(var))==2 && size(var,1)==1;
