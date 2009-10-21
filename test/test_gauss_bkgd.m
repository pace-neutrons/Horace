function y = test_gauss_bkgd(x, p)
% Gaussian on linear background
% 
%   >> y = test_gauss_bkgd(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function:
%           p = [height, centre, st_deviation, bkgd_const, bkgd_slope]
%
% Output:
% ========
%   y       Vector of calculated y-axis values


% T.G.Perring


y=p(1)*exp(-0.5*((x-p(2))/p(3)).^2) + (p(4)+x*p(5));
