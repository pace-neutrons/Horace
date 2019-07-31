function out_title = add_title (title, more_title, npos)
% Add lines to a title for 
%
%   >> title = add_title (title, more_title, where)
%
% Input:
% ------
%   title       Character string, array of character strings, or cell array of strings
%
%   more_title  Further title to be added to original title
%
%   where       Optional argument to indicate where the further title is inserted
%                   = n (integer 1,2,3,...)  insert so additional title starts at line n
%               - Blank lines are inserted to ensure that the new title always starts at line n.
%               - If omitted, then the further title is appended at the end of the title.
%               - If n=0 is equivalent to n=1 i.e. insert at the beginning
%
% Output:
% -------
%   out_title   New title. It is alway a cellstr.
%               - If 'title' is empty, the output is made from the additional title 'more_title' only.
%               - If 'more_title' is empty, the output is made from the original title only
%               - If both are empty, then out_title is set to an empty cellstr.
%               In this context, empty means a cellstr where all entries are empty strings, or an empty character array
%               Otherwise, empty lines are respected as significant, including leading or trailing empty lines.

% Check input arguments
if ~(iscellstr(title)||(ischar(title) && numel(size(title))==2))
    error ('Title must be a cellstr or character array')
end
if ~(iscellstr(more_title)||(ischar(more_title) && numel(size(more_title))==2))
    error ('Addition to to be added to label not a cellstr or character array')
end
if nargin==3
    if ~(isnumeric(npos) && iscalar(npos) && round(npos)==npos && npos>=0)
        error ('Insertion position into existing title must be numeric whole number and >=0')
    end
else
    npos=0;   % zero will be used later to signal that the extra titling is put at the beginning
end

% Produce new output title
t1=make_cellstr(title);
t2=make_cellstr(more_title);

if ~isempty(t1) && ~isempty(t2)
    lt1 = length(title);
    if npos==1
        out_title=[more_title;title];
    elseif npos==lt1+1 || npos==0
        out_title=[title;more_title];
    elseif npos <= lt1
        out_title=[title(1:npos-1);more_title;title(npos:lt1)];
    else
        out_title=[title;repmat({''},npos-lt1-1,1);more_title];
    end
elseif isempty(t1)
    out_title=t2;
elseif isempty(t2)
    out_title=t1;
else
    out_title=t1;
end

%---------------------------------------------------------------------------------
function cout=make_cellstr(c)
% Convert 2D character array cellstr into cellstr for titling purposes

if ischar(c)
    if ~isempty(c)
        cout=cellstr(c);
    else
        cout=cell(0,1);
    end
else
    empty=false(numel(c),1);
    for i=1:numel(c)
        empty(i)=isempty(strtrim(c{i}));
    end
    if ~all(empty)
        cout=c;
    else
        cout=cell(0,1);
    end
end
