function obj = set_bfun(obj,varargin)
% Set background function or functions
%
% Set all background functions
%   >> obj = obj.set_bfun (@fhandle, pin)
%   >> obj = obj.set_bfun (@fhandle, pin, free)
%   >> obj = obj.set_bfun (@fhandle, pin, free, bind)
%   >> obj = obj.set_bfun (@fhandle, pin, 'free', free, 'bind', bind)
%
% Set a particular foreground function or set of foreground functions
%   >> obj = obj.set_bfun (ifun, @fhandle, pin,...)    % ifun can be scalar or row vector

 
% Original author: T.G.Perring 
% 
% $Revision$ ($Date$)


% Check there is data
% -------------------
if isempty(obj.data_)
    if numel(varargin)>0
        error ('Cannot set background function(s) before data has been set.')
    else
        return  % no data has been set, so trivial return
    end
end

% Process input
% -------------
isfore = false;
[ok, mess, obj] = set_fun_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
