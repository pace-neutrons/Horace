function status = stringmatchi_log (str, strcell, exact)
% Logical array of matches or unambiguous abbreviations in a cellstr
%
%   >> status = stringmatchi_log (str, strcell)
%   >> status = stringmatchi_log (str, strcell, exact)      % logical 0 or 1
%   >> status = stringmatchi_log (str, strcell, 'exact')    % character string
%
% Input:
% ------
%   str         Character string
%   strcell     Cell array of strings
%
% Optional:
%   exact       Logical flag
%                   false [default]: exact matches not required
%                   true: exact match required
% *OR*
%   'exact'     If present, output only for exact matches
%
% Output:
% -------
%   status      Logical array elements true where str is an exact match or
%              unambiguous abbreviation of the corresponding element of
%              strcell.
%               If str is an exact match for one or more elements of
%               strcell, only these indicies are returned even if it is
%               also an abbreviation of other element.

if ~is_string(str)
    error('HERBERT:stringmatchi_log:invalid_argument',...
        'First argument must be a string')
end

if nargin==2 || (islognumscalar(exact) && ~logical(exact))
    nch=numel(str);
    ind=find(strncmpi(str,strcell,nch));
    
    % If string and cellstr and more than one match, look for equality
    if numel(ind)>1
        ix=false(size(ind));
        for i=1:numel(ind(:))
            if numel(strcell{ind(i)})==nch
                ix(i)=true;
            end
        end
        if any(ix(:))
            ind=ind(ix);
        end
    end
    status = false(size(strcell));
    status(ind) = true;
    
elseif (islognumscalar(exact) && logical(exact)) || ...
        (is_string(exact) && strcmpi(exact,'exact'))
    status = strcmpi(str, strcell);
    
else
    error('HERBERT:stringmatchi_log:invalid_argument',...
        'Optional third argument can only take the value ''exact'' or logical true/false')
end
