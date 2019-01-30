function obj = get_divergence (div,lam0)
% Get the divergence profile from interpolating a lookup table.
%
%   >> 
%
% Input:
% ------
%   div     Structure with fields:
%               angdeg  Column vector of angles (degrees)
%                       Must be equally spaced
%               lam     Coiumn vector of wavelengths (Angstroms)
%                       First and last points must be zeros
%               S       Array size [numel(div),numel(lam)] of fluxes
%
%   lam0    Wavelength at which to construct divergence profile. Must lie
%           within the range covered by div.lam (above)
%
% Output:
% -------
%   obj     Object of type IX_divergence_profile


ang = div.angdeg*(pi/180);  % angles in radians
lam = div.lam;
S = div.S;

% Check wavelength interpolates the data
if lam0<lam(1) || lam0>lam(end)
    error('The incident neutron wavelength lies outside the range of the divergence lookup table')
end

% Interpolate the profile, and normalise the distribution
profile = zeros(size(ang));
for i=1:numel(profile)
    profile(i) = interp1(lam, S(i,:), lam0, 'linear');
end
profile = (profile/sum(profile)) / mean(diff(ang));

obj = IX_divergence_profile (ang, profile);
