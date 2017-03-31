function obj = set_global_background(obj,set_global)
% Specify that there will be a global background fit function
%
%   >> obj = obj.set_global_background          % set global background
%   >> obj = obj.set_global_background (status) % set global background true or false
%
% If the scope changes i.e. is altered from global to local, or local to global,
% then the function(s) and any previously set constraints are cleared
%
% See also: set_local_background set_local_foreground set_global_foreground

% <a href="matlab:doc mfclass/set_local_foreground">mfclass/set_local_foreground</a>
% <a href="matlab:doc mfclass/set_local_background">mfclass/set_local_background</a>
% <a href="matlab:doc mfclass/set_global_foreground">mfclass/set_global_foreground</a>

 
% Original author: T.G.Perring 
% 
% $Revision$ ($Date$)


if nargin==1
    set_global = true;
end
isfore = false;
obj = function_set_scope_(obj, isfore, ~set_global);
