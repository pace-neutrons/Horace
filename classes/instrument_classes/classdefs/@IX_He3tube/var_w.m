function val = var_w (obj, wvec, sintheta)
% Variance of width of absorbtion in a 3He cylindrical tube
%
%   >> val = var_w (obj, wvec)
%   >> val = var_w (obj, wvec, sintheta)
%
% Input:
% ------
%   obj         IX_He3tube object
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array
%   sintheta    [Optional] Sine of the angle between the cylinder axis and
%              the direction of travel of the neutron i.e. sintheta=1 when
%              the neutron hits the detector perpendicular to the tube
%              axis. Scalar or array.
%               Default: sintheta=1 (i.e. beam perpendicular to cylinder)
%
%   Note: either or both of wvec and sintheta can be arrays, but if both
%   are arrays then they must have the same size and shape.
%
% Output:
% -------
%   val         Variance of width of aborption (m^2)


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


alf = macro_xs_dia (obj, wvec);
if nargin==3
    alf = alf./sintheta;
end

val = (obj.inner_rad^2) * var_w(alf);
