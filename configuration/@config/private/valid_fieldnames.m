function ok=valid_fieldnames(c)
% Check elements of a cell array are 1xn non-empty character strings that are valid fieldnames for a structure
%
%   >> ok=valid_fieldnames(c)
%
% Input:
% ------
%   c   cell array
%
% Output:
% -------
%   ok  true if cell array elements all satisfy the rules for valid fieldname; false otherwise

% $Revision$ ($Date$)

ok=true;
for i=1:numel(c)
    ok=ischar(c{i}) && ~isempty(c{i}) && size(c{i},1)==1 && (isvarname(c{i})||iskeyword(c{i}));
    if ~ok, return, end
end
