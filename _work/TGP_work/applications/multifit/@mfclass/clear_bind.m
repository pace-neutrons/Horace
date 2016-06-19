function obj = clear_bind (obj, ifun)
% Clear bindings between parameters for foreground functions
%
%   >> obj = obj.clear_bind            % clear all binding
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
if nargin==1, ifun = []; end
isfore = true;
[ok, mess, obj] = clear_bind_private_ (obj, isfore, ifun);
if ~ok, error(mess), end
