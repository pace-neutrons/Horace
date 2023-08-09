function val = covariance (obj, varargin)
% Covariance of points of absorption in detector(s) in a detector array
%
%   >> val = covariance (obj, wvec)
%   >> val = covariance (obj, ind, wvec)
%
% Input:
% ------
%   obj         IX_detector_array object
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
%   val         Covariance of points of absorption in the detector frame(s) (m^2)
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


val = func_eval (obj, @covariance, varargin{:});
