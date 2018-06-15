%--------------------------------------------------------------------------
function new_list = add_to_list_(initial_list, varargin)
% Append character strings to a cell array of strings
%
%   >> new_list = add_to_list (initial_list, str1, str2, ...)
%
% Only the first occurence of new strings is appended, and then only if
% it doesn't appear in the initial list.
%
% Input:
% ------
%   initial_list    Row cell arrayof character strings
%   str1, str2,...  Can be strings or cell arrays of strings
%
% Output:
% -------
%   new_list        Row cell array with unique instances

for i=1:numel(varargin)
    str = varargin{i};
    if ischar(str) && numel(size(str))==2
        varargin{i} = {str};
    elseif iscellstr(str)
        varargin{i} = varargin{i}(:)';
    else
        error('Not all arguments are strings or cell arrays of strings')
    end
end

add_list = cat(2,varargin{:});  % make one long row
if ~isempty(add_list)
    [~,ix] = unique(add_list,'first','legacy');
    add_list = add_list(sort(ix));
    new=~ismember(add_list,initial_list);
    new_list = [initial_list,add_list(new)];
else
    new_list = initial_list;
end

