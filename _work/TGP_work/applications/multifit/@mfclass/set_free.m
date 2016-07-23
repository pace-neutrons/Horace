function obj = set_free (obj, varargin)
% Set which foreground function parameters are free and which are bound
%
% Set for all foreground functions
%   >> obj = obj.set_free (pfree)
%
% Set for one or more specific foreground function(s)
%   >> obj = obj.set_free (ifun, pfree)
%
% Input:
% ------
%   pfree   Logical row vector (or array of ones and zeros)

% Check there are function(s)
% ---------------------------
if isempty(obj.fun_)
    if numel(varargin)>0
        error ('Cannot set free/fixed status of foreground function(s) before they have been set.')
    else
        return  % no data has been set, so trivial return
    end
end

% Process input
% -------------
isfore = true;
[ok, mess, obj] = set_free_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
