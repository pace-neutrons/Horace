function [ok, cstr, all_non_empty, non_empty] = str_make_cellstr_trim (varargin)
% Make a cellstr of trimmed character vectors from a set of input arguments
% After trimming leading and trailing whitespace, the function also removes
% empty character vectors.
%
%   >> [ok, cstr, all_non_empty, non_empty] = str_make_cellstr_trim (c1, c2, c3,...)
%
% Differs from str_make_cellstr, which only removes trailing whitespace from
% character vectors and does not trim Matlab string objects at all; nor does it
% remove empty character vectors.
%
% See also str_make_cellstr
%
%
% Input:
% ------
%   c1,c2,c3,...    Input text: each can be one of:
%                   - Character vector (i.e. row vector of characters length >= 0
%                     or the empty character array, '')
%                   - Two-dimensional character array
%                   - Cell array of character vectors
%                   - strings or string array (Matlab release R2017a onwards)
%
% Output:
% -------
%   ok              Logical scalar:
%                   - true if all input arguments were convertible to a cell
%                     array of character vectors
%                   - false if conversion not possible
%
%   cstr            Column vector cell array of character vectors.
%                   Uses the Matlab function cellstr to perform the conversion
%                   on each input argument.
%                   Trailing whitespace is removed from character vectors and 
%                   character vectors created from 2D character arrays, but not
%                   from Matlab string objects.
%
%                   If ok is false: (i.e. conversion of all input arguments to 
%                   character vectors was not possible), then false.
%
%   all_non_empty   If ok is true, then all_non_empty is true if all input
%                       strings are non-empty; false otherwise.
%                   If ok is false, then all_non_empty is set to false
%
%   non_empty       If ok is true: 
%                   Logical column vector with length equal to the number of
%                   character vectors in the input cell array, cstr_in, where
%                   elements are true if the corresponding element of cstr_in is
%                   non-empty after trimming, and false otherwise
%
%                   If ok is false, then all_non_empty is set to false


[ok, cstr] = str_make_cellstr (varargin{:});
if ok
    [cstr, all_non_empty, non_empty] = str_trim_cellstr(cstr);
else
    all_non_empty = false;
    non_empty = false;
end
