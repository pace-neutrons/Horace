function ok=isstringmatchi(str1,str2)
% Determine if a string beginning with the other, ignoring case
%
%   >> ok=isstringmatchi(str1,str2)
%
% Note: if either string is empty, or if either input is not a string, then ok=false

ok = ischar(str1) && isrow(str1) && ischar(str2) && isrowvector(str2) &&...
    strncmpi(str1,str2,min(numel(str1),numel(str2)));
