function y = example_1d_function(x, p)
% Example fitting function: Gaussian function
%
% A one-dimensional fit function must have the form:
% 	ycalc = my_function (x,p)
%
% or, more generally:
% 	ycalc = my_function (x1,x2,...,p,c1,c2,...)
%
% where
%  	x           Array of x valuesdimensions
%   p           A vector of numeric parameters that define the
%              function (e.g. [A,x0,w] as area, position and
%              width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
% See also mgauss linear_bg
%
% -------------------------------------------------------------------------
% In this example:
%   >> y = gauss(x,p)
%
% Input:
% =======
%   x   Array of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [height, centre, st_deviation]
%
% Output:
% ========
%   y   Array of calculated y-axis values


% T.G.Perring

y = p(1) * exp(-0.5*((x-p(2))/p(3)).^2);
