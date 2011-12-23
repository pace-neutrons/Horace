function ok=valid_fieldnames(c)
% Check elements of a cell array are 1xn non-empty character strings that are valid fieldnames for a structure

% $Revision: 120 $ ($Date: 2011-12-20 18:18:12 +0000 (Tue, 20 Dec 2011) $)

ok=true;
for i=1:numel(c)
    ok=ischar(c{i}) && ~isempty(c{i}) && size(c{i},1)==1 && (isvarname(c{i})||iskeyword(c{i}));
    if ~ok, return, end
end
