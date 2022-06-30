function [w, tmax, tlo, thi] = delta_function_pulse_width2 (pp, frac, ei)
% Calculate pulse width quantities (microseconds)
%
%   >> [w, tmax, tlo, thi] = delta_function_pulse_width2 (pp, frac, ei)
%
% Input:
% -------
%   pp          Parameters for delta function. Empty array []
%   frac        Fraction of peak height at which to determine the width
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   w           Width across the peak (microseconds)
%   tlo         Short time fractional height (microseconds)
%   thi         High time fractional height (microseconds)


w = zeros(size(ei));
tmax = zeros(size(ei));
tlo = zeros(size(ei));
thi = zeros(size(ei));

end
