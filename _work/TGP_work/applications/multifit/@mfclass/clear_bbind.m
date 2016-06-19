function obj = clear_bbind (obj, ifun)
% Clear bindings between parameters for background functions
%
%   >> obj = obj.clear_bbind           % clear all binding
%   >> obj = obj.clear_bbind (ifun)    % clear bindings for indicated function(s)


% Check there are function(s)
% ---------------------------
if isempty(obj.bfun_)
    if numel(varargin)>0
        error ('Cannot clear bindings of background function(s) before the functions have been set.')
    else
        return  % no data has been set, so trivial return
    end
end

% Process input
% -------------
if nargin==1, ifun = []; end
isfore = false;
[ok, mess, obj] = clear_bind_private_ (obj, isfore, ifun);
if ~ok, error(mess), end
