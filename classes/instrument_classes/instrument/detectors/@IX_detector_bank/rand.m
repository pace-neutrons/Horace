function X = rand (obj, varargin)
% Return an array of random points in detector(s) in a detector bank
%
%   >> X = rand (obj, wvec)
%   >> X = rand (obj, ind, wvec)
%
% Input:
% ------
%   obj         IX_detector_bank object
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
%   X           Array of random points in the detector coordinate frame.
%               The size of the array is [3,size(ind)] with any singleton
%              dimensions in sz squeezed away


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


[~, ind] = parse_ind_wvec_ (obj.det, varargin{:});
X = rand (obj.det, squeeze(obj.dmat(1,:,ind(:))), varargin{:});
