function y = slow_func2d (x1, x2, p, funchandle, nslow)
% Evaluate a function but make it much slower 
%
%   >> y = slow_func2d (x1, x2, p, funchandle, nslow)
%
% Input:
% =======
%   x1          Array of values at which to evaluate function along the first
%               dimension
%
%   x2          Array of values at which to evaluate function along the second
%               dimension. Must have the same size as x1
%
%   p           Vector of parameters needed by the function funchandle:
%               E.G. if a two dimensional Gaussian (see gauss2d)
%                   p = [height, x1_0, x2_0, c11, c12, c22]
%
%   funchandle  Handle to function to evaluate e.g. @gauss2d
%               The function can be any function that evaluates in
%               two dimensions with the format expected by multifit
%
% Optionally:
%   nslow       Number of times to run the time_waster function, which
%               alters each calculated value from the function call by a
%               factor <= 10^-13 (regardless of the value of nslow.
%               Each value of nslow takes about the time of 25 
%               exponentiations.
%                   nslow >=0
%               Default if not given: nslow = 1
%
% Output:
% ========
%   y           Array of calculated y-axis values

if nargin==4
    nslow = 1;
else
    nslow = round(nslow);
    if nslow < 0
        nslow = 0;
    end
end
y = funchandle (x1, x2, p);

if nslow > 0
    y = time_waster (y, nslow);
end
