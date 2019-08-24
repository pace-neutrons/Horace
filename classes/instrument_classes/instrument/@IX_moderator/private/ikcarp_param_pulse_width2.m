function [width, tlo, thi] = ikcarp_param_pulse_width2 (pp, ei)
% Calculate st. dev. of moderator pulse width distribution (microseconds)
%
%   >> [width, tlo, thi] = ikcarp_param_pulse_width2 (pp,frac,ei)
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
%                   p(3)    Characteristic energy for swap-over to storage
%                          (Typical value is 200meV)
%   frac        Fraction of peak height at which to determine the width
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   width       Width across the peak (microseconds)
%   tlo         Short time fractinal height (microseconds)
%   thi         High time fractinal height (microseconds)


[tauf, taus, R] = ikcarp_param_convert (pp, ei);

width=zeros(size(ei));
tlo=zeros(size(ei));
thi=zeros(size(ei));
for i=1:numel(ei)
    [width(i), ~, tlo(i), thi(i)] = pulse_width_ikcarp ([tauf(i),taus(i),R(i)], ei(i));
end
