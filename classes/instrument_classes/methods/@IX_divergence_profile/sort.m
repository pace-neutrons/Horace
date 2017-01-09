function [bObj,ix]=sort(aObj)
% Equivalent to intrinsic Matlab sort but here for objects
%
%   >> [bObj, ix] = sort(aObj)   % arguments as per intrinsic Matlab

aStruct=struct_special(aObj);
[~,ix] = nestedSortStruct(aStruct, fieldnames(aStruct)');
bObj=aObj(ix);
