function [bObj,ix]=sort(aObj)
% Equivalent to intrinsic Matlab sort but here for objects
%
%   >> [bObj, ix] = sort(aObj)   % arguments as per intrinsic Matlab

[~,ix] = sortStruct(struct(aObj(:)), fieldnames(aObj)');
bObj=aObj(ix);
