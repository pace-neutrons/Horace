function [t_av, t_cov] = covariance_mod_shape_mono (moderator,...
    fwhh_shape, fwhh_mono, ei, x0, xa)
% Calculate the time correlations for moderator, shaping and mono choppers
%
%   >> [t_av, t_cov] = covariance_mod_shape_mono (moderator,...
%                                       fwhh_shape, fwhh_mono, ei, x0, xa)
%
% The average time of the pulse at the shaping chopper position and the fermi
% chopper will in general be non zero, as will the covariance matrix.
%
% Input:
% ------
%   moderator   IX_moderator object
%   fwhh_shape  FWHH of a disk chopper that shapes the moderator pulse
%   fwhh_mono   FWHH of a monochromating chopper
%   ei          Indicdent energy (may be needed by the moderator)
%   x0          Distance (m) from moderator to monochromating chopper
%   xa          Distance (m) from shaping chopper to monochromating chopper
%
% Output:
% -------
%   t_av        Mean time of pulse at shaping and mono chopper positions
%              (microseconds) [row vector]
%   t_cor       Covariance matrix of times at shaping and mono choppers
%              [var_sh_sho, var_sh_mo; var_sh_mo, var_mo_mo] (microseconds^2)

area = integral2 (@(x,y)(fun_area(x,y,moderator,fwhh_shape,fwhh_mono,ei,x0,xa,[0,0])),...
    -fwhh_shape, fwhh_shape, -fwhh_mono, fwhh_mono);

t_av = zeros(1,2);
t_av(1) = integral2 (@(x,y)(fun_area(x,y,moderator,fwhh_shape,fwhh_mono,ei,x0,xa,[1,0])),...
    -fwhh_shape, fwhh_shape, -fwhh_mono, fwhh_mono) / area;

t_av(2) = integral2 (@(x,y)(fun_area(x,y,moderator,fwhh_shape,fwhh_mono,ei,x0,xa,[0,1])),...
    -fwhh_shape, fwhh_shape, -fwhh_mono, fwhh_mono) / area;

t_cov = zeros(2,2);
t_cov(1,1) = integral2 (@(x,y)(fun_area(x,y,moderator,fwhh_shape,fwhh_mono,ei,x0,xa,[2,0])),...
    -fwhh_shape, fwhh_shape, -fwhh_mono, fwhh_mono) / area;
t_cov(1,2) = integral2 (@(x,y)(fun_area(x,y,moderator,fwhh_shape,fwhh_mono,ei,x0,xa,[1,1])),...
    -fwhh_shape, fwhh_shape, -fwhh_mono, fwhh_mono) / area;
t_cov(2,2) = integral2 (@(x,y)(fun_area(x,y,moderator,fwhh_shape,fwhh_mono,ei,x0,xa,[0,2])),...
    -fwhh_shape, fwhh_shape, -fwhh_mono, fwhh_mono) / area;

% Correct covariance matrix for non-zero first moments
t_cov(1,1) = t_cov(1,1) - t_av(1)^2;
t_cov(1,2) = t_cov(1,2) - t_av(1)*t_av(2);
t_cov(2,2) = t_cov(2,2) - t_av(2)^2;
t_cov(2,1) = t_cov(1,2);

%----------------------------------------------------------
function f = fun_area (ta, tch, moderator, fwhh_shape, fwhh_mono, ei, x0, xa, pwr)
[~,t_av] = pulse_width(moderator,ei);
tm = (x0/xa)*ta - ((x0-xa)/xa)*tch;
mod_pulse = pulse_shape(moderator,ei,tm+t_av);
chop_shape = 1 - abs(ta)/fwhh_shape;
chop_mono = 1 - abs(tch)/fwhh_mono;

f = mod_pulse.*chop_shape.*chop_mono;

if ~any(pwr)
    return
elseif ~any(pwr-[1,1])
    f = f .* ta .* tch;
elseif ~any(pwr-[2,0])
    f = f .* (ta.^2);
elseif ~any(pwr-[0,2])
    f = f .* (tch.^2);
elseif ~any(pwr-[1,0])
    f = f .* ta;
elseif ~any(pwr-[0,1])
    f = f .* tch;
else
    error('Aargh!')
end
