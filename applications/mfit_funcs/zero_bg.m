function y=zero_bg(x,p)
% Zero background function - returns zero for all x values
%
%   >> y = zezro_bg (x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function. Contents ignored
%       (can be an empty object)
%
% Output:
% ========
%   y   Vector of calculated y-axis values - all zeros

y=zeros(size(x));
