function y = test_gauss(x, p)
% Gaussian
% 
%   >> y = test_gauss(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function:
%           p = [height, centre, st_deviation]
%
% Output:
% ========
%   y       Vector of calculated y-axis values


% T.G.Perring


y=p(1)*exp(-0.5*((x-p(2))/p(3)).^2);
