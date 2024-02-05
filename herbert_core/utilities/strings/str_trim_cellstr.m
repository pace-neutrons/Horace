function [cstr, all_non_empty, non_empty] = str_trim_cellstr (cstr_in)
% Trim whitespace and remove empty elements from a cell array of character vectors
%
%   >> [cstr, all_non_empty, non_empty] = str_trim_cellstr (cstr_in)
%
%
% Input:
% ------
%   cstr_in         Cell array of character vectors  (i.e. row vector of
%                   characters length >= 0 or the empty character array, '')
%
% Output:
% -------
%   cout            Column vector cell array, with leading and trailing
%                   whitespace trimmed and empty entries removed
%
%   all_non_empty   True if all input strings are non-empty after leading and
%                   trailing whitespace is removed
%
%   non_empty       Logical column vector with length equal to the number of
%                   character vectors in the input cell array, cstr_in, where
%                   elements are true if the corresponding element of cstr_in is
%                   non-empty after trimming, and false otherwise

if ~str_is_cellstr(cstr_in)
    error('HERBERT:str_trim_cellstr:invalid_argument',...
        'Input argument must be a cell array of character vectors')
end

cstr = strtrim(cstr_in(:));
non_empty = ~cellfun(@isempty, cstr);

all_non_empty = all(non_empty);
cstr = cstr(non_empty);
