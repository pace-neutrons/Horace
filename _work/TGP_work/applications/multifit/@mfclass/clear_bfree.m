function obj = clear_bfree (obj, varargin)
% Clear all parameters to be free in fits for one or more background functions
%
% Clear for all background functions
%   >> obj = obj.clear_bfree
%
% Clear for one or more specific background function(s)
%   >> obj = obj.clear_bfree (ifun)


% Check there are function(s)
% ---------------------------
if isempty(obj.bfun_)
    if numel(varargin)>0
        error ('Cannot set free/fixed status of background function(s) before they have been set.')
    else
        return  % no functions been set, so trivial return
    end
end

% Process input
% -------------
isfore = false;
[ok, mess, obj] = clear_free_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
