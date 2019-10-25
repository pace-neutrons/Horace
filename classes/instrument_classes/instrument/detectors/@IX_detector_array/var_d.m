function val = var_d (obj, varargin)
% Variance of depth of absorption in detector(s) in a detector array
%
%   >> val = var_d (obj, wvec)
%   >> val = var_d (obj, ind, wvec)
%
% Note: this is along the neutron path
%
% Input:
% ------
%   obj         IX_detector_array object
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
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


if ~isscalar(obj)
    error('Only operates on a single detector array object (i.e. object must be scalar');
end

val = func_eval (obj.det_bank_, @var_d, {'wvec'}, varargin{:});
