function y = slow_func1d (x, p, funchandle, nslow)
% Evaluate a function but make it much slower 
%
%   >> y = slow_func1d (x, p, funchandle, nslow)
%
% Input:
% =======
%   x           Array of values at which to evaluate function along the first
%               dimension
%
%   p           Vector of parameters needed by the function funchandle:
%               E.G. if a two dimensional Gaussian (see gauss)
%                   p = [height, centre, st_deviation]
%
%   funchandle  Handle to function to evaluate e.g. @gauss
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

if nargin==3
    nslow = 1;
else
    nslow = round(nslow);
    if nslow < 0
        nslow = 0;
    end
end
y = funchandle (x, p);

if nslow > 0
    y = time_waster (y, nslow);
end
