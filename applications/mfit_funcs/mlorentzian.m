function y = mlorentzian(x, p)
% Multiple Lorentzians
% 
%   >> y = mlorentzian(x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [h1, c1, gam1, h2, c2, gam2, ...]
%
% Output:
% ========
%   y   Vector of calculated y-axis values

% T.G.Perring

% Simply calculate function at input values
if rem(length(p),3)==0
    nlor=length(p)/3;
    ht=p(1:3:end);
    cen=p(2:3:end);
    gam=p(3:3:end);
    y=zeros(size(x));
    for i=1:nlor
        y=y + (ht(i)*gam(i)^2)./((x-cen(i)).^2+gam(i)^2);
    end
else
    error ('Check number of parameters')
end
