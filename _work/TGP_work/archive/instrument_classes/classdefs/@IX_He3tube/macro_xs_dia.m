function alf = macro_xs_dia (obj, wvec)
% Diameter of a 3He tube in multiples of the macroscopic absorption cross-section
%
%   >> alf = macro_xs_dia (this, wvec)
%   >> alf = macro_xs_dia (this, wvec, sintheta)
%
% Input:
% ------
%   obj         IX_He3tube object
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array
%
% Output:
% -------
%   alf         Inner diameter of tube as a multiple of the macroscopic
%              absorption cross-section
%
%
% Origin of data for 3He cross-section
% -------------------------------------
% TGP took data from an apprixoimate function for the efficieny of a tube
% due to C.K.Loong, in c. 1990.
%
%  CKL data : (Argonne)
%   "At 2200 m/s xsect=5327 barns    En=25.415 meV         "
%   "At 10 atms, rho_atomic=2.688e-4,  so sigma=1.4323 cm-1"
%
%  These data are not quite consistent, but the errors are small :
%    2200 m/s = 25.299 meV
%    5327 barns & 1.4323 cm-1 ==> 10atms ofideal gas at 272.9K
%   but at what temperature are the tubes "10 atms" ?
%
%  Shall use  1.4323 cm-1 @ 3.49416 A-1 with sigma proportional to 1/v
%
%  This corresponds to a reference energy of 25.299meV, NOT 25.415.
% This accounts for a difference of typically 1 pt in 1000 for
% energies around a few hundred meV.


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


% Define constant so that alf=const*atms*inner_rad(m)/(wvec*sintheta)
% (sigref=143.23; wref=3.49416; atmref=10; const=2*sigref*wref/atmref;)

const = 1.000937073600000e+02 * obj.inner_rad * obj.atms;
alf = const./wvec;
