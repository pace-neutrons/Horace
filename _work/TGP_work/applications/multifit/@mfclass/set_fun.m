function obj = set_fun(obj,varargin)
% Set foreground function or functions
%
% Set all foreground functions
%   >> obj = obj.set_fun (@fhandle, pin)
%   >> obj = obj.set_fun (@fhandle, pin, free)
%   >> obj = obj.set_fun (@fhandle, pin, free, bind)
%   >> obj = obj.set_fun (@fhandle, pin, 'free', free, 'bind', bind)
%
% Set a particular foreground function or set of foreground functions
%   >> obj = obj.set_fun (ifun, @fhandle, pin,...)    % ifun can be scalar or row vector
%
%
% Form of fit functions
% ----------------------
%           If fitting x,y,e data, or a structure with fields w.x,w.y,w.e,
%           then the function must have the form:
%               ycalc = my_function (x1,x2,...,p)
%
%             or, more generally:
%               ycalc = my_function (x1,x2,...,p,c1,c2,...)
%
%             where
%               - x1,x2,... Arrays of x values along first, second,...
%                          dimensions
%               - p         A vector of numeric parameters that define the
%                          function (e.g. [A,x0,w] as area, position and
%                          width of a peak)
%               - c1,c2,... Any further arguments needed by the function (e.g.
%                          they could be the filenames of lookup tables)
%
%             Type >> help gauss2d  or >> help mexpon for examples
%
%           If fitting objects, then if w is an instance of an object, the
%           function(s) or method(s) must have the form:
%               wcalc = my_function (w,p)
%
%             or, more generally:
%               wcalc = my_function (w,p,c1,c2,...)
%
%             where
%               - w         Object on which to evaluate the function
%               - p         A vector of numeric parameters that define the
%                          function (e.g. [A,x0,w] as area, position and
%                          width of a peak)
%               - c1,c2,... Any further arguments needed by the function (e.g.
%                          they could be the filenames of lookup tables)
%             Type >> help gauss2d  or >> help mexpon for examples


% Check there is data
% -------------------
if isempty(obj.data_)
    if numel(varargin)>0
        error ('Cannot set foreground function(s) before data has been set.')
    else
        return  % no data has been set, so trivial return
    end
end

% Process input
% -------------
isfore = true;
[ok, mess, obj] = set_fun_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
