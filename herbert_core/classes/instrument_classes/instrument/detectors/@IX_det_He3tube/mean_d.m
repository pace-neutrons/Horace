function val = mean_d (obj, npath_in, varargin)
% Mean depth of absorption in a 3He cylindrical tube along the neutron path
%
%   >> val = mean_d (obj, npath, wvec)
%   >> val = mean_d (obj, npath, ind, wvec)
%
% Note: this is along the neutron path, not perpendicular to the tube axis
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
%   val         Mean depth of absorption along the neutron path with respect
%               to axis of tube (m)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


[~, npath, ind, wvec] = parse_npath_ind_wvec_ (obj, npath_in, varargin{:});
alf = macro_xs_dia (obj, npath, ind, wvec);

scale = obj.inner_rad(ind(:))./npath(1,:)';
if ~isscalar(ind)
    scale = reshape(scale, size(alf));
end
val = scale .* mean_d_alf(alf);

