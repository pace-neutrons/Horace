function ind = stringmatchi (varargin)
% Find matches of a character vector to initial substrings of strings, ignoring case
%
% Returns an index array of exact matches of a character vector to a cell array
% of strings, if there are any.
% If there are no exact matches, then returns an index array where the 
% character vector is an abbreviation of the contents of the cell array.
%
%   >> ind = stringmatchi (str, strcell)
%   >> ind = stringmatchi (str, strcell, exact)      % option: logical 0 or 1
%   >> ind = stringmatchi (str, strcell, '-exact')   % option: character string
% 
% Differs from stringmatchiLog, which returns a logical array matches, not an
% index array.
%
% See also stringmatchi
%
%
% Input:
% ------
%   str         Character vector (i.e. row vector of characters, or the empty
%              character, '')
%   strcell     Cell array of strings (as accepted by Matlab function strcmpi)
%
% Optional:
%   exact       Logical flag
%                   true: exact match required
%                   false [default]: exact matches not required
% *OR*
%   'exact'     If present, output only for exact matches
%
% Output:
% -------
%   ind         Indices of elements in strcell to which str is an exact match.
%               If there are no exact matches then the indices are to elements
%              in strcell to which str is an abbreviation


status = stringmatchi_log(varargin{:});
ind = find(status);
