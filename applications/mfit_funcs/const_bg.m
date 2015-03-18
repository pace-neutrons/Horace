function y=const_bg(x,p)
% Constant background function
%
%   >> y = const_bg (x,p)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           y = p(1)
%
% Output:
% ========
%   y   Vector of calculated y-axis values - same value for all x values

if ~isscalar(p)
    error('Input parameters must be a single number');
end
    
y=p*ones(size(x));
