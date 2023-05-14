function val = covariance (obj, npath_in, varargin)
% Covariance of points of absorption in a 3He cylindrical tube
%
%   >> val = covariance (obj, npath, wvec)
%   >> val = covariance (obj, npath, ind, wvec)
%
% Input:
% ------
%   obj         IX_det_He3tube object
%
%   npath       Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Vector length 3 or an array size [3,n]
%               where n is the number of indices (see ind below). If a vector
%               then npath is expanded internally to [3,n] array.
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet) as a row vector.
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               If both ind and wvec are arrays, then they must have the same
%               number of elements, but not necessarily the same shape.
%
%
% Output:
% -------
%   val         Covariance of point of absorption in the detector frame(s) (m^2)
%               The output is a stack of 3x3 matrices, with the size of 
%               the stacking array being whichever of ind or wvec is an
%               array. Up to two leading singleton dimension are squeezed 
%               away.
%
%               EXAMPLES
%                   size(wvec) == [2,5]     ==> size(val) == [3,3,2,5]
%                   size(wvec) == [1,5]     ==> size(val) == [3,3,5]
%                   size(wvec) == [1,1,5]   ==> size(val) == [3,3,5]
%                   size(wvec) == [1,1,1,5] ==> size(val) == [3,3,1,5]
%
%               Note:
%                 - if ind is a scalar, the calculation is performed for
%                  that value at each of the values of wvec
%                 - if wvec is a scalar, the calculation is performed for
%                  that value at each of the values of ind
%
%               If both ind and wvec are arrays, the shape is that of wvec.


% Original author: T.G.Perring


cxx = var_x (obj, npath_in, varargin{:});
cyy = var_y (obj, npath_in, varargin{:});
czz = var_z (obj, npath_in, varargin{:});

val = zeros(3,3,numel(cxx));
val(1,1,:) = cxx(:);
val(2,2,:) = cyy(:);
val(3,3,:) = czz(:);

val = reshape(val, [3,3,size(cxx)]);
val = squeeze(val);
