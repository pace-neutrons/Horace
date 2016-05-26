function obj = add_bind (obj,varargin)
% Add bindings between parameters for foreground functions
%
% *** Copy help from set_bind once the help is finalised, with appropriate changes.


% Check there are function(s)
% ---------------------------
if numel(obj.fun_)==0
    error ('Cannot bind foreground function parameters because the functions have not been set.')
end

% Process input
% -------------
isfore = true;
[ok, mess, obj] = add_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
