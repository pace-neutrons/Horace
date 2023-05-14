function val = mean_x (obj, varargin)
% Mean depth of absorption along the x-axis in detector(s) in a detector bank
%
%   >> val = mean_x (obj, wvec)
%   >> val = mean_x (obj, ind, wvec)
%
% Input:
% ------
%   obj         IX_detector_bank object
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
%   val         Mean point of absorption along the x-axis (m)
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


[~, ind] = parse_ind_wvec_ (obj.det, varargin{:});
val = mean_x (obj.det, squeeze(obj.dmat(1,:,ind(:))), varargin{:});
