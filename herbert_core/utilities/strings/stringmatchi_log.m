function status = stringmatchi_log (str, strcell, exact)
% Find matches of a character vector to initial substrings of strings, ignoring case
%
% Returns a logical array of exact matches of a character vector to a cell array
% of strings, if there are any.
% If there are no exact matches, then returns a logical array where the 
% character vector is an abbreviation of the contents of the cell array.
%
%   >> status = stringmatchi_log (str, strcell)
%   >> status = stringmatchi_log (str, strcell, exact)      % option: logical 0 or 1
%   >> status = stringmatchi_log (str, strcell, '-exact')   % option: character string
% 
% Differs from stringmatchi, which returns the indices of matches, not a logical
% array.
%
% See also stringmatchi
%
%
% Input:
% ------
%   str         Character vector (i.e. row vector of characters, or the empty character, '')
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
%   status      Logical array elements true where str is an exact match to the
%              corresponding element of strcell; if there are no exact
%              matches then the logical array elements indicate where str is
%              an abbreviation of the corresponding element of strcell.


% Test class of input
if ~is_charVector(str)
    error('HERBERT:stringmatchi:invalid_argument',...
        'First argument must be a character vector')
end

% Determine if exact matches are required or not
if nargin < 3
    exact = false;
elseif islognumscalar(exact)
    exact = logical(exact);
elseif is_string(exact) && numel(exact)>1 && strcmpi(exact,'-exact')
    exact = true;
else
    error('HERBERT:stringmatchi:invalid_argument', ['Optional third ', ...
        'argument can only take the value ''exact'' or logical true/false'])
end

% Find matches
if exact
    % Search for exact matches only
    status = strcmpi(str, strcell);
    
else
    % Exact matches and abbreviations
    status = strncmpi(str, strcell, numel(str));
    
    % If string and cellstr have more than one match, look for equality
    if sum(status(:)) > 1
        status_exact = strcmpi(str, strcell);
        if sum(status_exact) > 0
            status = status_exact;
        end
    end
end
