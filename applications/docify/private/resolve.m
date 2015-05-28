function [strout,ok,mess]=resolve(str,substr,val)
% Recursively resolve string substitutions of the form <name>
%
%   >> [strout,ok,mess]=resolve(str,substr,val)
%
% Input:
% ------
%   str     Character string in which to make substitutions
%   substr  Cell array of strings of form '<...>' to be substituted
%   val     Cell array of corresponding substitutions
%
% The substitutions are performed recursively until there are no further
% substitutions that can be made, or until the maximum depth permitted has
% been reached.

ok=true;
mess='';
nmax=10;    % deepest nesting that we will allow
strin=str;
for i=1:nmax
    strout=regexprep(strin,substr,val,'ignorecase');
    if strcmp(strout,strin)
        return
    else
        strin=strout;
    end
end
ok=false;
mess=['String substitution exceeds maximum depth of ',num2str(nmax),'. Check not infinite.'];
