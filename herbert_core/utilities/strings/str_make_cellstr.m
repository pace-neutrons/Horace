function [ok,cout]=str_make_cellstr(varargin)
% Take a set of arguments and try to make a cellstr of strings from the contents
%
%   >> [ok,cout] = str_make_cellstr(c1,c2,c3,...)
%
% Input:
% ------
%   c1,c2,c3,...    Two-dimensional character arrays or cell arrays of strings
%
% Output:
% -------
%   ok              =true if valid input (could all be empty)
%   cout            Column vector cellstr
%                  Trailing whitespace is removed from all strings
%                 (This is for consistency with what cellstr(str) does


narg=numel(varargin);

% Get number of strings
n=zeros(narg,1);
for i=1:narg
    if iscellstr(varargin{i})
        n(i)=numel(varargin{i});
    elseif ischar(varargin{i}) && numel(size(varargin{i}))==2
        if ~isempty(varargin{i})
            n(i)=size(varargin{i},1);
        else
            n(i)=numel(cellstr(varargin{i}));   % so the empty string is stored
        end
    else
        ok=false;
        cout=cell(0,1);
        return
    end
end

% Fill up output cellstr
nend=cumsum(n);
nbeg=nend-n+1;
if nend(end)>0
    cout=cell(nend(end),1);
    for i=1:narg
        if iscellstr(varargin{i})
            cout(nbeg(i):nend(i))=deblank(varargin{i});
        else
            cout(nbeg(i):nend(i))=cellstr(varargin{i});
        end
    end
else
    cout=cell(0,1);
end

ok=true;
