function wout = func_eval (win, varargin)
% Evaluate a function at the plotting bin centres of d2d object or array of d2d objects
% Syntax:
%   >> wout = func_eval (win, func_handle, pars)
%   >> wout = func_eval (win, func_handle, pars, 'all')
%
% Input:
% ======
%   win         Dataset or array of datasets; the function will be evaluated
%              at the bin centres along the plot axes
%
%   func        Handle to the function to be evaluated
%              Function must be of form y = my_func(x1,x2,pars)
%               e.g. y=gauss2d(x1,x2,[ht,x1_0,x2_0,sig1,sig2])
%              and must accept arrays of the coordinate values of the points
%              along each dimension i.e. one array for each dimension.
%               It returns an array of the function values.
%
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values. If a more general set of parameters,
%              package these into a cell array and pass that as pars.
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
%   >> wout = func_eval (w, @gauss2d, [ht,x1_0,x2_0,sig1,sig2])
%
%   where the function appears on the matlab path
%           function y = gauss2d (x1, x2, pars)
%           y = (pars(1)/(sig*sqrt(2*pi))) * ...

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(func_eval(sqw(win),varargin{:}));
