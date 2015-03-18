function y=quad_bg(x,p)
% Quadratic background function
%
%   >> y = quad_bg (x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           y = p(1) + p(2)*x + p(3)*x.^2
%
% Output:
% ========
%   y   Vector of calculated y-axis values

if length(p)~=3
    error('Input parameters must be a vector of length 3');
end
    
y=p(1) + p(2)*x + p(3)*(x.^2);
