function val = covariance (obj, npath_in, varargin)
% Covariance of points of absorption in a old Tobyfit approx to a 3He cylindrical tube
%
%   >> val = covariance (obj, npath, wvec)
%   >> val = covariance (obj, npath, ind, wvec)
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
%   val         Covariance of point of absorption in the detector frame (m^2)
%               The size is [3,3,sz] where sz is the shape of whichever of ind
%               or wvec is an array, and then the array is squeezed.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


cxx = var_x (obj, npath_in, varargin{:});
cyy = var_y (obj, npath_in, varargin{:});
czz = var_z (obj, npath_in, varargin{:});

val = zeros(3,3,numel(cxx));
val(1,1,:) = cxx(:);
val(2,2,:) = cyy(:);
val(3,3,:) = czz(:);

val = reshape(val, [3,3,size(cxx)]);
val = squeeze(val);
