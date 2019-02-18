function [dt, t_av, fwhh] = ikcarp_param_pulse_width (pp, ei)
% Calculate st. dev. of moderator pulse width distribution (microseconds)
%
%   >> [dt, t_av, fwhh] = ikcarp_param_pulse_width (pp,ei)
%
%   >> [dt, t_av, fwhh] = ikcarp_param_pulse_width (pp,ei) % generally much slower
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
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   dt          Standard deviation of pulse width (microseconds)
%   t_av        First moment (microseconds)
%   fwhh        Full width half height (microseconds)

[tauf, taus, R] = ikcarp_param_convert (pp, ei);
dt = zeros(size(ei));
t_av = zeros(size(ei));

if nargout==2
    for i=1:numel(ei)
        [dt(i), t_av(i)] = pulse_width_ikcarp ([tauf(i),taus(i),R(i)], ei(i));
    end
else
    fwhh=zeros(size(ei));
    for i=1:numel(ei)
        [dt(i), t_av(i), fwhh(i)] = pulse_width_ikcarp ([tauf(i),taus(i),R(i)], ei(i));
    end
end
