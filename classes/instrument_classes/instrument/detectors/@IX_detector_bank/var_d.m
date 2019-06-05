function val = var_d (obj, varargin)
% Variance of depth of absorption in detector(s) in a detector bank
%
%   >> val = var_d (obj, wvec)
%   >> val = var_d (obj, ind, wvec)
%
% Note: this is along the neutron path
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
%   val         Variance of depth of absorption along the neutron path (m^2)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


[~, ind] = parse_ind_wvec_ (obj.det, varargin{:});
val = var_d (obj.det, squeeze(obj.dmat(1,:,ind(:))), varargin{:});
