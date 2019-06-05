function [dt,t_av,fwhh]=pulse_width_ikcarp(pp,ei)
% Calculate st. dev. of moderator pulse width distribution (microseconds)
%
%   >> [dt,tav]=pulse_width_ikcarp(pp,ei)
%   >> [dt,tav,fwhh]=pulse_width_ikcarp(pp,ei) % generally much slower
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
%   fwhh        Full width half height (microseconds)

dt   = sqrt(3*pp(1)^2 + pp(3)*(2-pp(3))*pp(2)^2);
t_av = 3*pp(1)   + pp(3)*pp(2);
if numel(ei)~=1
    dt=dt*ones(size(ei));
    t_av=t_av*ones(size(ei));
end

if nargout==3
    if pp(2)==0 || pp(3)==0
        fwhh=3.394680670846503*pp(1);
    else
        fwhh=ikcarp_fwhh (pp(1), pp(2), pp(3));
    end
    if numel(ei)~=1
        fwhh=fwhh*ones(size(ei));
    end
end
