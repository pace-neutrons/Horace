function s2=avoidtex(s1)
% Put '\' in front of '\', '_', '^' control characters to avoid tex interpreter warning messages
%   >> s2=avoidtex(s1)
%
%   s1, s2 strings of characters (one row)
%
% Used to put exact filename in figure titles

% Radu Coldea 02-Oct-1999

if ischar(s1)
    char_flag = true;
elseif iscell(s1)
    char_flag = false;
else
    s2 = s1;
    return;
end

% use cells to do multiline
s1 = cellstr(s1);
s2 = s1;

for j = 1:length(s1)
    pos=sort([findstr(s1{j},'\') findstr(s1{j},'_') findstr(s1{j},'^')]);
    for i=1:length(pos),
       s2{j}=[s2{j}(1:(pos(i)+i-2)) '\' s2{j}((pos(i)+i-1):length(s2{j}))];
    end   
end

% if it started as a char, it should end as a char
if char_flag
    s2 = char(s2);
end
