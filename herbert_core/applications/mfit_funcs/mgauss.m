function y = mgauss(x, p)
% Multiple Gaussians
% 
%   >> y = mgauss(x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [h1, c1, sig1, h2, c2, sig2, ...]
%
% Output:
% ========
%   y   Vector of calculated y-axis values

% T.G.Perring

if rem(length(p),3)==0
    ngauss=length(p)/3;
    ht=p(1:3:end);
    cen=p(2:3:end);
    sig=p(3:3:end);
    y=zeros(size(x));
    for i=1:ngauss
        y=y + ht(i)*exp(-0.5*((x-cen(i))/sig(i)).^2);
    end
else
    error ('Check number of parameters')
end
