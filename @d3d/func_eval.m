function wout = func_eval (win, varargin)
% Evaluate a function at the plotting bin centres of d3d object or array of d3d objects
% Syntax:
%   >> wout = func_eval (win, func_handle, pars)
%   >> wout = func_eval (win, func_handle, pars, 'all')
%
% Input:
% ======
%   win         Dataset or array of datasets; the function will be evaluated
%              at the bin centres along the plot axes
%
%   func_handle Handle to the function to be evaluated at the bin centres
%               Must have form:
%                   y = my_function (x1,x2,x3,pars)
%
%               or, more generally:
%                   y = my_function (x1,x2,x3,pars,c1,c2,...)
%
%               - x1,x2,x3  Arrays of x coordinates along each of the 3 dimensions
%               - pars      Parameters needed by the function
%               - c1,c2,... Any further arguments needed by the function e.g.
%                          they could be the filenames of lookup tables for
%                          resolution effects)
%
%               e.g. y=gauss3d(x1,x2,x3,[ht,x0,sig1,sig2,sig3])
%
%   pars        Arguments needed by the function. 
%                - Most commonly just a numeric array of parameters
%                - If a more general set of parameters is needed by the function, then
%                  wrap as a cell array {pars, c1, c2, ...}
%
%   'all'       [option] Requests that the calculated function be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%               Applies only to input with no pixel information - it is ignored if
%              full sqw object.
%
% Output:
% =======
%   wout        Output object or array of objects 
%
% e.g.
%   >> wout = func_eval (w, @gauss3d, [ht,x1_0,x2_0,x3_0,sig1,sig2,sig3]])
%
%   where the function appears on the matlab path
%           function y = gauss3d (x1, x2, x3, pars)
%           y = (pars(1)/(sig*sqrt(2*pi))) * ...

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(func_eval(sqw(win),varargin{:}));
