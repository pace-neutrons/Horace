function val = var_d (obj, npath_in, varargin)
% Variance of depth of absorption in a old Tobyfit approx to a 3He cylindrical tube along the neutron path
%
%   >> val = var_d (obj, npath, wvec)
%   >> val = var_d (obj, npath, ind, wvec)
%
% Note: this is along the neutron path, not perpendicular to the tube axis
%
% Input:
% ------
%   obj         IX_det_TobyfitClassic object
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
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


[sz, ~, ind] = parse_npath_ind_wvec_ (obj, npath_in, varargin{:});

% Take full width of 15mm from a diameter of 25.4mm for consistency with Tobyfit Classic
fac = 75/127;

depth = fac * obj.dia_(ind(:));
if ~isscalar(ind)
    val = (reshape(depth, sz).^2)/12;
else
    val = ((depth.^2)/12) *ones(sz);
end
