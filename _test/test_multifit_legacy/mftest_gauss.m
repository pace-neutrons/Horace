function y = mftest_gauss(x, p)
% Gaussian
% 
%   >> y = mftest_gauss(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function:
%           p = [h1, c1, sig1]
%
% Output:
% ========
%   y       Vector of calculated y-axis values

% T.G.Perring

% Simply calculate function at input values
ht=p(1);
cen=p(2);
sig=p(3);
y=ht*exp(-0.5*((x-cen)/sig).^2);
