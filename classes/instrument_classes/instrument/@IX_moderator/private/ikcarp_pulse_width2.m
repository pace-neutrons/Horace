function [width, tlo, thi] = ikcarp_pulse_width2 (pp, frac, ei)
% Calculate pulse width quantities (microseconds)
%
%   >> [width, tlo, thi] = ikcarp_pulse_width2 (pp, frac, ei)
%
% Input:
% -------
%   pp          Arguments for Ikeda-Carpenter moderator
%                   [tauf,taus,R] (times in microseconds)
%   frac        Fraction of peak height at which to determine the width
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   width       Width across the peak (microseconds)
%   tlo         Short time fractional height (microseconds)
%   thi         High time fractional height (microseconds)


[width,~,tlo,thi]=ikcarp_fwhh (pp(1), pp(2), pp(3), frac);
if numel(ei)~=1
    width=width*ones(size(ei));
    tlo=tlo*ones(size(ei));
    thi=thi*ones(size(ei));
end
