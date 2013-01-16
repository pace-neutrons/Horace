function y = mlorentzian_bkgd(x, p)
% Multple Lorentzians on linear background
% 
%   >> y = mlorentzian_bkgd(x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [h1, c1, gam1, h2, c2, gam2, ..., bkgd_const, bkgd_slope]
%
% Output:
% ========
%   y   Vector of calculated y-axis values

% T.G.Perring

% Simply calculate function at input values
if rem(length(p),3)==2
    nlor=(length(p)-2)/3;
    ht=p(1:3:end-2);
    cen=p(2:3:end-2);
    gam=p(3:3:end-2);
    y=p(end-1)+x*p(end);
    for i=1:nlor
        y=y + (ht(i)*gam(i)^2)./((x-cen(i)).^2+gam(i)^2);
    end
else
    error ('Check number of parameters')
end
