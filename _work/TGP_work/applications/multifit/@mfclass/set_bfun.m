function obj = set_bfun(obj,varargin)
% Set background function or functions
%
% Set all background functions
%   >> obj = obj.set_bfun (@fhandle, pin)
%   >> obj = obj.set_bfun (@fhandle, pin, pfree)
%   >> obj = obj.set_bfun (@fhandle, pin, pfree, pbind)
%   >> obj = obj.set_bfun (@fhandle, pin, 'pfree', pfree, 'pbind', pbind)
%
% Set a particular foreground function or set of foreground functions
%   >> obj = obj.set_bfun (ifun, @fhandle, pin,...)    % ifun can be scalar or row vector


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
