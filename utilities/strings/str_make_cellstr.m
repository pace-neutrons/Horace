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

cout=[];
ok=true;
for i=1:numel(varargin)
    if iscellstr(varargin{i})
        tmp=deblank(varargin{i});
        cout=[cout;tmp(:)];
    elseif ischar(varargin{i}) && numel(size(varargin{i}))==2
        cout=[cout;cellstr(varargin{i})];
    else
        ok=false;
        cout={};
        return
    end
end
