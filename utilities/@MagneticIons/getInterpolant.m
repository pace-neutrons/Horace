function [J0_ff,varargout] = getInterpolant(self,IonName)
% Method returns set of functions handles used to
% calculate magnetic form factor in up to sextupole
% approximation. Some ions have all coefficients of six order
% momentum equal to zero.
%
%>> Usage:
%>>mi = MagneticIons('Fe0');
%>>[J0_ff,J2_ff]=mi.getInterpolant()
% or 
%>>[J0_ff,J2_ff,J4_ff]=mi.getInterpolant()
% or
%>>[J0_ff,J2_ff,J4_ff,J6_ff]=mi.getInterpolant()
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
%  where Q2==Q.*Q and J0_ff calculates magnetic form factor in zero and
%  J2_ff -- dipole approximation correspondingly
%
%
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
%

%
if ~exist('IonName','var')
    IonName = self.currentIon;
end
par = self.IonParMap_(IonName);

%ion            A      a     B      b     C      c     D
%J0_ff = @(x2)((A*exp(-a*x2)+B*exp(-b*x2)+C*exp(-c*x2)+D));

J0_ff = @(x2)((par(1,1)*exp(-par(1,2)*x2)+par(1,3)*exp(-par(1,4)*x2)+par(1,5)*exp(-par(1,6)*x2)+par(1,7)));
if nargout>1
    for i=1:nargout-1
        varargout{i}=@(x2)(((par(i+1,1)*exp(-par(i+1,2)*x2)+par(i+1,3)*exp(-par(i+1,4)*x2)+par(i+1,5)*exp(-par(i+1,6)*x2)+par(i+1,7)).*x2));
    end
end


