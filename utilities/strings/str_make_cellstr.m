function [ok,cout]=str_make_cellstr(varargin)
% Take a set of arguments and try to make a cellstr from the contents
%
%   >> [ok,cout] = str_make_cellstr(c1,c2,c3,...)
%
%   c1,c2,c3,...    Two-dimensional character arrays or cell arrays of strings
%   ok              =true if valid input (could all be empty)
%   cout            Column cellstr

cout=[];
ok=true;
for i=1:numel(varargin)
    if iscellstr(varargin{i})
        tmp=varargin{i};
        cout=[cout;tmp(:)];
    elseif ischar(varargin{i}) && numel(size(varargin{i}))==2
        cout=[cout;cellstr(varargin{i})];
    else
        ok=false;
        cout={};
        return
    end
end
