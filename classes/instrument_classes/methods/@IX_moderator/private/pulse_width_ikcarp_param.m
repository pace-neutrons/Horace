function [dt,t_av]=pulse_width_ikcarp_param(pp,ei)
% Calculate st. dev. of moderator pulse width distribution (microseconds)
%
%   >> [dt,tav]=pulse_width_ikcarp_param(pp,ei)
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
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   dt          Standard deviation of pulse width (microseconds)
%   t_av        First moment (microseconds)

[tauf,taus,R]=ikcarp_param_convert(pp);
[dt,t_av]=pulse_width_ikcarp([tauf,taus,R],ei);
