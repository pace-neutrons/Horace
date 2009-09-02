function wout = func_eval (win, varargin)
% Evaluate a function at the plotting bin centres of d4d object or array of d4d objects
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
%              Function must be of form y = my_func(x1,x2,x3,x4,pars)
%               e.g. y=gauss4d(x1,x2,x3,x4,[ht,x1_0,x2_0,x3_0,x4_0,sig1,sig2,sig3,sig4])
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
%   >> wout = func_eval (w, @gauss4d, [ht,x1_0,x2_0,x3_0,x4_0,sig1,sig2,sig3,sig4])
%
%   where the function appears on the matlab path
%           function y = gauss4d (x1, x2, x3, x4, pars)
%           y = (pars(1)/(sig*sqrt(2*pi))) * ...

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(func_eval(sqw(win),varargin{:}));
