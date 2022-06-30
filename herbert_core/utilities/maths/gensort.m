function [B, ix] = gensort(A,varargin)
% Sort a struct array or object array of any complexity
%
% Sort structure or object array:
%   >> [B, ix] = gensort(A)                 % public object properties (default)
%   >> [B, ix] = gensort(..,'public')       % equivalent to above
%   >> [B, ix] = gensort(..,'independent')  % independent object properties
%
% Resolve objects into structures before sorting:
% (The sorting can be much faster as the overhead of resolving objects is
% greatly reduced. However, it prevents any object-specific comparison
% methods from being used)
%   >> [B, ix] = gensort(...,'resolve')             % public properties (default)
%   >> [B, ix] = gensort(...,'resolve','public')    % same as above
%   >> [B, ix] = gensort(...,'resolve','independent')   % independent properties
%
% Similar to the intrinsic Matlab sort
%
% This is a general sorting algorithm that recursively resolves any objects
% into its properties, and which can sort variable types of dissimilar
% types and sizes.
% In the case that the fields or properties are all character arrays or
% numeric or logical arrays, use one of the faster functions
%  <a href="matlab:help('sortStruct');">sortStruct</a> , <a href="matlab:help('sortObj');">sortObj</a> or <a href="matlab:help('sortObjIndep');">sortObjIndep</a>.
%
%
% Input:
% ------
%   A       Struct or object array to be sorted (row or column vector)
%
% Optional keywords:
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
%   B       Sorted struct or object array. Same shape as A
%   ix      Index array with the same size as A, so B = A(ix)


if ~(isobject(A) || isstruct(A)), error('Function only sorts struct or object arrays'), end
if ~isvector(A), error('Array must be row or column vector'), end

% Parse options
keyval_def = struct('resolve', false, 'public', false, 'independent', false);
flags = {'resolve','public','independent'};
opt.flags_noneg = true;

[par,keyval,~,~,ok,mess] = parse_arguments (varargin,keyval_def,flags,opt);

if ~ok, error(mess), end
if ~isempty(par), error('Check the optional arguments'), end

if keyval.public && keyval.independent
    error('Only one of ''public'' and ''independent'' can be present')
elseif ~keyval.independent
    keyval.public = true;
end

% Perform sort
if ~isequalnArr(A)
    if keyval.resolve
        if keyval.public
            [~, ix] = gensort_private(obj2struct(A));
        else
            [~, ix] = gensort_private(obj2structIndep(A));
        end
        B = A(ix);
    else
        [B, ix] = gensort_private(A, keyval.public);
    end
else
    B = A;
    ix = reshape(1:numel(A),size(A));
end
