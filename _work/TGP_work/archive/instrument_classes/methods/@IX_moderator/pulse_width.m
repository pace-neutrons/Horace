function [dt,t_av,fwhh]=pulse_width(moderator,ei)
% Calculate st. dev. of moderator pulse width distribution (microseconds)
%
%   >> [dt,tav]=pulse_width(moderator,ei)
%
%   >> [dt,tav,fwhh]=pulse_width(moderator,ei)
%
% The second call returns fwhh too: can be much slower, however, so only return
% the third argument if it is needed.
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
%   fwhh        Full width half height (microseconds)

if ~isscalar(moderator), error('Function only takes a scalar object'), end

model=moderator.pulse_model;
if strcmp(model,'ikcarp')           % Raw Ikeda Carpenter
    if nargout==2
        [dt,t_av]=pulse_width_ikcarp(moderator.pp,ei);
    else
        [dt,t_av,fwhh]=pulse_width_ikcarp(moderator.pp,ei);
    end
elseif strcmp(model,'ikcarp_param') % Ikeda-Carpenter with parametrised tauf, taus, R
    if nargout==2
        [dt,t_av]=pulse_width_ikcarp_param(moderator.pp,ei);
    else
        [dt,t_av,fwhh]=pulse_width_ikcarp_param(moderator.pp,ei);
    end
else
    error('Unrecognised pulse model')
end
