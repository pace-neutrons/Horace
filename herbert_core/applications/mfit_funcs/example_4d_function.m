function y = example_4d_function(x1, x2, p)
% Example fitting function four dimensions
% -------------------------------------------------------------------------
% A four-dimensional fit function must have the form:
%
% 	>> ycalc = my_function (x1,x2,x3,x4,p)
%
% More generally:
% 	>> ycalc = my_function (x1,x2,x3,x4,p,c1,c2,...)
%
% where
%  	x1,...x4    Arrays of x values, x1 containing the values of the 
%              coordinates along the first dimension, x2 containing
%              the values along the second dimension etc. All arrays
%              are assumed to have the same size.
%   p           A vector of numeric parameters that define the
%              function (e.g. [A, x1_0, x2_0, x3_0, x4_0, w] as area,
%              position and width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
% See also linear4D_bg
%
% -------------------------------------------------------------------------
% This example is a four-dimensional Gaussian:
% 
%   >> y = gauss4d (x1, x2, s3, x4, p)
%
%  For each data point
%       y = h * exp(-1/2 * [dx1,dx2,dx3].*cov^-1.*[dx1;dx2;dx3])
%   where
%       dx1 = x1-x1_0
%       dx2 = x2-x2_0
%       dx3 = x3-x3_0
%       dx3 = x4-x4_0
%   
%       cov = Covariance matrix, a 3x3 matrix
%               (c11 is the variance of x1, c22 is the variance of x2
%               and c12/sqrt(c11*c22) is the correlation between x1 and x2).
%
% Input:
% =======
%   x1  Array of values at which to evaluate function along the first
%      dimension
%   x2  Array of values at which to evaluate function along the second
%      dimension. Must have the same size as x1
%   x3  Array of values at which to evaluate function along the third
%      dimension. Must have the same size as x1
%   x4  Array of values at which to evaluate function along the first
%      dimension. Must have the same size as x1
%   p   Vector of parameters needed by the function:
%           p = [height, x1_0, x2_0, x3_0, x4_0,...
%                   c11, c12, c13, c14, c22, c23, c24, c33, c34, c44]
%
% Output:
% ========
%   y   Array of calculated y-axis values. Same size as x1.


% T.G.Perring

ht=p(1); x1_0=p(2); x2_0=p(3); x3_0=p(4); x4_0=p(5);
c11=p(6); c12=p(7); c13=p(8); c14=p(9);
c22=p(10); c23=p(11); c24=p(12);
c33=p(13); c34=p(14); c44=p(15);

m = inv([c11, c12, c13, c14; c12, c22, c23, c24;...
    c13, c23, c33, c34; c14, c24, c34, c44]);

dx1 = x1-x1_0;
dx2 = x2-x2_0;
dx3 = x3-x3_0;
dx4 = x4-x4_0;

y = ht*exp(-0.5*( m(1,1)*dx1.^2 + m(2,2)*dx2.^2 + m(3,3)*dx3.^2 + m(4,4)*dx4.^2 +...
    2*m(1,2)*(dx1.*dx2) + 2*m(1,3)*(dx1.*dx3) + 2*m(1,4)*(dx1.*dx4) +...
    2*m(2,3)*(dx2.*dx3) + 2*m(2,4)*(dx2.*dx4) + 2*m(3,4)*(dx3.*dx4)));
