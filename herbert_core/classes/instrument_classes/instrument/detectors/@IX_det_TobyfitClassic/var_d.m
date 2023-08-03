function val = var_d (obj, varargin)
% Variance of depth of absorption in the old Tobyfit approx to a 3He cylindrical tube along the neutron path
%
%   >> val = var_d (obj, npath, wvec)
%   >> val = var_d (obj, ind, npath, wvec)
%
% Input:
% ------
%   obj         IX_det_TobyfitClassic object
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet) as a row vector.
%
%   npath       Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Vector length 3 or an array size [3,n]
%               where n is the number of indices (see ind below). If a vector
%               then npath is expanded internally to [3,n] array.
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%               If both ind and wvec are arrays, then they must have the same
%               number of elements, but not necessarily the same shape.
%
%
% Output:
% -------
%   val         Variance of depth of absorption along the neutron path (m^2)
%               The shape is whichever of ind or wvec is an array.
%
%               Note:
%                 - if ind is a scalar, the calculation is performed for
%                  that value at each of the values of wvec
%                 - if wvec is a scalar, the calculation is performed for
%                  that value at each of the values of ind
%
%               If both ind and wvec are arrays, the shape is that of wvec.


% Original author: T.G.Perring


[sz, ind] = parse_ind_npath_wvec_ (obj, varargin{:});

% Take full width of 15mm from a diameter of 25.4mm for consistency with Tobyfit Classic
fac = 75/127;

depth = fac * obj.dia_(ind(:));
if ~isscalar(ind)
    val = (reshape(depth, sz).^2)/12;
else
    val = ((depth.^2)/12) * ones(sz);
end
