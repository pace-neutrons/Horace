function obj = clear_fun(obj,ifun)
% Clear foreground function(s), clearing any corresponding constraints
%
% Clear all foreground functions
%   >> obj = obj.clear_fun
%
% Clear a particular foreground function or set of foreground functions
%   >> obj = obj.clear_fun (ifun)


% Check there are function(s)
% ---------------------------
if isempty(obj.fun_)
    if numel(varargin)>0
        error ('Cannot clear foreground function(s) before they have been set.')
    else
        return  % no data has been set, so trivial return
    end
end

% Process input
% -------------
if nargin==1, ifun = []; end
isfore = true;
[ok, mess, obj] = clear_fun_private_ (obj, isfore, ifun);
if ~ok, error(mess), end
