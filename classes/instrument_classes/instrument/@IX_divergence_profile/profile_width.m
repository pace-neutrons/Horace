function [angle_sig, angle_av, fwhh] = profile_width (self, varargin)
% Return covariance matrix for the sample shape
%
%   >> [sigma, fwhh] = pulse_width (divergence)
%
% Input:
% ------
%   divergence  IX_divergence_profile object
%
% Output:
% -------
%   sigma       Standard deviation of profile width (radians)
%   angle_av    Average angle
%   fwhh        FWHH (radians)


if ~isscalar(self), error('Method only takes a scalar divergence profile object'), end

angle = self.angles_;
profile = self.profile_;
[~,~,fwhh] = peak_cwhh_xye(angle,profile,[],0.5);

area = sum(profile);
angle_av = sum(angle.*profile)/area;
sigma = sqrt(sum(((angle-angle_av).*(angle-angle_av)).*profile)/area);
disp(angle_av)
disp(sigma)

[angle_var, angle_av] = var (self.pdf_);
angle_sig = sqrt(angle_var);
