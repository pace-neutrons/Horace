function val = mean_y (obj, varargin)
% Mean position of absorption in a 3He cylindrical tube along the y-axis
%
%   >> val = mean_y (obj, npath, wvec)
%   >> val = mean_y (obj, ind, npath, wvec)
%
% Input:
% ------
%   obj         IX_det_He3tube object
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet) as a row vector.
%
%   npath       Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Vector length 3 or an array size [3,n]
%               where n is the number of indices (see ind below). If a vector
%               then npath is expanded internally to [3,n] array.
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               If both ind and wvec are arrays, then they must have the same
%               number of elements, but not necessarily the same shape.
%
%
% Output:
% -------
%   val         Mean point of absorption perpendicular to the axis of tube
%               and the direction of travel of the neutron (m)
%               The shape is whichever of ind or wvec is an array.
%
%               Note:
%                 - if ind is a scalar, the calculation is performed for
%                  that value at each of the values of wvec
%                 - if wvec is a scalar, the calculation is performed for
%                  that value at each of the values of ind
%
%               If both ind and wvec are arrays, the shape is that of wvec.


% Original author: T.G.Perring


sz = parse_ind_npath_wvec_ (obj, varargin{:});
val = zeros(sz);
