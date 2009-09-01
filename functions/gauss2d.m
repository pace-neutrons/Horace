function y = gauss2d(x1, x2, p)
% Two-dimensional Gaussian on linear background
% 
%   >> y = gauss2d(x1,x2,p)
%
%  Function has form
%       y = h * exp(-1/2 [dx1 dx2] [sig_11  sig_12]^-1 [dx1] )
%                                  [sig_12  sig_22]    [dx2]
%   where
%       dx1 = x1-x1_0
%       dx2 = x2-x2_0   
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function:
%           p = [height, x1_0, x2_0, sig_11, sig_12, sig_22]
%
% Output:
% ========
%   y       Vector of calculated y-axis values

% T.G.Perring

% Simply calculate function at input values
x1_0=p(2); x2_0=p(3);
c11=p(4); c12=p(5); c22=p(6);
det=c11*c22-c12^2;
m11=c22/det; m12=-c12/det; m22=c11/det;
dx1=x1-x1_0; dx2=x2-x2_0;
y=p(1)*exp(-0.5*(m11*dx1.^2 + 2*m12*(dx1.*dx2) + m22*dx2.^2));
