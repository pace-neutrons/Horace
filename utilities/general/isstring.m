function ok=isstring(var)
% true if variable is a character string i.e. 1xn character array (n>=0), or empty character
%
%   >> ok=isstring(var)
%
% Note: if var is empty but has size 1x0 then will return true
%       Also, if empty, will return true

ok=ischar(var) && (isrowvector(var) || isempty(var));
