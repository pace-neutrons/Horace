function [J0_ff,varargout] = getInterpolant(IonName)
% Method returns set of functions handles used to
% calculate magnetic form factor in up to sextupole
% approximation. Some ions have all coefficients of six order
% momentum equal to zero.
%
%>> Usage:
%
%>>[J0_ff,J2_ff]=MagneticIons.getInterpolant('Fe0')
% or
%>>[J0_ff,J2_ff,J4_ff]=MagneticIons.getInterpolant('Fe0')
% or
%>>[J0_ff,J2_ff,J4_ff,J6_ff]=MagneticIons.getInterpolant('Fe3')
%
% Returns functions, calculating magnetic moment of Fe0 ion
% up to the sextupole approximation. (all odd decomposition terms
% are 0 so naturally not returned)
%
% The functions depend on Q^2 in angstroms^(-1) and
% magnetic form-factor observed in neutron experiments
% in reciprocal point of space Q (expressed in reverse
% angstroms) can be calculated by the formula:
%
%e.g.:
%>>FF=J0_ff(Q2).^2+J2_ff(Q2).^2;
%  where Q2==Q.*Q (without 4*pi^2 factor)  and J0_ff calculates magnetic
%  form factor in zero and J2_ff -- dipole approximation correspondingly
%
%
par = MagneticIons.IonParMap_(IonName);

%ion            A      a     B      b     C      c     D
%J0_ff = @(x2)((A*exp(-a*x2)+B*exp(-b*x2)+C*exp(-c*x2)+D));

J0_ff = @(x2)((par(1,1)*exp(-par(1,2)*x2)+par(1,3)*exp(-par(1,4)*x2)+par(1,5)*exp(-par(1,6)*x2)+par(1,7)));
if nargout>1
    for i=1:nargout-1
        varargout{i}=@(x2)(((par(i+1,1)*exp(-par(i+1,2)*x2)+par(i+1,3)*exp(-par(i+1,4)*x2)+par(i+1,5)*exp(-par(i+1,6)*x2)+par(i+1,7)).*x2));
    end
end
