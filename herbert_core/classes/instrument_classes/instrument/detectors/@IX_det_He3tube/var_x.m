function val = var_x (obj, npath_in, varargin)
% Variance of depth of absorption in a 3He cylindrical tube perpendicular to axis
%
%   >> val = var_x (obj, npath, wvec)
%   >> val = var_x (obj, npath, ind, wvec)
%
% Input:
% ------
%   obj         IX_det_He3tube object
%
%   npath       Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Vector length 3 or an array size [3,n]
%               where n is the number of indices (see ind below). If a vector
%               then npath is expanded internally to [3,n] array
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet)
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%
% If both ind and wvec are arrays, then they must have the same number of elements
%
%
% Output:
% -------
%   val         Variance of depth of absorption perpedicular to the tube
%               axis (m^2)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


[~, npath, ind, wvec] = parse_npath_ind_wvec_ (obj, npath_in, varargin{:});
alf = macro_xs_dia (obj, npath, ind, wvec);

scale = obj.inner_rad(ind(:)).^2;
if ~isscalar(ind)
    scale = reshape(scale, size(alf));
end
val = scale .* var_d_alf(alf);

