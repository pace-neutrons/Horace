function [pk_fwhh, gam] = get_pulse_props_ (self, ei, phase)
% Get the FWHH for optimal incident energy, and gamma
%
%   pk_fwhh     Scalar; unit is seconds
%   gam         Array with size of ei; dimensionless quantity (>=0)
%
% See T.G.Perring Ph.D. thesis for details

vi=1e6*sqrt(ei)/self.c_e_to_t_;           % incident velocity (m/s)

omega=2*pi*self.frequency_;
s=2*omega*self.curvature_;
pk_fwhh=self.slit_width_/(2*self.radius_*omega);

if phase
    gam=(2*self.radius_/pk_fwhh)*abs(1/s-1./vi);
else
    gam=(2*self.radius_/pk_fwhh)*abs(1/s+1./vi);
end
