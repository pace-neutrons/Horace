function tf = istext(str)
% Determine if str is character or string

if iscell(str)
    tf = cellfun(@(str)(ischar(str) || isstring(str)),str);
else
    tf = ischar(str) || isstring(str);
end

