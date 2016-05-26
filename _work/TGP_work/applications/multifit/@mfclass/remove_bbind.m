function obj = remove_bbind (obj, ifun)
% Remove bindings between parameters for background functions
%
%   >> obj = obj.remove_bbind           % clear all binding
%   >> obj = obj.remove_bbind (ifun)    % clear bindings for indicated function(s)


% Check there are function(s)
% ---------------------------
if numel(obj.bfun_)==0
    error ('Cannot clear bindings of background function(s) because the functions have not been set.')
end

% Process input
% -------------
if nargin==1, ifun = []; end
isfore = false;
[ok, mess, obj] = remove_bind_private_ (obj, isfore, ifun);
if ~ok, error(mess), end
