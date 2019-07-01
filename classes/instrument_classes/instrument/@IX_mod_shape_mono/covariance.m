function [t_cov, t_av] = covariance (self, varargin)
% Calculate the time correlations for moderator, shaping and mono choppers
%
%   >> [t_cov, t_av] = covariance_mod_shape_mono (self)
%   >> [t_cov, t_av] = covariance_mod_shape_mono (self, energy)
%
% Controlling contributions of instrument components
%   >> [t_cov, t_av] = covariance_mod_shape_mono (...,'mc',mc_val)
%
% The average time of the pulse at the shaping chopper position and the fermi
% chopper will in general be non zero, as will the covariance matrix.
%
% Input:
% ------
%   self        IX_mod_shape_mono object
%
% Optionally:
%   energy      Neutron energy (meV) (array or scalar)
%               If omitted or empty, use the ei value in the moderator
%              object in IX_mod_shape_mono
%
%   mc_val      Logical row vector [moderator, shape_chopper, mono_chopper]
%              which shows which components contribute to the pulse shape.
%               - If only one of moderator and shape_chopper is true,
%                 then the other is treated as having no effect i.e. it is
%                 infinitely wide.
%               - If both are turned off means a delta function in time.
%
% Output:
% -------
%   t_cov       Covariance matrix of times at shaping and monochromating
%              choppers [var_sh_sho, var_sh_mo; var_sh_mo, var_mo_mo]
%              (microseconds^2)
%
%   t_av        Mean time of pulse at shaping and monochromating
%              chopper positions (microseconds) [row vector]


% Parse optional parameters
% - get mc
if numel(varargin)>=2 && is_string(varargin{end-1})
    if strncmpi(varargin{end-1},'mc',numel(varargin{end-1}))
        mc = logical(varargin{end}(:)');
        mc_moderator = mc(1);
        mc_shape_chopper = mc(2);
        mc_mono_chopper = mc(3);
        args = varargin(1:end-2);
    else
        error('Check optional input arguments')
    end
else
    mc_moderator = true;
    mc_shape_chopper = true;
    mc_mono_chopper = true;
    args = varargin;
end
% - get energy
if numel(args)==1
    self.energy = args{1};
elseif numel(args)~=0
    error('Check optional input arguments')
end


% Pick out constituent instrument components and quantities
moderator = self.moderator_;
shaping_chopper = self.shaping_chopper_;
mono_chopper = self.mono_chopper_;

x1 = mono_chopper.distance;
x0 = moderator.distance - x1;       % distance from mono chopper to moderator face
xa = shaping_chopper.distance - x1; % distance from shaping chopper to mono chopper
alf = (xa/x0);
bet = (x0-xa)/x0;

t_cov = zeros(2);
t_av = zeros(1,2);
if mc_moderator && mc_shape_chopper% moderator and shaping chopper both present
    if mc_mono_chopper    % 2D integral needs to be performed
        [t_cov,t_av] = moments_2D (self, alf);
    else        % 1D integral needs to be performed
        [t_cov(1,1),t_av(1)] = moments_1D (moderator, shaping_chopper, alf);
    end
elseif mc_moderator     % shaping chopper is treated as absent
    sig_m = pulse_width(moderator);
    if mc_mono_chopper
        sig_ch = pulse_width(mono_chopper);
        t_cov = [(alf*sig_m)^2 + (bet*sig_ch)^2, bet*sig_ch^2;...
            bet*sig_ch^2, sig_ch^2];
    else
        t_cov = [(alf*sig_m)^2, 0; 0, 0];
    end
elseif mc_shape_chopper    % moderator is treated as infinitely wide
    sig_sh = pulse_width(shaping_chopper);
    if mc_mono_chopper
        sig_ch = pulse_width(mono_chopper);
        t_cov = [sig_sh^2, 0; 0, sig_ch^2];
    else
        t_cov = [sig_sh^2, 0; 0, 0];
    end
end


% =================================================================================================
function [t_var,t_av] = moments_1D (moderator, shaping_chopper, alf)
% Return average and variance at shaping chopper position if delta-function
% monochromating chopper. In this case the integrals reduce to 1D.

[~,t_m_av] = pulse_width(moderator);
[tlo_shape,thi_shape] = pulse_range(shaping_chopper);

% Integration range
if alf*t_m_av > abs(tlo_shape)
    tlo = tlo_shape;
else
    tlo = -alf*t_m_av;
end

% Waypoints - get a few points in that span the width of the moderator pulse
% Hope that this forces the grid to spot a sharp pulse in the shaping chopper window
t_sh_waypoints = alf*[-t_m_av/2, 0, t_m_av/2, t_m_av, 2*t_m_av];
ok = (t_sh_waypoints>tlo & t_sh_waypoints<thi_shape);
t_sh_waypoints = t_sh_waypoints(ok);

% Zeroth moment
area = integral (@(x)fun_1D(x, moderator, shaping_chopper, alf, t_m_av, 0),...
    tlo, thi_shape, 'waypoints', t_sh_waypoints);

% First moment
t_av = integral (@(x)fun_1D(x, moderator, shaping_chopper, alf, t_m_av, 1),...
    tlo, thi_shape, 'waypoints', t_sh_waypoints) / area;

% Variance
t_var = integral (@(x)fun_1D(x, moderator, shaping_chopper, alf, t_m_av, 2),...
    tlo, thi_shape, 'waypoints', t_sh_waypoints) / area;

% Correct variance for non-zero first moment
t_var = t_var - t_av^2;


%----------------------------------------------------------
function f = fun_1D (t_sh, moderator, shaping_chopper, alf, t_m_av, pwr)
% Function that gives the transmission as a function of time at shaping
% chopper and time at monochromating chopper, weighted by powers of t_sh
% and t_sh
%
%   t_sh        Time at shaping chopper (microseconds) w.r.t. mean
%   moderator       Scalar moderator object
%   shaping_chopper Scalar shaping chopper object
%   mono_chopper    Scalar monochromating chopper object
%   alf         Ratio (xa/x0) i.e. pulse shaping chopper to monochromating
%               chopper distance divided by moderator to monochromating
%               chopper distance
%   t_m_av      First moment of moderator pulse (microseconds)
%   pwr         Integrand multiplied by (t_sh)^m * (t_ch)^2 where pwr = [m,n]

t_m = t_sh/alf;

mod_pulse = pulse_shape (moderator, t_m+t_m_av);
shape_pulse = pulse_shape (shaping_chopper, t_sh);

f = mod_pulse.*shape_pulse;

if pwr==1
    f = f .* t_sh;
elseif pwr==2
    f = f .* (t_sh.^2);
elseif pwr~=0
    error('Aargh!')
end


% =================================================================================================
function [t_cov,t_av] = moments_2D (obj, alf)
% General case of finite no-zero widths of moderator, shaping and 
% monochromating choppers. Have a two-dimensional integral to perform, which 
% can be pathologicla in the case of markedly different widths for the
% different components.
% For this reason, there are different regimes which use different methods
% A particularly tricky case is when the shaping chopper is much broader than
% the moderator. By experiment, caluclating the moments from Monte Carlo
% sampling appears to be accurate and robust. This is because we sample
% the distributions correctly without weighting of events. So use this
% approach.

moderator = obj.moderator_;
shaping_chopper = obj.shaping_chopper_;
mono_chopper = obj.mono_chopper_;

[~,t_m_av] = pulse_width(moderator);
[tlo_shape,thi_shape] = pulse_range(shaping_chopper);
[tlo_mono,thi_mono] = pulse_range(mono_chopper);

% From characteristic width of moderator in relation to the shaping chopper, determine
% the integration variables
fac = 0.33;    % change to non-zero value when implement narrow moderator code
if (alf*t_m_av) > fac*thi_shape
    % Work in t_sh-t_ch space
    % Zeroth moment
    area = integral2 (@(x,y)(fun_shaped(x, y, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, [0,0])), tlo_shape, thi_shape, tlo_mono, thi_mono);
    
    % First moments
    t_av = zeros(1,2);
    t_av(1) = integral2 (@(x,y)(fun_shaped(x, y, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, [1,0])), tlo_shape, thi_shape, tlo_mono, thi_mono) / area;
    
    t_av(2) = integral2 (@(x,y)(fun_shaped(x, y, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, [0,1])), tlo_shape, thi_shape, tlo_mono, thi_mono) / area;
    
    % Second moments
    t_cov = zeros(2,2);
    t_cov(1,1) = integral2 (@(x,y)(fun_shaped(x, y, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, [2,0])), tlo_shape, thi_shape, tlo_mono, thi_mono) / area;
    
    t_cov(1,2) = integral2 (@(x,y)(fun_shaped(x, y, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, [1,1])), tlo_shape, thi_shape, tlo_mono, thi_mono) / area;
    
    t_cov(2,2) = integral2 (@(x,y)(fun_shaped(x, y, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, [0,2])), tlo_shape, thi_shape, tlo_mono, thi_mono) / area;
        
    % Correct covariance matrix for non-zero first moments
    t_cov(1,1) = t_cov(1,1) - t_av(1)^2;
    t_cov(1,2) = t_cov(1,2) - t_av(1)*t_av(2);
    t_cov(2,2) = t_cov(2,2) - t_av(2)^2;
    t_cov(2,1) = t_cov(1,2);
    
else
    % Random sampling with 10^6 points eems to get the covariance to about 0.5%
    % and seems to be very robust, unlike using the Matlab functions integral
    % or integral2, which are time-consuming and can be thrown by the pathological
    % cases of widely different widths.
    % For reproducibility, reset the seed for random number generation, but
    % reset to incoming state afterwards.
    npnt = 1e6;     
    state = rng;        % get current state of erandom number generators
    rng(0,'twister');   % set particular state
    X = obj.rand([npnt,1]);
    rng(state);         % return to original state
    t_cov = cov(X');
    t_av = mean(X,2)';
end


%----------------------------------------------------------
function f = fun_shaped (t_sh, t_ch, moderator, shaping_chopper, mono_chopper,...
    alf, t_m_av, pwr)
% Function that gives the transmission as a function of time at shaping
% chopper and time at monochromating chopper, weighted by powers of t_sh
% and t_sh
%
%   t_sh        Time at shaping chopper (microseconds) w.r.t. mean
%   t_ch        Time at monochromating chopper (microseconds) w.r.t. mean
%   moderator       Scalar moderator object
%   shaping_chopper Scalar shaping chopper object
%   mono_chopper    Scalar monochromating chopper object
%   alf         Ratio (xa/x0) i.e. pulse shaping chopper to monochromating
%               chopper distance divided by moderator to monochromating
%               chopper distance
%   t_m_av      First moment of moderator pulse (microseconds)
%   pwr         Integrand multiplied by (t_sh)^m * (t_ch)^2 where pwr = [m,n]

t_m = t_sh/alf - ((1-alf)/alf)*t_ch;

% Offset moderator time by t_av as t_m measured w.r.t zero moment of t_sh
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
