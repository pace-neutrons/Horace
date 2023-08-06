function val = effic (obj, varargin)
% Efficiency of a 3He cylindrical tube
%
%   >> val = effic (obj, npath_in, wvec)
%   >> val = effic (obj, ind, npath_in, wvec)
%
% Input:
% ------
%   obj         IX_det_He3tube object
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
%   val         Efficiency (in range 0 to 1).
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


[~, ind, npath, wvec] = parse_ind_npath_wvec_ (obj, varargin{:});
alf = macro_xs_dia (obj, ind, npath, wvec);

val = effic_alf (alf);
