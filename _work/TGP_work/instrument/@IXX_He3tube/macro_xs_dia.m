function alf = macro_xs_dia (obj, ind, wvec)
% Path length through a 3He tube in multiples of the macroscopic absorption cross-section
%
%   >> alf = macro_xs_dia (this, ind, wvec)
%
% The diameter is divided by the sin of the angle of the neutron path
% w.r.t. the tube axis. That is, the return argument alf is distance through
% the tube along the neutron path in multiples of the macroscopic cross-section.
%
% Input:
% ------
%   obj         IX_He3tube object
%   ind         Indicies of detector elements. Scalar or array
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array
%
% If both ind and wvec are arrays, they must have the same number of elements
%
% Output:
% -------
%   alf         Inner diameter of tube as a multiple of the macroscopic
%              absorption cross-section.
%               If both ind and wvec are arrays, the shape is that of wvec
%
%
% Origin of data for 3He cross-section
% -------------------------------------
% TGP took data from an approximate function for the efficieny of a tube
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
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)


% Define constant so that alf=const*atms*inner_rad(m)/(wvec*sintheta)
% (sigref=143.23; wref=3.49416; atmref=10; const=2*sigref*wref/atmref;)


const = 1.000937073600000e+02;
if isscalar(ind)
    alf = (const * obj.inner_rad(ind) * obj.atms_(ind) / obj.sintheta_(ind)) ./ wvec;
    
elseif isscalar(wvec)
    alf = (const/wvec) *...
        reshape(obj.inner_rad(ind).*obj.atms_(ind)./obj.sintheta_(ind), size(ind));
    
else    % both non-scalar
    alf = (const *...
        reshape(obj.inner_rad(ind).*obj.atms(ind)./obj.sintheta_(ind), size(wvec))) ./ wvec;
    
end

