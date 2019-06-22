function [t_av, t_cov] = covariance_mod_shape_mono (moderator,...
    shape_chopper, mono_chopper, ei)
% Calculate the time correlations for moderator, shaping and mono choppers
%
%   >> [t_av, t_cov] = covariance_mod_shape_mono (moderator,...
%                                   shape_chopper, mono_chopper, ei)
%
% The average time of the pulse at the shaping chopper position and the fermi
% chopper will in general be non zero, as will the covariance matrix.
%
% Input:
% ------
%   moderator       IX_moderator object
%   shape_chopper  	Moderator shaping chopper object
%   mono_chopper    Monochromating chopper object
%   ei              Indicdent energy (may be needed by the moderator)
%
% Output:
% -------
%   t_av            Mean time of pulse at shaping and mono chopper positions
%                  (microseconds) [row vector]
%   t_cor           Covariance matrix of times at shaping and mono choppers
%                  [var_sh_sho, var_sh_mo; var_sh_mo, var_mo_mo] (microseconds^2)


% The function integrates over the full width of the monochromating and shaping
% choppers to compute the first and second moments of t_shape and t_mono with
% account of the moderator pulse width. If the moderator pulse is very narrow, then
% the algorithm will have problems converging.

x0 = moderator.distance - mono_chopper.distance;    % moderator to monochromating chopper
xa = shape_chopper.distance - mono_chopper.distance;% shaping chopper to monochromating chopper

[tlo_shape,thi_shape] = pulse_range(shape_chopper);
[tlo_mono,thi_mono] = pulse_range(mono_chopper);

area = integral2 (@(x,y)(fun_area(x,y,moderator,shape_chopper,mono_chopper,ei,x0,xa,[0,0])),...
    tlo_shape, thi_shape, tlo_mono, thi_mono);

t_av = zeros(1,2);
t_av(1) = integral2 (@(x,y)(fun_area(x,y,moderator,shape_chopper,mono_chopper,ei,x0,xa,[1,0])),...
    tlo_shape, thi_shape, tlo_mono, thi_mono) / area;

t_av(2) = integral2 (@(x,y)(fun_area(x,y,moderator,shape_chopper,mono_chopper,ei,x0,xa,[0,1])),...
    tlo_shape, thi_shape, tlo_mono, thi_mono) / area;

t_cov = zeros(2,2);
t_cov(1,1) = integral2 (@(x,y)(fun_area(x,y,moderator,shape_chopper,mono_chopper,ei,x0,xa,[2,0])),...
    tlo_shape, thi_shape, tlo_mono, thi_mono) / area;
t_cov(1,2) = integral2 (@(x,y)(fun_area(x,y,moderator,shape_chopper,mono_chopper,ei,x0,xa,[1,1])),...
    tlo_shape, thi_shape, tlo_mono, thi_mono) / area;
t_cov(2,2) = integral2 (@(x,y)(fun_area(x,y,moderator,shape_chopper,mono_chopper,ei,x0,xa,[0,2])),...
    tlo_shape, thi_shape, tlo_mono, thi_mono) / area;

% Correct covariance matrix for non-zero first moments
t_cov(1,1) = t_cov(1,1) - t_av(1)^2;
t_cov(1,2) = t_cov(1,2) - t_av(1)*t_av(2);
t_cov(2,2) = t_cov(2,2) - t_av(2)^2;
t_cov(2,1) = t_cov(1,2);

%----------------------------------------------------------
function f = fun_area (ta, tch, moderator, shape_chopper, mono_chopper, ei, x0, xa, pwr)
[~,t_av] = pulse_width(moderator,ei);
tm = (x0/xa)*ta - ((x0-xa)/xa)*tch;
% Offset moderator time by t_av as tm measured w.r.t zero moment of tch, ta. 
% Actually, need to be more sophisticated in reality, because the phase of 
% the choppers will be chosen by some calibration procedure that results in
% <t_sh>=0 for the shaped moderator pulse at the chaping chopper - but need
% to check how the calibration is actually done in practice.

mod_pulse = pulse_shape (moderator,ei,tm+t_av);  
chop_shape = pulse_shape (shape_chopper,ta);
chop_mono = pulse_shape (mono_chopper,tch);

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
