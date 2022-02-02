function [y,t] = delta_function_pulse_shape (pp, t)
% Return normalised pulse width function
%
%   >> [y,t] = delta_function_pulse_shape (pp, t)
%
% Input:
% -------
%   pp          Parameters for delta function. Empty array []
%
%   t           Array of times at which to evaluate pulse shape (microseconds)
%               If empty, uses a suitable set of points. In this case, being
%               a delta function, the choice of values is trhe single case
%               of t = 0.
%
% Output:
% -------
%   y           Pulse shape. Normalised so pulse has unit area
%               Note that because the pulse shape is a delta function, y
%               takes the value zero except if t = 0, when it is +Inf.
%
%   t           If input was not empty, same as imput argument
%               If input was empty, the default set of points


if isempty(t)
    t = 0;
    y = Inf;
else
    y = zeros(size(t));
    y(t==0) = Inf;
end

end
