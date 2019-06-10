function [cStruct, m, n] = uniqueStruct(aStruct, varargin)
% Sorts unique values of a one-dimensional struct array
%
%   >> [cStruct m, n] = uniqueStruct (aStruct)
%   >> [cStruct m, n] = uniqueStruct (aStruct, occurence)
%   >> [cStruct m, n] = uniqueStruct (...,'legacy')
%
% Very similar to the intrinsic Matlab unique but here for a struct array
%
% Input:
% ------
%   aStruct     Structure to be sorted. Fields must be character arrays, or
%              numeric or logical arrays. Structures are sorted by the
%              first field contents, then by the second field etc.
%
%   occurence   Character string: 'last' or 'first'; indicates if the index
%              element in output array m points to first or last occurence of
%              a non-unique element in aObj
%               Default: 'first' ('last' if specify 'legacy')
%
%  'legacy'     If present, then the output array m (below) follows the
%              legacy behaviour (i.e. Matlab 2012b and earlier)
%
% Output:
% -------
%   cStruct     Sorted array of unique elements in aStruct
%
%   m           Index array such that cStruct=aStruct(m). Note that m has
%              the indicies of the last occurence of repeated elements by
%              default. This accords with the legacy (i.e. pre-c.2012) behaviour
%              of the built-in function unique. Set the input argument
%              occurence to alter this behaviour.
%
%   n           Index array such that aStruct=cStruct(n)


if ~isstruct(aStruct), error('Function only sorts structure arrays'), end
if ~isvector(aStruct), error('Structure array must be a row or column vector'), end

% Parse options
keyval_def = struct('last', false, 'first', false, 'legacy', false);
flags = {'last','first','legacy'};
opt.flags_noneg = true;

[par,keyval,~,~,ok,mess] = parse_arguments (varargin,keyval_def,flags,opt);

if ~ok, error(mess), end
if ~isempty(par), error('Check the optional arguments'), end

if ~(keyval.last || keyval.first)
    if keyval.legacy
        keyval.last = true;
    else
        keyval.first = true;
    end
elseif keyval.last && keyval.first
    error('Only one of ''first'' and ''last'' can be present')
end

% Perform unique sort
if ~isequalnArr(aStruct)
    [cStruct, ix] = sortStruct_private(aStruct);
    [cStruct, m, n] = genunique_private(cStruct, ix, keyval.first, keyval.legacy);
else
    [cStruct, m, n] = genunique_private(aStruct, [], keyval.first, keyval.legacy);
end
