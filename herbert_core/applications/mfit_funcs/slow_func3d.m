function y = slow_func3d (x1, x2, x3, p, funchandle, nslow)
% Evaluate a function but make it much slower 
%
%   >> y = slow_func3d (x1, x2, x3, p, funchandle, nslow)
%
% Input:
% =======
%   x1          Array of values at which to evaluate function along the first
%               dimension
%
%   x2          Array of values at which to evaluate function along the second
%               dimension. Must have the same size as x1
%
%   x3          Array of values at which to evaluate function along the third
%               dimension. Must have the same size as x1
%
%   p           Vector of parameters needed by the function funchandle:
%               E.G. if a two dimensional Gaussian (see gauss3d)
%                   p = [height, x1_0, x2_0, x3_0, c11, c12, c13, c22, c23, c33]
%
%   funchandle  Handle to function to evaluate e.g. @gauss3d
%               The function can be any function that evaluates in
%               three dimensions with the format expected by multifit
%
% Optionally:
%   nslow       Number of times to run the time_waster function, which
%               alters each calculated value from the function call by a
%               factor <= 10^-13 (regardless of the value of nslow.
%               Each value of nslow takes about the time of 25 
%               exponentiations per data point.
%                   nslow >=0
%               Default if not given: nslow = 1
%
% Output:
% ========
%   y           Array of calculated y-axis values

if nargin==5
    nslow = 1;
end
y = funchandle (x1, x2, x3, p);
y = time_waster (y, nslow);
