function y=polynomial(x,p)
% Quadratic background function
%
%   >> y = polynomial (x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           y = p(1) + p(2)*x + p(3)*x.^2 + ...
%       The order of th polynomial is determined by the length of p.
%
% Output:
% ========
%   y   Vector of calculated y-axis values

n=numel(p);
if n>=1
    y=p(n)*ones(size(x));
    for i=n-1:-1:1
        y=x.*y+p(i);
    end
else
    error('Input parameters must be a vector of length greater or equal to 1');
end
