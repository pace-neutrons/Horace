function w = plot_fun_shaped (self, w_sh, n_sh, w_ch, n_ch)

% Pick out constituent instrument components and quantities
moderator = self.moderator;
shaping_chopper = self.shaping_chopper;
mono_chopper = self.mono_chopper;

x1 = mono_chopper.distance;
x0 = moderator.distance - x1;       % distance from mono chopper to moderator face
xa = shaping_chopper.distance - x1; % distance from shaping chopper to mono chopper
[~,t_m_av] = pulse_width(moderator);

[tlo_shape,thi_shape] = pulse_range(shaping_chopper);
[tlo_mono,thi_mono] = pulse_range(mono_chopper);

disp([thi_shape])
disp([thi_mono])


t_sh = linspace(-w_sh,w_sh,n_sh);
t_ch = linspace(-w_ch,w_ch,n_ch);

[tt_sh, tt_ch] = ndgrid (t_sh, t_ch);
f = fun_shaped (tt_sh, tt_ch, moderator, shaping_chopper, mono_chopper,...
    x0, xa, t_m_av, [0,0]);

w = IX_dataset_2d (t_sh, t_ch, f);



%----------------------------------------------------------
function f = fun_shaped (t_sh, t_ch, moderator, shaping_chopper, mono_chopper,...
    x0, xa, t_m_av, pwr)
% Function that gives the transmission as a function of time at shaping
% chopper and time at monochromating chopper, weighted by powers of t_sh
% and t_sh
%
%   t_sh        Time at shaping chopper (microseconds) w.r.t. mean
%   t_ch        Time at monochromating chopper (microseconds) w.r.t. mean
%   moderator       Scalar moderator object
%   shaping_chopper Scalar shaping chopper object
%   mono_chopper    Scalar monochromating chopper object
%   x0          Moderator to monochromating chopper distance
%   xa          Pulse shaping chopper to monochromating chopper distance
%   t_m_av      First moment of moderator pulse (microseconds)
%   pwr         Integrand multiplied by (t_sh)^m * (t_ch)^2 where pwr = [m,n]

t_m = (x0/xa)*t_sh - ((x0-xa)/xa)*t_ch;

% Offset moderator time by t_av as tm measured w.r.t zero moment of t_sh
% and t_ch.
% Actually, need to be more sophisticated in reality, because the phase of
% the choppers will be chosen by some calibration procedure that results in
% <t_sh>=0 for the shaped moderator pulse at the chaping chopper - but need
% to check how the calibration is actually done in practice.

mod_pulse = pulse_shape (moderator, t_m+t_m_av);
shape_pulse = pulse_shape (shaping_chopper, t_sh);
mono_pulse = pulse_shape (mono_chopper, t_ch);

f = mod_pulse.*shape_pulse.*mono_pulse;

if ~any(pwr)
    return
elseif ~any(pwr-[1,1])
    f = f .* t_sh .* t_ch;
elseif ~any(pwr-[2,0])
    f = f .* (t_sh.^2);
elseif ~any(pwr-[0,2])
    f = f .* (t_ch.^2);
elseif ~any(pwr-[1,0])
    f = f .* t_sh;
elseif ~any(pwr-[0,1])
    f = f .* t_ch;
else
    error('Aargh!')
end
