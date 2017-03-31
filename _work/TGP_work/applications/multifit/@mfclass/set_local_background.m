function obj = set_local_background(obj,set_local)
% Specify that there will be a local background fit function
%
%   >> obj = obj.set_local_background          % set local background
%   >> obj = obj.set_local_background (status) % set local background true or false
%
% If the scope changes i.e. is altered from global to local, or local to global,
% then the function(s) and any previously set constraints are cleared
%
% See also: set_global_background set_local_foreground set_global_foreground

% See also:
% <a href="matlab:doc mfclass/set_local_foreground">mfclass/set_local_foreground</a>
% <a href="matlab:doc mfclass/set_global_foreground">mfclass/set_global_foreground</a>
% <a href="matlab:doc mfclass/set_global_background">mfclass/set_global_background</a>

 
% Original author: T.G.Perring 
% 
% $Revision$ ($Date$)


if nargin==1
    set_local = true;
end
isfore = false;
obj = function_set_scope_(obj, isfore, set_local);
