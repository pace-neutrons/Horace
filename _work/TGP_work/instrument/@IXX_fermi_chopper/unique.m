function [bObj, m, n] = unique(aObj, varargin)
% Equivalent to intrinsic Matlab unique but here for objects
%
%   >> [bObj, m, n] = unique(aObj)
%   >> [bObj, m, n] = unique(aObj, occurence)
%
% Input:
% ------
%   aObj        Array of input objects (row or column vector)
%
%   occurence   Character string 'last' [default] or 'first'; indicates if the index
%              element in output array m points to first or last occurence of
%              a non-unique element in aObj
%
%  'legacy'     If present, then the output array m (below) follows the 
%              legacy behaviour (i.e. Matlab 2012b and earlier)
%
% Output:
% -------
%   bObj        Sorted array of unique elements in aObj
%
%   m           Index array such that bObj=aObj(m)
%
%   n           Index array such that aObj=bObj(n)


if ~isvector(aObj), error('Object array must be row or column vector'), end
[~,m,n] = uniqueStruct(obj2struct(aObj), varargin{:});
bObj=aObj(m);
