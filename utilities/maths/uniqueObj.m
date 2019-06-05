function [cObj, m, n] = uniqueObj(aObj, varargin)
% Sorts unique values of an object array according to public properties
%
%   >> [cObj, m, n] = uniqueObj(aObj)
%   >> [cObj, m, n] = uniqueObj(aObj, occurence)
%   >> [cObj, m, n] = uniqueObj(...,'legacy')
%
% Very similar to the intrinsic Matlab unique but here for an object array
%
% The sort is performed on the public properties of the object.
% For an equivalent method on the independent properties (hidden and public)
% use <a href="matlab:help('uniqueObjIndep');">uniqueObjIndep</a>.
%
% The properties must be must be numeric arrays, logical arrays, or character
% arrays.
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
%   cObj        Sorted array of unique elements in aObj
%
%   m           Index array such that cObj=aObj(m)
%
%   n           Index array such that aObj=cObj(n)


if ~isobject(aObj), error('Function only sorts object arrays'), end
if ~isvector(aObj), error('Object array must be row or column vector'), end

% Parse options
keyval_def = struct('last', false, 'first', false, 'legacy', false);
flags = {'last','first','legacy'};
opt.flags_noneg = true;

[par,keyval,~,~,ok,mess] = parse_arguments (varargin,keyval_def,flags,opt);

if ~ok, error(mess), end
if ~isempty(par), error('Check the optional arguments'), end

if keyval.last && keyval.first
    error('Only one of ''first'' and ''last'' can be present')
elseif ~keyval.first
    keyval.last = true;
end

% Perform unique sort
if ~isequalnArr(aObj)
    [cStruct, ix] = sortStruct_private(structArrPublic(aObj));
    [~, m, n] = genunique_private(cStruct, ix, keyval.first, keyval.legacy);
    cObj = aObj(m);
else
    [cObj,m,n] = genunique_private(aObj, [], keyval.first, keyval.legacy);
end
