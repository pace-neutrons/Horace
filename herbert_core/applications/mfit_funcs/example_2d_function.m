function y = example_2d_function(x1, x2, p)
% Example fitting function two dimensions
% -------------------------------------------------------------------------
% A two-dimensional fit function must have the form:
%
% 	>> ycalc = my_function (x1,x2,p)
%
% More generally:
% 	>> ycalc = my_function (x1,x2,p,c1,c2,...)
%
% where
%  	x1, x2      Arrays of x values, x1 containing the values of the 
%              coordinates along the first dimension, and x2 containing
%              the values along the second dimension.
%   p           A vector of numeric parameters that define the
%              function (e.g. [A, x1_0, x2_0, w] as area, position and
%              width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
% See also planar_bg
%
% -------------------------------------------------------------------------
% This example is a two-dimensional Gaussian:
% 
%   >> y = gauss2d(x1,x2,p)
%
%  For each data point
%       y = h * exp(-1/2 * [dx1,dx2].*cov^-1.*[dx1;dx2])
%   where
%       dx1 = x1-x1_0
%       dx2 = x2-x2_0
%   
%       cov = [c11, c12; c12, c22]  i.e. covariance matrix
%               (c11 is the variance of x1, c22 is the variance of x2
%               and c12/sqrt(c11*c22) is the correlation between x1 and x2).
%
% Input:
% =======
%   x1  Array of values at which to evaluate function along the first
%      dimension
%   x2  Array of values at which to evaluate function along the second
%      dimension. Must have the same size as x1.
%   p   Vector of parameters needed by the function:
%           p = [height, x1_0, x2_0, c11, c12, c22]
%
% Output:
% ========
%   y   Array of calculated y-axis values. Same size as x1.


% T.G.Perring

ht=p(1); x1_0=p(2); x2_0=p(3);
c11=p(4); c12=p(5); c22=p(6);

det = c11*c22-c12^2;
m11 = c22/det;
m12 = -c12/det;
m22 = c11/det;

dx1 = x1-x1_0;
dx2 = x2-x2_0;

y = ht*exp(-0.5*(m11*dx1.^2 + 2*m12*(dx1.*dx2) + m22*dx2.^2));
