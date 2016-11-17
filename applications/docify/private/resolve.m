function [strout,ok,mess]=resolve(str,substr,val)
% Recursively resolve string substitutions of the form <name>
%
%   >> [strout,ok,mess]=resolve(str,substr,val)
%
% Input:
% ------
%   str     Character string or cellstr in which to make substitutions
%   substr  Cell array of strings of form '<...>' to be substituted
%   val     Cell array of corresponding substitutions
%
% Output:
%   strout  Output string or cellstr
%   ok      True if all OK, false otherwise
%   mess    Error message if not OK (string)
%
% The substitutions are performed recursively until there are no further
% substitutions that can be made, or until the maximum depth permitted has
% been reached.

if ~iscell(substr), substr={substr}; end
if ~iscell(val), val={val}; end

if ~iscell(str)
    [strout,ok,mess]=resolve_str(str,substr,val);
else
    strout=cell(size(str));
    for i=1:numel(str)
        [strout{i},ok,mess]=resolve_str(str{i},substr,val);
        if ~ok, return, end
    end
end

%--------------------------------------------------------------------------------------------------
function [strout,ok,mess]=resolve_str(str,substr,val)
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
    strout=strrep_special(strin,substr,val);
    if strcmp(strout,strin)
        return
    else
        strin=strout;
    end
end
ok=false;
mess=['String substitution exceeds maximum depth of ',num2str(nmax),'. Check not infinite.'];


%--------------------------------------------------------------------------------------------------
function strout=strrep_special(strin,substr,val)
% Substitute all occurences of character strings
% Don't use strrep, as it has a funny dimension expansion I don't want, and
% don't use regexprep as it does not like '\' as this is treated as a control
% character. I want straight replacement.
%
%   strin   Character string in which to make substitutions
%   substr  Cell array of strings of form '<...>' to be substituted
%   val     Cell array of corresponding substitutions

strout=strin;
for i=1:numel(substr)
    strout=strrep(strout,substr{i},val{i});
end
