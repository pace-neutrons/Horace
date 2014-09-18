function [dt,t_av]=pulse_width(moderator,ei)
% Calculate st. dev. of moderator pulse width distribution (microseconds)
%
%   >> [dt,tav]=pulse_width(moderator,ei)
%
% Input:
% -------
%   moderator   IX_moderator object
%   ei          Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   dt          Standard deviation of pulse width (microseconds)
%   t_av        First moment (microseconds)

if ~isscalar(moderator), error('Function only takes a scalar object'), end

model=moderator.pulse_model;
if strcmp(model,'ikcarp')           % Raw Ikeda Carpenter
    [dt,t_av]=pulse_width_ikcarp(moderator.pp,ei);
elseif strcmp(model,'ikcarp_param') % Ikeda-Carpenter with parametrised tauf, taus, R
    [dt,t_av]=pulse_width_ikcarp_param(moderator.pp,ei);
else
    error('Unrecognised pulse model')
end
