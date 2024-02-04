function L = str_length (str)
% Lengths of strings
%
%   >> L = str_length (str)
%
% Performs the same function as Matlab intrinsic function strlength, except that
% it also works for Matlab versions prior to R2017a i.e. before the new string
% class was introduced.
%
%
% Input:
% ------
%   str     One of:
%           - Character vector (i.e. row vector of characters length >= 0
%             or the empty character array, '')
%           - Cell array of character vectors
%           - String array
%
% Output:
% -------
%   L       Array of lengths of each of the character vectors or strings


if isa(string(),'string') && isstring(str)
    % A curious check, but is the fastest way to determine if Matlab string
    % class is supported (a factor 100-200 times faster than calling verLessThan
    % to check the Matlab version supports strings - certainly as of July 2021
    % on T.G.Perring's Dell 5540 Precision mobile workstation)
    L = strlength (str);
else
    if ~iscell(str)
        [ok, L] = is_charVector(str);   % catch character vector
    else
        [ok, L] = str_is_cellstr(str);  % catch cell array of character vectors
    end
    if ~all(ok(:))
        error('HERBERT:str_length:invalid_argument',...
        'First argument must be text.')
    end
end 
