function mess = accumulate_message (varargin)
% Accumulate messages 
%
%   >> mess = accumulate_message (mess1, mess2, ...)
%
% Input:
% ------
%   mess1,mess2,... Input messages (character string or cell array of strings)
%
% Output:
% -------
%   mess            Accumulated message, having trimmed trailing whitespace
%                   and removed empty strings.
%                   If all strings are empty, returns ''
%                   If just one non-empty string, then returns a character string
%                   Otgherwise, cell array of non-empty strings

[ok,mess]=str_make_cellstr(varargin{:});
if ~ok
    error('One or more inputs are not character strings or cell array of characters')
end
