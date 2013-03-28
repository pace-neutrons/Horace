function [cout,all_non_empty] = str_trim_cellstr(cin)
% Trim leading and trailing whitespace and remove empty entries from a cellstr
%
%   >> [ok,cout] = str_make_cellstr(cin)
%
% Input:
% ------
%   cin             Cell array of strings
%
% Output:
% -------
%   ok              =true if valid input (could all be empty)
%   cout            Column vector cellstr, with empty entries removed.
%   all_non_empty   True if all strings are non-empty

ok=true(size(cin));
cout=strtrim(cin(:));
for i=1:numel(cout)
    ok(i)=~isempty(cout{i});
end
if ~all(ok(:))
    cout=cout(ok);
    all_non_empty=false;    
else
    all_non_empty=true;
end
