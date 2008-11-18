function y = test_gauss_bkgd_cell (x, p, scale)
% Gaussian on linear background, with additional intensity scale parameter to test cell input to fit
% 
%   >> y = gauss(x,p,scale)
%   >> [y, name, pnames, pin] = gauss(x,p,scale)
%
% Input:
% =======
%   x       vector of x-axis values at which to evaluate function
%   p       vector or parameters needed by the function:
%               p = [height, centre, st_deviation, bkgd_const, bkgd_slope]
%   scale   scale parameter on Gaussian height

%
% Output:
% ========
%   y       Vector of calculated y-axis values


% T.G.Perring


% Simply calculate function at input values
y=scale*p(1)*exp(-0.5*((x-p(2))/p(3)).^2) + (p(4)+x*p(5));
