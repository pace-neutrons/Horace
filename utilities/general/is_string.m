function [ok,n]=is_string(varargin)
% true if variable is a character string i.e. 1xn character array (n>=0), or empty character
%
%   >> ok = is_string (var)             % true or false
%   >> ok = is_string (var1, var2,...)  % logical row vector
%   >> [ok,n] = is_string (...)         % n is number of caharvers (NaN if not a string)
%
% Note: if var is empty but has size 1x0 then will return true
%       Also, if empty, will return true

isstr = @(a)(ischar(a) && ((numel(size(a))==2 && size(a,1)==1) || isempty(a)));

if nargin==1
    ok = isstr(varargin{1});    
    if ok
        n = numel(varargin{1});
    else
        n = NaN;
    end
elseif nargin>1
    ok = cellfun(isstr, varargin);
    n = NaN(size(varargin));
    n(ok) = cellfun(@numel,varargin(ok));
else
    ok = false(1,0);
    n = NaN(1,0);
end
