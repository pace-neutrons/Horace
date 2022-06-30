function ind = stringmatchi (str, strcell)
% Index of match(es) or unambiguous abbreviations in a cell array of strings
%
%   >> ind = stringmatchi (string,strcell)
%
% Input:
% ------
%   string  Test string
%   strcell Cell array of strings
%
% Output:
% -------
%   ind     Index of str in strcell if str is an exact match or unambiguous
%          abbreviation of one of the elements of cellst.
%           If str is an exact match for one or more elements of strcell,
%          only these indicies are returned even if it is also an abbreviation
%          of other element


if ~is_string(str)
    error('First argument must be a string')
end

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
