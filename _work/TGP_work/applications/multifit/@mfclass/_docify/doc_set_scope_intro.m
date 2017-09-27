% Description of function syntax for setting blobal or local scope
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type  = '#1'    % 'back' or 'fore'
%   scope = '#2'    % 'global' or 'local'
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Specify that there will be a <scope> <type>ground fit function
%
%   >> obj = obj.set_<scope>_<type>ground          % set <scope> <type>ground
%   >> obj = obj.set_<scope>_<type>ground (status) % set <scope> <type>ground true or false
%
% If the scope changes i.e. is altered from global to local, or local to global,
% then the <type>ground fit functions and any previously set constraints are
% cleared
% <#doc_end:>
% -----------------------------------------------------------------------------
