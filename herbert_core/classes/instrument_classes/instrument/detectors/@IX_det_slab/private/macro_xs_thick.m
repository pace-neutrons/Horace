function [alf, atten] = macro_xs_thick (obj, ind, npath, wvec)
% Path length through a slab in multiples of the macroscopic absorption cross-section
%
%   >> alf = macro_xs_thick (obj, ind, npath, wvec)
%
% The thickness is divided by the cosine of the angle of the neutron path
% w.r.t. the face normal. That is, the return argument alf is distance through
% the slab along the neutron path in multiples of the macroscopic cross-section.
%
% Input:
% ------
%   obj         IX_det_slab object
%   ind         Indices of detector elements. Scalar or array
%   npath       Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Array size [3,n] where n is the
%               number of indices (see ind below)
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
%
%   atten       Attenuation distance.
%               The shape is the same as alf.


% Original author: T.G.Perring


% Define constant so that alf=const*atms*inner_rad(m)/(wvec*sintheta)
% (2200 m/s ==> wref=3.494157974647365)

wvec0 = 3.494157974647365;  % wvec at 2200 m/s

% Thickness along neutron path in multiples of attenuation length(s) at 2200 m/s
atten0 = obj.atten_(ind(:));
thickness = (obj.depth_(ind(:))./npath(1,:)') ./ atten0;

% Convert to thickness at the input wavevector(s)
if isscalar(ind)
    % atten0 and thickness are both scalar; wvec may be scalar or array
    alf = (wvec0 * thickness) ./ wvec;
    atten = wvec * (atten0 / wvec0);
    
elseif isscalar(wvec)
    % atten0 and thickness will be arrays (scalar case already caught above)
    alf = (wvec0/wvec) * reshape(thickness, size(ind));
    atten = (wvec/wvec0) * reshape(atten0, size(ind));
    
else
    % Both non-scalar
    alf = wvec0 * (reshape(thickness, size(wvec)) ./ wvec);
    atten = (wvec .* reshape(atten0, size(wvec))) / wvec0;
    
end
