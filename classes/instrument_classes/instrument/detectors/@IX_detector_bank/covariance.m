function val = covariance (obj, varargin)
% Covariance of points of absorption in detector(s) in a detector bank
%
%   >> val = covariance (obj, wvec)
%   >> val = covariance (obj, ind, wvec)
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
%   val         Covariance of points of absorption in the detector frame (m^2)
%               The size is [3,3,sz] where sz is the shape of whichever of ind
%               or wvec is an array, and then the array is squeezed.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


[~, ind] = parse_ind_wvec_ (obj.det, varargin{:});
val = covariance (obj.det, squeeze(obj.dmat(1,:,ind(:))), varargin{:});
