function val = var_y (obj, varargin)
% Variance of width of absorption along the y-axis in detector(s) in a detector bank
%
%   >> val = var_y (obj, wvec)
%   >> val = var_y (obj, ind, wvec)
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
%   val         Variance of absorption along the y-axis (m^2)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


[~, ind] = parse_ind_wvec_ (obj.det, varargin{:});
val = var_y (obj.det, squeeze(obj.dmat(1,:,ind(:))), varargin{:});
