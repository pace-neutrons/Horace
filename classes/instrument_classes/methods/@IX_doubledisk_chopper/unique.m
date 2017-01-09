function [bObj, m, n] = unique(aObj, varargin)
% Equivalent to intrinsic Matlab unique but here for objects
%
%   >> [bObj, m, n] = unique(aObj)
%   >> [bObj, m, n] = unique(aObj, occurence)
%
% Input:
% ------
%   aObj        Array of input objects
%
%   occurence   Character string 'last' [default] or 'first'; indicates if the index
%              element in output array m points to first or last occurence of
%              a non-unique element in aObj
%
% Output:
% -------
%   bObj        Sorted array of unique elements in aObj
%
%   m           Index array such that bObj=aObj(m)
%
%   n           Index array such that aObj=bObj(n)


[~,m,n] = uniqueStruct(struct(aObj(:)), varargin{:});
bObj=aObj(m);
