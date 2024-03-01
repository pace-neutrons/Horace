function y = linear_bkgd_sqw(h,~,~,~, p)
% Straight line
% 
%   >> y = linear_bkgd(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function:
%           p = [const, grad]
%
% Output:
% ========
%   y       Vector of calculated y-axis values

% T.G.Perring

% Simply calculate function at input values

y=ones(size(h))*p(1);
