function [dt, t_av, fwhh] = delta_function_pulse_width (pp, ei)
% Calculate pulse width quantities (microseconds)
%
%   >> [dt, t_av, fwhh] = delta_function_pulse_width (pp, ei)
%
% Input:
% -------
%   pp          Parameters for delta function. Empty array []
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   dt          Standard deviation of pulse width (microseconds)
%   t_av        First moment (microseconds)
%   fwhh        Full width half height (microseconds)
%
% All these widths are returned as zero because the pulse is a delta
% function


dt = zeros(size(ei));
t_av = zeros(size(ei));
fwhh = zeros(size(ei));

end
