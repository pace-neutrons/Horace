function obj = add_bbind (obj,varargin)
% Add bindings between parameters for background functions
%
% *** Copy help from set_bind once the help is finalised, with appropriate changes.


% Check there are function(s)
% ---------------------------
if numel(obj.bfun_)==0
    error ('Cannot bind background function parameters because the functions have not been set.')
end

% Process input
% -------------
isfore = false;
[ok, mess, obj] = add_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
