function obj = set_bbind (obj,varargin)
% Set bindings between parameters for background functions
%
% *** Copy help from set_bind once the help is finalised, with appropriate changes.


% Check there are function(s)
% ---------------------------
if numel(obj.bfun_)==0
    error ('Cannot bind background function parameters before the functions have been set.')
end

% Process input
% -------------
isfore = false;

% Clear all bindings first
[ok, mess, obj] = remove_bind_private_ (obj, isfore, []);
if ~ok, error(mess), end

% Add new bindings
[ok, mess, obj] = add_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
