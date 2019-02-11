function [bObj,ix]=sort(aObj)
% Equivalent to intrinsic Matlab sort but here for objects
%
%   >> [bObj, ix] = sort(aObj)  % arguments as intrinsic Matlab sort
%
% Input:
% ------
%   aObj    Object array to be sorted (row or column vector)
%
% Output:
% -------
%   bObj    Sorted object array. Same shape as aObj
%   ix      Index array bObj = aObj(ix)

[~,ix] = sortStruct(obj2struct(aObj));
bObj=aObj(ix);
