function isit=isfield(this,fieldName)
% function checks if the field(s) 'fieldName' is(are) the public field(s)
% of the class this. 
% *** > cell array of fields is not tested but may work
%
% It is overload of mathab function isfield for class this
%
%
% $Revision$ ($Date$)
%
names=fields(this);
is_it = ismember(names,fieldName);
if any(is_it)>0
    isit = true;
else
    isit = false;    
end
