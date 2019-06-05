function [sigma,fwhh]=profile_width(divergence)
% Calculate st. dev. of divergence distribution
%
%   >> [dt,pk_fwhh]=profile_width(divergence)
%
% Input:
% -------
%   fermi   IX_divergence_profile object
%
% Output:
% -------
%   dtheta  Standard deviation of pulse width (rad)
%   fwhh    FWHH of profile (rad)

if ~isscalar(divergence), error('Function only takes a scalar object'), end

angle = divergence.angle;
profile = divergence.profile;
[~,~,fwhh] = peak_cwhh_xye(angle,profile,[],0.5);
area = sum(profile);
theta_av = sum(angle.*profile)/area;
sigma = sqrt(sum(((angle-theta_av).*(angle-theta_av)).*profile)/area);
