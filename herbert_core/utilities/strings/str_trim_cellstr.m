function [cout,all_non_empty,ok] = str_trim_cellstr(cin)
% Trim leading and trailing whitespace and remove empty entries from a cellstr
%
%   >> [cout,all_non_empty,ok] = str_trim_cellstr(cin)
%
% Input:
% ------
%   cin             Cell array of strings
%
% Output:
% -------
%   cout            Column vector cellstr, with empty entries removed.
%   all_non_empty   True if all input strings are non-empty
%   ok              Logical column vector, true where cout is non-empty

cout=strtrim(cin(:));
ok=~cellfun(@isempty,cout);
if ~all(ok)
    cout=cout(ok);
    all_non_empty=false;    
else
    all_non_empty=true;
end
