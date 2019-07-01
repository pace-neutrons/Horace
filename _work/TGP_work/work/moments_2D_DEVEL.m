function [t_cov,t_av] = moments_2D_DEVEL (self)
moderator = self.moderator_;
shaping_chopper = self.shaping_chopper_;
mono_chopper = self.mono_chopper_;
x1 = mono_chopper.distance;
x0 = moderator.distance - x1;       % distance from mono chopper to moderator face
xa = shaping_chopper.distance - x1; % distance from shaping chopper to mono chopper
alf = (xa/x0);
[t_cov,t_av] = moments_2D (moderator, shaping_chopper, mono_chopper, alf);

%==================================================================================
function [t_cov,t_av] = moments_2D (moderator, shaping_chopper, mono_chopper, alf)

[~,t_m_av] = pulse_width(moderator);
[tlo_shape,thi_shape] = pulse_range(shaping_chopper);
[tlo_mono,thi_mono] = pulse_range(mono_chopper);

% From characteristic width of moderator in relation to the shaping chopper, determine
% the integration variables
fac = 0;    % change to non-zero value when implement narrow moderator code
% if (alf*t_m_av) > fac*thi_shape
%     % Work in t_sh-t_ch space
%     % Zeroth moment
%     disp('Dealt with elsewhere')
% end
    

    % Work in tm-t_ch space as very narrow moderator w.r.t shaping chopper
    % Zeroth moment
    area = integral (@(x,y)(fun_mod_outer(x, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, tlo_shape, thi_shape, [0,0])), tlo_mono, thi_mono);
    
    % First moments
    t_av = zeros(1,2);
    t_av(1) = integral (@(x,y)(fun_mod_outer(x, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, tlo_shape, thi_shape, [1,0])), tlo_mono, thi_mono) / area;
    
    t_av(2) = integral (@(x,y)(fun_mod_outer(x, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, tlo_shape, thi_shape, [0,1])), tlo_mono, thi_mono) / area;
    
    % Second moments
    t_cov = zeros(2,2);
    t_cov(1,1) = integral (@(x,y)(fun_mod_outer(x, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, tlo_shape, thi_shape, [2,0])), tlo_mono, thi_mono) / area;
    
    t_cov(1,2) = integral (@(x,y)(fun_mod_outer(x, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, tlo_shape, thi_shape, [1,1])), tlo_mono, thi_mono) / area;
    
    t_cov(2,2) = integral (@(x,y)(fun_mod_outer(x, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, tlo_shape, thi_shape, [0,2])), tlo_mono, thi_mono) / area;


% Correct covariance matrix for non-zero first moments
t_cov(1,1) = t_cov(1,1) - t_av(1)^2;
t_cov(1,2) = t_cov(1,2) - t_av(1)*t_av(2);
t_cov(2,2) = t_cov(2,2) - t_av(2)^2;
t_cov(2,1) = t_cov(1,2);


%----------------------------------------------------------
function f = fun_mod_outer (t_ch, moderator, shaping_chopper, mono_chopper,...
    alf, t_m_av, tlo_shape, thi_shape, pwr)
% Integrate over t_m to get integrand for t_ch integration
% This function will in general be fed an array of t_ch. Use arrayfun to
% evaluate for this array

f = arrayfun(@(x,ylo,yhi)(fun_mod_outer_single(x, moderator, shaping_chopper, mono_chopper,...
    alf, t_m_av, tlo_shape, thi_shape, pwr)), t_ch);

%----------------------------------------------------------
function f = fun_mod_outer_single (t_ch, moderator, shaping_chopper, mono_chopper,...
    alf, t_m_av, tlo_shape, thi_shape, pwr)
% Integrate over t_m to get integrand for t_ch integration
% This function takes a single value of t_ch

tlo = max(-t_m_av, (tlo_shape - (1-alf)*t_ch)/alf);
thi = (thi_shape - (1-alf)*t_ch)/alf;

if thi>tlo
    t_m_waypoints = [-t_m_av/2, 0, t_m_av/2, t_m_av, 2*t_m_av];
    ok = (t_m_waypoints>tlo & t_m_waypoints<thi);
    t_m_waypoints = t_m_waypoints(ok);
    f = integral (@(x)(fun_mod_inner(x, t_ch, moderator, shaping_chopper, mono_chopper,...
        alf, t_m_av, pwr)), tlo, thi, 'waypoints', t_m_waypoints);
    
else    % upper integrand less than or equal to -t_m_av
    f = 0;
end


%----------------------------------------------------------
function f = fun_mod_inner (t_m, t_ch, moderator, shaping_chopper, mono_chopper,...
    alf, t_m_av, pwr)
% Function that gives the transmission as a function of time at shaping
% chopper and time at monochromating chopper, weighted by powers of t_sh
% and t_sh
%
%   t_m         Time at moderator (microseconds) w.r.t. mean
%   t_ch        Time at shaping chopper (microseconds) w.r.t. mean
%   moderator       Scalar moderator object
%   shaping_chopper Scalar shaping chopper object
%   mono_chopper    Scalar monochromating chopper object
%   x0          Moderator to monochromating chopper distance
%   xa          Pulse shaping chopper to monochromating chopper distance
%   t_m_av      First moment of moderator pulse (microseconds)
%   pwr         Integrand multiplied by (t_sh)^m * (t_ch)^2 where pwr = [m,n]

t_sh = t_m*alf + (1-alf)*t_ch;

% Offset moderator time by t_av as t_m measured w.r.t zero moment of t_sh
% and t_ch.

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
