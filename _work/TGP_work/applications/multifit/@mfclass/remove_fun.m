function obj = remove_fun(obj,ifun)
% Remove foreground function(s), clearing any corresponding constraints
%
% Remove all foreground functions
%   >> obj = obj.remove_fun
%
% Remove a particular foreground function or set of foreground functions
%   >> obj = obj.remove_fun (ifun)


% Check there are function(s)
% ---------------------------
if numel(obj.fun_)==0
    error ('Cannot remove foreground function(s) before they have been set.')
end

% Process input
% -------------
if nargin==1, ifun = []; end
isfore = true;
[ok, mess, obj] = remove_fun_private_ (obj, isfore, ifun);
if ~ok, error(mess), end
