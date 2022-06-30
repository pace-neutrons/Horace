function [ilo,ihi] = parse_top_doc_comment_blocks (cstr)
% Find leading comment blocks after classdef, function, properties, methods statements
%
%   >> [ilo,ihi] = parse_top_doc_comment_blocks (cstr)
%
% Input:
% ------
%   cstr    Cell array of character strings read from the file
%
% Output:
% -------
%   ok      True if all OK, flase if not
%   mess    Error message if not OK; '' if OK
%   ilo     Array of line indicies of start of leading comment blocks which
%          may contain meta documentation that is permitted to be parsed
%   ihi     Array of line indicies of end of these leading comment blocks
%
% Note: if there are no blocks to be checked, numel(ilo)==numel(ihi)==0


% Trivial case of no lines
if numel(cstr)==0
    ilo=[]; ihi=[];
    return
end

% Find class definition or function key words, and look for immediately
% following comment block
keyword = {'function', 'classdef','methods','properties'};
tok = strtok(cstr);
ind = find(ismember(tok,keyword));

% Find leading comment lines, which may therefore contain meta documentation
ilo = ind+1;    % first line after a keyword line
ihi = NaN(size(ilo));
iscomment=strncmp(cstr,'%',1);
for i=1:numel(ilo)
    ind = find(~iscomment(ilo(i):end),1);
    if ~isempty(ind)
        ihi(i) = ind+ilo(i)-2;
    else
        ihi(i) = numel(cstr);
    end
end

% Remove any empty blocks
keep = (ilo<=ihi);
ilo = ilo(keep);
ihi = ihi(keep);
