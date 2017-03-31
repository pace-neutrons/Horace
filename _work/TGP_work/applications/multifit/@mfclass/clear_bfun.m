function obj = clear_bfun(obj, varargin)
% Clear background function(s), clearing any corresponding constraints
%
% Clear all background functions
%   >> obj = obj.clear_bfun
%
% Clear a particular background function or set of background functions
%   >> obj = obj.clear_bfun (ifun)

 
% Original author: T.G.Perring 
% 
% $Revision$ ($Date$)


% Check there are function(s)
% ---------------------------
if isempty(obj.bfun_)
    if numel(varargin)>0
        error ('Cannot clear background function(s) before they have been set.')
    else
        return  % no data has been set, so trivial return
    end
end

% Process input
% -------------
isfore = false;
[ok, mess, obj] = clear_fun_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
