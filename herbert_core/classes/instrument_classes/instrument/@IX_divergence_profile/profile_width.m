function [angle_sig, angle_av, fwhh] = profile_width (self)
% Return covariance matrix for the sample shape
%
%   >> [angle_sig, angle_av, fwhh] = profile_width (divergence)
%
% Input:
% ------
%   divergence  IX_divergence_profile object
%
% Output:
% -------
%   angle_sig   Standard deviation of profile width (radians)
%   angle_av    Average angle (radians)
%   fwhh        FWHH (radians)


if ~isscalar(self), error('Method only takes a scalar divergence profile object'), end

angle = self.angles_;
profile = self.profile_;
[~,~,fwhh] = peak_cwhh_xye(angle,profile,[],0.5);

[angle_var, angle_av] = var (self.pdf_);
angle_sig = sqrt(angle_var);
