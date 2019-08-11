function alf = macro_xs_thick (obj, npath, ind, wvec)
% Path length through a slab in multiples of the macroscopic absorption cross-section
%
%   >> alf = macro_xs_thick (obj, npath, ind, wvec)
%
% The thickness is divided by the cosine of the angle of the neutron path
% w.r.t. the face normal. That is, the return argument alf is distance through
% the slab along the neutron path in multiples of the macroscopic cross-section.
%
% Input:
% ------
%   obj         IX_det_slab object
%   npath       Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Array size [3,n] where n is the
%               number of indices (see ind below)
%   ind         Indices of detector elements. Scalar or array
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array
%
% If both ind and wvec are arrays, they must have the same number of elements
%
% Output:
% -------
%   alf         Thickness of the slab along the neutron path as a multiple
%              of the attenuation length.
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


% Define constant so that alf=const*atms*inner_rad(m)/(wvec*sintheta)
% (2200 m/s ==> wref=3.494157974647365)

wvec0 = 3.494157974647365;  % wvec at 2200 m/s

thickness = (obj.depth_(ind(:))./npath(1,:)') ./ obj.atten_(ind(:));

if isscalar(ind)
    alf = (wvec0 * thickness) ./ wvec;
    
elseif isscalar(wvec)
    alf = (wvec0/wvec) * reshape(thickness, size(ind));
    
else    % both non-scalar
    alf = wvec0 * reshape(thickness, size(wvec)) ./ wvec;
    
end
