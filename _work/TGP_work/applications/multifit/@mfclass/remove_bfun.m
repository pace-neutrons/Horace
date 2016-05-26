function obj = remove_bfun(obj,ifun)
% Remove background function(s), clearing any corresponding constraints
%
% Remove all background functions
%   >> obj = obj.remove_bfun
%
% Remove a particular background function or set of background functions
%   >> obj = obj.remove_bfun (ifun)


% Check there are function(s)
% ---------------------------
if numel(obj.bfun_)==0
    error ('Cannot remove background function(s) before they have been set.')
end

% Process input
% -------------
if nargin==1, ifun = []; end
isfore = false;
[ok, mess, obj] = remove_fun_private_ (obj, isfore, ifun);
if ~ok, error(mess), end
