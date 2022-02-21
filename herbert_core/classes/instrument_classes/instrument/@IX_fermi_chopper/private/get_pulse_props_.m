function [pk_fwhh, gam] = get_pulse_props_ (obj, ei, phase)
% Get the FWHH for optimal incident energy, and gamma
%
%   >> [pk_fwhh, gam] = get_pulse_props_ (obj, ei, phase)
%
% Input:
% ------
%   obj     IX_fermi_chopper object (scalar instance)
%
%   ei      Neutron energy (meV) (scalar or array)
%           Overrides the proeprty value in obj
%
%   phase   If true, optimally phased; if false, 180 degrees out of phase
%           Overrides the proeprty value in obj
%
% Output:
% -------
%   pk_fwhh FWHH at energy and phase corresponding to maximum
%           transmission (seconds) (scalar)
%
%   gam     Array with size of ei; dimensionless quantity (>=0)
%
%
% See T.G.Perring Ph.D. thesis for details


if obj.slit_width_==0 && obj.radius_==0 && obj.frequency_==0 && ...
        obj.curvature_==0
    % Special case of the null chopper
    % If all the chopper parameters are zero, then we take this to permit
    % a delta function pulse shape independent of neutron energy. This is
    % so that the default constructor permits transmission, but does not
    % correspond to a special set i.e. a parochial set of parameters
    pk_fwhh = 0;
    gam = 0;
    
else
    % One or more chopper parameters have been set
    vi = 1e6 * sqrt(ei) / obj.c_e_to_t_;           % incident velocity (m/s)
    
    omega=2*pi*obj.frequency_;
    s=2*omega*obj.curvature_;
    pk_fwhh=obj.slit_width_/(2*obj.radius_*omega);
    
    if phase
        gam=(2*obj.radius_/pk_fwhh)*abs(1/s-1./vi);
    else
        gam=(2*obj.radius_/pk_fwhh)*abs(1/s+1./vi);
    end
    
    % Case of delta function transmission
    if pk_fwhh==0
        gam(vi==s) = 0;
    end
    
end

end
