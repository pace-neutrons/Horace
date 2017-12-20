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
%   mess            Accumulated message, having trimmed trailing whitespace.
%                   If all strings are empty, returns ''
%                   If just one non-empty string, then returns a character string
%                   Otherwise, cell array of non-empty strings


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


[ok,mess]=str_make_cellstr(varargin{:});
if ~ok
    error('One or more inputs are not character strings or cell array of characters')
end
