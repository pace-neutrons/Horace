function val = mean (obj, varargin)
% Mean position of absorption in a 3He cylindrical tube
%
%   >> val = mean (obj, npath, wvec)
%   >> val = mean (obj, ind, npath, wvec)
%
% Input:
% ------
%   obj         IX_det_He3tube object
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet)
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
%   val         Mean depth of absorption in the detector frame (m)
%               The output is a stack of column 3-vectors, with the size of 
%               the stacking array being whichever of ind or wvec is an
%               array. A leading singleton dimension is squeezed away.
%
%               EXAMPLES
%                   size(wvec) == [2,5]     ==> size(val) == [3,2,5]
%                   size(wvec) == [1,5]     ==> size(val) == [3,5]
%                   size(wvec) == [1,1,5]   ==> size(val) == [3,1,5]
%
%               Note:
%                 - if ind is a scalar, the calculation is performed for
%                  that value at each of the values of wvec
%                 - if wvec is a scalar, the calculation is performed for
%                  that value at each of the values of ind
%
%               If both ind and wvec are arrays, the shape is that of wvec.


% Original author: T.G.Perring


mx = mean_x (obj, varargin{:});
my = mean_y (obj, varargin{:});
mz = mean_z (obj, varargin{:});

sz_full = size_array_stack ([3,1], size(mx));
val = reshape([mx(:)';my(:)';mz(:)'], sz_full);
