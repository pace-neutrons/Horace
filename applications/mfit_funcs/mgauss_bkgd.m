function y = mgauss_bkgd(x, p)
% Multple Gaussians on linear background
% 
%   >> y = mgauss_bkgd(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function:
%           p = [h1, c1, sig1, h2, c2, sig2, ..., bkgd_const, bkgd_slope]
%
% Output:
% ========
%   y       Vector of calculated y-axis values

% T.G.Perring

% Simply calculate function at input values
if rem(length(p),3)==2
    ngauss=(length(p)-2)/3;
    ht=p(1:3:end-2);
    cen=p(2:3:end-2);
    sig=p(3:3:end-2);
    y=p(end-1)+x*p(end);
    for i=1:ngauss
        y=y + ht(i)*exp(-0.5*((x-cen(i))/sig(i)).^2);
    end
else
    error ('Check number of parameters')
end
