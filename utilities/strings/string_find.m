function ind = string_find (str, strcell)
% Find element in a cell array of strings for which the test string is an unambiguous abbreviation
%
%   >> ind = string_find(str,strcell)
%
%   str     Test string
%   strcell Cell array of strings to compare with
%
%   ind     Index of str in strcell if str is an exact match or unambiguous
%           abbreviation of one of the elements of cellst. Note: if str is
%           an exact match for an element of strcell, then it is accepted as
%           unique even if it is also an abbreviation for another element
%           
%           ind=0  no abbreviation
%           ind<0  more than one possible match: |ind| = number matches
%
% Related to Matlab intrinsic strmatch, but not identical

if ~(ischar(str) && size(str,1)==1)
    ind = 0;  % not a single string
end

if iscellstr(strcell) && ~isempty(strcell)
    l_str = length(str);
    matches = 0;
    equality = 0;
    for i = 1:length(strcell)
        n = length(strcell{i});
        if (n >= l_str)
            index = strncmpi(str,strcell{i},l_str);
            if index==1
                i_match = i;
                matches = matches + 1;
                if n==l_str
                    i_equal = i;
                    equality = equality + 1;
                end
            end
        end
    end
    if equality == 1
        ind = i_equal;
    elseif matches == 0
        ind = 0;
    elseif matches == 1
        ind = i_match;
    elseif matches > 1
        ind = -1;
    end
else
    ind = 0;
end
