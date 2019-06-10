function [C, m, n] = genunique(A,varargin)
% Sort unique values of a struct array or object array of any complexity
%
%   >> [C, m, n] = genunique(A)
%   >> [C, m, n] = genunique(A, occurence)
%   >> [C, m, n] = genunique(...,'legacy')
%
%   >> [C, m, n] = genunique(..,'public')       % public object properties (default)
%   >> [C, m, n] = genunique(..,'independent')  % independent object properties
%
% Resolve objects into structures before sorting:
% (The sorting can be much faster as the overhead of resolving objects is
% greatly reduced. However, it prevents any object-specific comparison
% methods from being used)
%   >> [C, m, n] = genunique(...,'resolve')             % public properties (default)
%   >> [C, m, n] = genunique(...,'resolve','public')    % same as above
%   >> [C, m, n] = genunique(...,'resolve','independent')   % independent properties
%
% Very similar to the intrinsic Matlab unique
%
% The function uses a general sorting algorithm that recursively resolves
% any objects into its properties, and which can sort variable types of
% dissimilar types and sizes.
% In the case that the fields or properties are all character arrays or
% numeric or logical arrays, use one of the faster functions
%  <a href="matlab:help('uniqueStruct');">uniqueStruct</a> , <a href="matlab:help('uniqueObj');">uniqueObj</a> or <a href="matlab:help('uniqueObjIndep');">uniqueObjIndep</a>.
%
%
% Input:
% ------
%   A       Struct or object array to be sorted (row or column vector)
%
% Optional sorting keywords:
%   occurence   Character string: 'last' or 'first'; indicates if the index
%              element in output array m points to first or last occurence of
%              a non-unique element in A
%               Default: 'first' ('last' if specify 'legacy')
%
%  'legacy'     If present, then the output array m (below) follows the
%              legacy behaviour (i.e. Matlab 2012b and earlier)
%
% Optional object handling keywords:
%  'resolve'        Recursively resolve objects into structures before
%                  sorting.
%
%  'public'         Keep public properties (independent and dependent)
%                   More specifically, it calls an object method called
%                  structPublic if it exists; otherwise it calls the
%                  generic function structPublic.
%
%  'independent'    Keep independent properties only (hidden, protected and
%                  public)
%                   More specifically, it calls an object method called
%                  structIndep if it exists; otherwise it calls the
%                  generic function structIndep.
%
% Output:
% -------
%   C       Sorted struct or object array. Same shape as A
%   ix      Index array C = A(ix)


if ~(isobject(A) || isstruct(A)), error('Function only sorts struct or object arrays'), end
if ~isvector(A), error('Array must be row or column vector'), end

% Parse options
keyval_def = struct('last', false, 'first', false, 'legacy', false,...
    'resolve', false, 'public', false, 'independent', false);
flags = {'last','first','legacy','resolve','public','independent'};
opt.flags_noneg = true;

[par,keyval,~,~,ok,mess] = parse_arguments (varargin,keyval_def,flags,opt);

if ~ok, error(mess), end
if ~isempty(par), error('Check the optional arguments'), end

if keyval.public && keyval.independent
    error('Only one of ''public'' and ''independent'' can be present')
elseif ~keyval.independent
    keyval.public = true;
end

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
if ~isequalnArr(A)
    % Perform sort
    if keyval.resolve
        if keyval.public
            [~, ix] = gensort_private(obj2struct(A));
        else
            [~, ix] = gensort_private(obj2structIndep(A));
        end
        C = A(ix);
    else
        [C, ix] = gensort_private(A, keyval.public);
    end
    % Find unique elements
    [C, m, n] = genunique_private(C, ix, keyval.first, keyval.legacy);
    
else
    [C, m, n] = genunique_private(A, [], keyval.first, keyval.legacy);
end
