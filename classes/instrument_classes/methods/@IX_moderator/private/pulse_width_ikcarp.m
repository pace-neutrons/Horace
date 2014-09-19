function [dt,t_av]=pulse_width_ikcarp(pp,ei)
% Calculate st. dev. of moderator pulse width distribution (microseconds)
%
%   >> [dt,tav]=pulse_width_ikcarp_param(pp,ei)
%
% Input:
% -------
%   pp          Arguments for Ikeda-Carpenter moderator
%                   [tauf,taus,R] (times in microseconds)
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   dt          Standard deviation of pulse width (microseconds)
%   t_av        First moment (microseconds)

dt   = sqrt(3*pp(1)^2 + pp(3)*(2-pp(3))*pp(2)^2);
t_av = 3*pp(1)   + pp(3)*pp(2);
if numel(ei)~=1
    dt=dt*ones(size(ei));
    t_av=t_av*ones(size(ei));
end
