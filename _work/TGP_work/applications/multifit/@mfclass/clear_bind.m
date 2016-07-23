function obj = clear_bind (obj, varargin)
% Clear bindings between parameters for foreground functions
%
%   >> obj = obj.clear_bind            % clear all bindings
%   >> obj = obj.clear_bind (ifun)     % clear bindings for indicated function(s)


% Check there are function(s)
% ---------------------------
if isempty(obj.fun_)
    if numel(varargin)>0
        error ('Cannot clear bindings of foreground function(s) before the functions have been set.')
    else
        return  % no data has been set, so trivial return
    end
end

% Process input
% -------------
isfore = true;
[ok, mess, obj] = clear_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
