function val = var_d (obj, npath_in, varargin)
% Variance of depth of absorption in a slab detector along the neutron path
%
%   >> val = var_d (obj, npath, wvec)
%   >> val = var_d (obj, npath, ind, wvec)
%
% Input:
% ------
%   obj         IX_det_slab object
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
%   val         Variance of depth of absorption along the neutron path (m^2)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


[~,npath,ind,wvec] = parse_npath_ind_wvec_ (obj, npath_in, varargin{:});
alf = macro_xs_thick (obj, npath, ind, wvec);

thickness = (obj.depth_(ind(:))./npath(1,:)');
if ~isscalar(ind)
    thickness = reshape(thickness, size(alf));
end

val = (thickness.^2) .* var_d_alf(alf);
