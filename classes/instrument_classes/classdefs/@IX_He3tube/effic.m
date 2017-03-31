function val = effic (obj, wvec, sintheta)
% Efficiency of a 3He cylindrical tube
%
%   >> val = effic (obj, wvec)
%   >> val = effic (obj, wvec, sintheta)
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
%   val         Efficiency (in range 0 to 1) averaged across the width of
%              the tube.


% Original author: T.G.Perring
%
% $Revision: 1019 $ ($Date: 2015-07-16 12:20:46 +0100 (Thu, 16 Jul 2015) $)


alf = macro_xs_dia (obj, wvec);
if nargin==3
    alf = alf./sintheta;
end

val=effic(alf);
