function obj = set_free (obj, varargin)
% Set which foreground function parameters are free and which are bound
%
% Set for all foreground functions
%   >> obj = obj.set_free           % All parameters set to free
%   >> obj = obj.set_free (pfree)   % Row vector (applies to all) or cell array (one per function)
%
% Set for one or more specific foreground function(s)
%   >> obj = obj.set_free (ifun)
%   >> obj = obj.set_free (ifun, pfree)


% Check there are function(s)
% ---------------------------
if numel(obj.fun_)==0
    error ('Cannot set free/fixed status of foreground function(s) before they have been set.')
end

% Process input
% -------------
isfore = true;
[ok, mess, obj] = set_free_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
