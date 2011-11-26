function ok=valid_fieldnames(c)
% Check elements of a cell array are 1xn non-empty character strings that are valid fieldnames for a structure
ok=true;
for i=1:numel(c)
    ok=ischar(c{i}) && ~isempty(c{i}) && size(c{i},1)==1 && (isvarname(c{i})||iskeyword(c{i}));
    if ~ok, return, end
end
