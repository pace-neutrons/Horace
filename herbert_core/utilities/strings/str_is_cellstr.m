function [ok, n] = str_is_cellstr (arg)
% Determine if an argument is a cell array of character vectors
%
%   >> [ok, n] = str_is_cellstr (arg)
%
%
% Input:
% ------
%   arg             Input argument
%
% Output:
% -------
%   ok              Logical scalar
%                   - true if the input is cell array of character vectors
%                     (i.e. row vector of characters, or the empty character, '').
%                     An empty cell array is also true: it is the case of no
%                     character vectors - consistent with Matlab iscellstr.
%                   - false otherwise
%
%                   EXAMPLES: 
%                     Valid input:
%                       {}    {''}    {'45'}    {'hello', 'sunshine'}
%                     Invalid input:
%                       45    {45}    '45'      {{'45'}}   {['bad';'man']}
%
%   n               Array with the number of characters in each of the character
%                   vectors in the cell array. [Same size as the input cell array].
%                   Where the input argument is not a cell array of character
%                   vector, n = NaN


if ~iscell(arg)
    ok = false;
    n = NaN;
elseif numel(arg) == 1
    [ok, n] = is_charVector (arg{1});
elseif numel(arg) > 1
    [ok_arr, n] = cellfun(@is_charVector, arg);
    ok = all(ok_arr(:));
else
    ok = true;
    n = zeros(size(arg));
end
