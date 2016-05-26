function obj = set_bind (obj,varargin)
% Set bindings between parameters for foreground functions
%
% Single binding description:
%   >> obj = obj.set_bind ( [ip_bind, ifun_bind], [ip, ifun])
%   >> obj = obj.set_bind ( [ip_bind, ifun_bind], [ip, ifun], ratio)
%
% Multiple binding descriptions: (can be a single cell array too)
%   >> obj = obj.set_bind ( {[ip_bind, ifun_bind], [ip, ifun], ratio}, {...}, ...)
%
% Binding descritions for one or more specific bound functions: (cell array only)
%   >> obj = obj.set_bind (ifun_bind, {ip_bind, [ip, ifun], ratio}, {...}, ...)
%
% In full:
% --------
%   >> obj = obj.set_bind (b1, b2, ...)
%   >> obj = obj.set_bind (ifun_bind, b1, b2, ...)
%
% where b1, b2, ... are binding descriptors. Each binding descriptor is a
% cell array with the general form:
%
%       { [ip_bind, ifun_bind], [ip, ifun] }
% *OR*  { [ip_bind, ifun_bind], [ip, ifun], ratio }
%
% where
%     [ip_bind, ifun_bind]      Parameter index and function index of the
%                              foreground parameter to be bound
%     [ip, ifun]                Parameter index and function index of the
%                              parameter to which the above parameter is bound
%                              The function index is positive for foreground
%                              functions, negative for background functions.
%     ratio                     Ratio of bound parameter value to floating
%                              parameter. If not given, or ratio=NaN, then the
%                              value is set from the initial parameter values
%
% If one or both of the function indicies are omitted, then the binding
% descriptors can have more general interpretations that make it simple
% to specify binding across many functions:
%
% -  If the function index of the bound parameter is omitted, then it is
%   assumed that the binding applies to all foreground functions i.e. the
%   binding descriptor is applied to each foreground function in turn (this
%   is only relevant if the foreground functions are local)
%       { ip_bind, [ip, ifun] }
%       { ip_bind, [ip, ifun], ratio }
%
% -  If the function index of the floating parameter is omitted, it is assumed
%   to be the same as the bound parameter function index.
%    If the floating parameter index ip is negative, then the
%   function index is taken to be the corresponding background function.
%       { [ip_bind, ifun_bind], ip }
%       { [ip_bind, ifun_bind], ip, ratio }
%
% -  If the function indicies of both the bound and floating parameters are
%   omitted, then it is assumed that the two parameter indicies refer to
%   the same foreground function, and it is applied to every foreground
%   function.
%    If the floating parameter index ip is negative, then the
%   function index is taken to be the corresponding background function.
%       { ip_bind, ip }
%       { ip_bind, ip, ratio }
%
%
% Single descriptor, selected foreground functions:
% -  If only a single binding descriptor is given, then the contents do not
%   need to be entered as a cell array
%     e.g.
%       >> obj = obj.set_bind ( [ip_bind, ifun_bind], [ip, ifun], ratio)
%
% -  One or more bound function indicies can be explicitly given for all
%   the binding descriptors, so that it is no necessary to give them
%   explicitly (although if a binding descriptor does contain a bound
%   function index then this will take precedence)
%    e.g.
%       >> obj = obj.set_bind ( ifun_bind, {ip_bind, [ip, ifun], ratio}, {...}, ...)
%
% EXAMPLES


% Check there are function(s)
% ---------------------------
if numel(obj.fun_)==0
    error ('Cannot bind foreground function parameters before the functions have been set.')
end

% Process input
% -------------
isfore = true;

% Clear all bindings first
[ok, mess, obj] = remove_bind_private_ (obj, isfore, []);
if ~ok, error(mess), end

% Add new bindings
[ok, mess, obj] = add_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
