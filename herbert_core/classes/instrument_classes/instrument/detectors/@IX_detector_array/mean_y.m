function val = mean_y (obj, varargin)
% Mean position of absorption along the y-axis in detector(s) in a detector array
%
%   >> val = mean_y (obj, wvec)
%   >> val = mean_y (obj, ind, wvec)
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
%   val         Mean point of absorption along the y-axis (m)
%               The shape is whichever of ind or wvec is an array.
%
%               Note:
%                 - if ind is a scalar, the calculation is performed for
%                  that value at each of the values of wvec
%                 - if wvec is a scalar, the calculation is performed for
%                  that value at each of the values of ind
%
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring


val = func_eval (obj, @mean_y, varargin{:});
