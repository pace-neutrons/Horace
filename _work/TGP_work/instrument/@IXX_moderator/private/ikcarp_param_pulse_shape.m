function [y,t] = ikcarp_param_pulse_shape (pp, ei, t)
% Calculate normalised Ikeda-Carpenter function
%
%   >> y = ikcarp_param_pulse_shape (pp, ei, t)
%
% Input:
% -------
%   pp          Arguments for parametrised Ikeda-Carpenter moderator
%                   p(1)    Effective distance (m) of for computation
%                          of FWHH of Chi-squared function at Ei
%                          (Typical value 0.03 - 0.06; theoretically 0.028
%                           for hydrogen)
%                   p(2)    Slowing down decay time (microseconds) 
%                          (Typical value 25)
%                   p(3)    Characteristic energy for swapover to storage
%                          (Typical value is 200meV)
%
%   ei          Incident energy (meV) (scalar)
%
%   t           Array of times at which to evaluate pulse shape (microseconds)
%               If empty, uses a suitable set of points
%
% Output:
% -------
%   y           Height of pulse shape. Normalised so pulse has unit area
%
%   t           If input was not empty, same as imput argument
%               If input was empty, the default set of points


[tauf, taus, R] = ikcarp_param_convert (pp, ei);
if isempty(t)
    npnt = 500;
    t = ikcarp_pdf_xvals (npnt, tauf, taus);
end
y = ikcarp (t, tauf, taus, R);
