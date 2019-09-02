function t_m_offset = t_m_offset_calibrate_ (obj)
% Calibrate the offset time for moderator sampling
%
%   >> t_m_offset = t_m_offset_calibrate_ (obj)
%
% The offset time is the time at the moderator which the shaping and
% monochromating choppers are phased for the given energy. That is,
% the centres of the time pulses in the choppers define the velocity of
% the neutrons, and the moderator offset time is the one which maximises
% the flux
%
% Input:
% ------
%   obj             IX_mod_shape_mono object
%
% Output:
% -------
%   t_m_offset_msm  Offset time at moderator for the various cases of 
%                   contributions turned on or off. Row vector length 8:
%                  
%                       mod  shape  mono        Element
%                        1     1     1             8
%                        1     1     0             7
%                        1     0     1             6
%                        1     0     0             5
%                        0     1     1             4
%                        0     1     0             3
%                        0     0     1             2
%                        0     0     0             1


[~,t_av] = pulse_width (obj.moderator);

t_m_offset = zeros(1,8);

% mod-shape-chop = [1,1,1]
t_m_offset(8) = t_m_offset_msm (obj);

% mod-shape-chop = [1,1,0]
t_m_offset(7) = t_m_offset_ms (obj);

% mod-shape-chop = [1,0,1]
t_m_offset(6) = t_av;

% mod-shape-chop = [1,0,0]
t_m_offset(5) = t_av;

% mod-shape-chop = [0,1,1]
t_m_offset(4) = 0;  % not relevant, as the moderator is infinite

% mod-shape-chop = [0,1,0]
t_m_offset(3) = 0;  % not relevant, as the moderator is infinite

% mod-shape-chop = [0,0,1]
t_m_offset(2) = 0;  % not relevant, as the moderator is infinite

% mod-shape-chop = [0,0,0]
t_m_offset(1) = 0;  % not relevant, as the moderator is infinite


%=============================================================================================
function t_m_offset = t_m_offset_msm (obj)
% Calibrate the offset time from which to sample the moderator
%
%   >> t_m_offset = t_m_offset_msm (obj)
%
% This function is for the case of all three of moderator, shaping
% chopper and monochromating chopper have finite non-zero widths
%
% The offset time is the time at the moderator which the shaping and
% monochromating choppers are phased for the given energy. That is,
% the centres of the time pulses in the choppers define the velocity of
% the neutrons, and the moderator offset time is the one which maximises
% the flux
%
% Input:
% ------
%   obj             IX_mod_shape_mono object
%
% Output:
% -------
%   t_m_offset_msm  Offset_time


% Pick out constituent instrument components and quantities
moderator = obj.moderator_;
shaping_chopper = obj.shaping_chopper_;
mono_chopper = obj.mono_chopper_;
energy = obj.energy;

x1 = mono_chopper.distance;
x0 = moderator.distance - x1;       % distance from mono chopper to moderator face
xa = shaping_chopper.distance - x1; % distance from shaping chopper to mono chopper
const_sh = (x0/xa);
const_ch = (x0-xa)/xa;

% Get the fwhh and half-height posiitons for the moderator
[w_mod, ~, t_HH_lo, t_HH_hi] = pulse_width2 (moderator, 0.5, energy);

% Get the full ranges of the double disk choppers
w_shape = 2*abs(pulse_range(shaping_chopper));
w_shape_at_mod = w_shape*const_sh;

w_mono = 2*abs(pulse_range(mono_chopper));
w_mono_at_mod = w_mono*const_ch;

% Determine the time interval for array convolution as
% measured along the moderator time axis
frac = 0.01;
dt = frac * min([w_mod, w_shape_at_mod, w_mono_at_mod]);

% Perform convolution of shaping and monochromating chopper projected
% onto moderator time
n = ceil(0.5*w_shape_at_mod/dt);
t_sh = (dt/const_sh)*(-n:n);    % just covers the full range of the chopper
sh = pulse_shape(shaping_chopper,t_sh);

n = ceil(0.5*w_mono_at_mod/dt);
t_ch = (dt/const_ch)*(-n:n);    % just covers the full range of the chopper
ch = pulse_shape(mono_chopper,t_ch);

chop_fun = conv(sh,ch,'full');

% Perform convolution with moderator profile
Tlo = t_HH_lo - (w_shape_at_mod + w_mono_at_mod);
Thi = t_HH_hi + (w_shape_at_mod + w_mono_at_mod);

t = Tlo + dt*(0:ceil((Thi-Tlo)/dt));
mod_fun = pulse_shape (moderator, t);

intensity = conv(mod_fun, chop_fun, 'same');

% Position of peak intensity
[~,imax] = max(intensity);
t_m_offset = Tlo + dt*(imax-1);



%=============================================================================================
function t_m_offset = t_m_offset_ms (obj)
% Calibrate the offset time from which to sample the moderator
%
%   >> t_m_offset = t_m_offset_ms (obj)
%
% This function is for the case of moderator and shaping chopper
% having finite non-zero widths, but the monochromating chopper is a
% delta function
%
% The offset time is the time at the moderator which the shaping and
% monochromating choppers are phased for the given energy. That is,
% the centres of the time pulses in the choppers define the velocity of
% the neutrons, and the moderator offset time is the one which maximises
% the flux
%
% Input:
% ------
%   obj             IX_mod_shape_mono object
%
% Output:
% -------
%   t_m_offset_msm  Offset_time



% Pick out constituent instrument components and quantities
moderator = obj.moderator_;
shaping_chopper = obj.shaping_chopper_;
mono_chopper = obj.mono_chopper_;
energy = obj.energy;

x1 = mono_chopper.distance;
x0 = moderator.distance - x1;       % distance from mono chopper to moderator face
xa = shaping_chopper.distance - x1; % distance from shaping chopper to mono chopper
const_sh = (x0/xa);

% Get the fwhh and half-height posiitons for the moderator
[w_mod, ~, t_HH_lo, t_HH_hi] = pulse_width2 (moderator, 0.5, energy);

% Get the full range of the double disk chopper
w_shape = 2*abs(pulse_range(shaping_chopper));
w_shape_at_mod = w_shape*const_sh;

% Determine the time interval for array convolution as
% measured along the moderator time axis
frac = 0.01;
dt = frac * min([w_mod, w_shape_at_mod]);

% Get shaping chopper projected onto moderator time
n = ceil(0.5*w_shape_at_mod/dt);
t_sh = (dt/const_sh)*(-n:n);    % just covers the full range of the chopper
sh = pulse_shape(shaping_chopper,t_sh);

% Perform convolution with moderator profile
Tlo = t_HH_lo - w_shape_at_mod;
Thi = t_HH_hi + w_shape_at_mod;

t = Tlo + dt*(0:ceil((Thi-Tlo)/dt));
mod_fun = pulse_shape (moderator, t);

intensity = conv(mod_fun, sh, 'same');

% Position of peak intensity
[~,imax] = max(intensity);
t_m_offset = Tlo + dt*(imax-1);
