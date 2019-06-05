function val = mean_z (obj, varargin)
% Mean position of absorption aloing the z-axis in detector(s) in a detector bank
%
%   >> val = mean_z (obj, wvec)
%   >> val = mean_z (obj, ind, wvec)
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
%   val         Mean point of absorption along the z-axis (m)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


[~, ind] = parse_ind_wvec_ (obj.det, varargin{:});
val = mean_z (obj.det, squeeze(obj.dmat(1,:,ind(:))), varargin{:});
