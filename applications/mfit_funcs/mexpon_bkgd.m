function y = mexpon_bkgd(x, p)
% Multiple exponential functions: y = h*exp(-x/d) on linear background
% 
%   >> y = mexpon_bkgd(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   Vector length 2n: [h1,d1,h2,d2,..., bkgd_const, bkgd_slope]
%
% Output:
% ========
%   y       Vector of calculated y-axis values

% T.G.Perring

% Simply calculate function at input values
if rem(length(p),3)==0
    nexp=(length(p)-2)/3;
    ht=p(1:2:end-2);
    d=p(2:2:end-2);
    y=p(end-1)+x*p(end);
    for i=1:nexp
        y=y + ht(i)*exp(-x/d(i));
    end
else
    error ('Check number of parameters')
end
