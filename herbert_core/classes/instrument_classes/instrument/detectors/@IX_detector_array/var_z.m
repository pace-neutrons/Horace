function val = var_z (obj, varargin)
% Variance of height of absorption along the z-axis in detector(s) in a detector array
%
%   >> val = var_z (obj, wvec)
%   >> val = var_z (obj, ind, wvec)
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
%   val         Variance of absorption along the z-axis(m^2)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


if ~isscalar(obj)
    error('Only operates on a single detector array object (i.e. object must be scalar');
end

val = func_eval (obj.det_bank_, @var_z, {'wvec'}, varargin{:});

