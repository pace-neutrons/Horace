function obj = clear_free (obj, varargin)
% Clear all parameters to be free in fits for one or more foreground functions
%
% Clear for all foreground functions
%   >> obj = obj.clear_free
%
% Clear for one or more specific foreground function(s)
%   >> obj = obj.clear_free (ifun)


% Check there are function(s)
% ---------------------------
if isempty(obj.fun_)
    if numel(varargin)>0
        error ('Cannot set free/fixed status of foreground function(s) before they have been set.')
    else
        return  % no functions have been set, so trivial return
    end
end

% Process input
% -------------
isfore = true;
[ok, mess, obj] = clear_free_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
