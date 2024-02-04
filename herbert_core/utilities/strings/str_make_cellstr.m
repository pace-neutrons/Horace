function [ok, cstr] = str_make_cellstr (varargin)
% Make a cellstr of character vectors from a set of input arguments
%
%   >> [ok, cstr] = str_make_cellstr (c1, c2, c3,...)
%
% Differs from str_make_cellstr_trim, which in addition trims leading and
% trailing whitespace and also removes empty entries.
%
% See also str_make_cellstr_trim
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
%                   If ok is false (i.e. conversion of all input arguments to
%                   character vectors was not possible), then false.


% Use Matlab cellstr to convert to each input argument to a cell array of
% character vectors, if possible.
% If not possible, retain the long-standing behaviour of str_make_cellstr
% snd return a status flag of false, and do *NOT* throw an error
try
    cstr_arr = cellfun(@cellstr, varargin, 'UniformOutput', false);
catch
    ok = false;
    cstr = cell(0,1);
    return
end

% There are cases that cellstr returns but which are not a cell array of
% character vectors. An example is var = {['Pete';'Bob ']}; this results in
% cellstr(var) == var, but var is not a valid character vector. Catch any
% such cases with a call to str_is_cellstr
ok_arr = cellfun(@str_is_cellstr, cstr_arr);
if all(ok_arr(:))
    ok = true;
    cstr_arr = cellfun(@make_column, cstr_arr, 'UniformOutput', false);
    cstr = cat(1, cstr_arr{:});
else
    ok = false;
    cstr = cell(0,1);
end
