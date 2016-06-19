function obj = add_bind (obj,varargin)
% Add bindings between parameters for foreground functions
%
% *** Copy help from set_bind once the help is finalised, with appropriate changes.


% Check there are function(s)
% ---------------------------
if isempty(obj.fun_)
    if numel(varargin)>0
        error ('Cannot bind foreground function parameters before the functions have been set.')
    else
        return  % no data has been set, so trivial return
    end
end

% Process input
% -------------
isfore = true;
[ok, mess, obj] = add_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
