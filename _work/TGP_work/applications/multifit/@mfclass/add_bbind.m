function obj = add_bbind (obj,varargin)
% Add bindings between parameters for background functions
%
% *** Copy help from set_bind once the help is finalised, with appropriate changes.


% Check there are function(s)
% ---------------------------
if isempty(obj.bfun_)
    if numel(varargin)>0
        error ('Cannot bind background function parameters before the functions have been set.')
    else
        return  % no data has been set, so trivial return
    end
end


% Process input
% -------------
isfore = false;
[ok, mess, obj] = add_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
