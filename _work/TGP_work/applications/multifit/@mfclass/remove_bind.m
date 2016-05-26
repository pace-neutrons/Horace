function obj = remove_bind (obj, ifun)
% Remove bindings between parameters for foreground functions
%
%   >> obj = obj.remove_bind            % clear all binding
%   >> obj = obj.remove_bind (ifun)     % clear bindings for indicated function(s)


% Check there are function(s)
% ---------------------------
if numel(obj.fun_)==0
    error ('Cannot clear bindings of foreground function(s) because the functions have not been set.')
end

% Process input
% -------------
if nargin==1, ifun = []; end
isfore = true;
[ok, mess, obj] = remove_bind_private_ (obj, isfore, ifun);
if ~ok, error(mess), end
