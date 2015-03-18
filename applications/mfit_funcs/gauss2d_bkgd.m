function y = gauss2d_bkgd(x1, x2, p)
% Two-dimensional Gaussian on linear background
% 
%   >> y = gauss2d_bkgd(x1,x2,p)
%
%  Function has form
%       y = h * exp(-1/2 * [dx1,dx2].*cov.*[dx1;dx2]) + (b0 + b1*x + b2*x.^2)
%   where
%       dx1 = x1-x1_0
%       dx2 = x2-x2_0
%   
%       cov = [c11, c12; c12, c22]  i.e. covariance matrix
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [height, x1_0, x2_0, c11, c12, c22, b0, b1, b2]
%
% Output:
% ========
%   y   Vector of calculated y-axis values

% T.G.Perring

ht=p(1); x1_0=p(2); x2_0=p(3);
c11=p(4); c12=p(5); c22=p(6);
det=c11*c22-c12^2;
m11=c22/det; m12=-c12/det; m22=c11/det;
b0=p(7); b1=p(8); b2=p(9);
dx1=x1-x1_0; dx2=x2-x2_0;
y=ht*exp(-0.5*(m11*dx1.^2 + 2*m12*(dx1.*dx2) + m22*dx2.^2)) + (b0+b1*x1+b2*x2);
