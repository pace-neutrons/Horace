function obj = set_global_foreground(obj,set_global)
% Specify that there will be a global foreground fit function
%
%   >> obj = obj.set_global_foreground          % set global foreground
%   >> obj = obj.set_global_foreground (status) % set global foreground true or false
%
% If the scope changes i.e. is altered from global to local, or local to global,
% then the function(s) and any previously set constraints are cleared
%
% See also:
% <a href="matlab:doc mfclass/set_local_foreground">mfclass/set_local_foreground</a>
% <a href="matlab:doc mfclass/set_local_background">mfclass/set_local_background</a>
% <a href="matlab:doc mfclass/set_global_background">mfclass/set_global_background</a>

if nargin==1
    set_global = true;
end
isfore = true;
obj = function_set_scope_(obj, isfore, ~set_global);
