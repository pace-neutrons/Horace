function val = func_eval (obj, func_handle, varargin)
% Evaluate a function for an array of detector indices and wavevector
%
%   >> X = func_eval (obj, func_handle, wvec)       % for default indices
%   >> X = func_eval (obj, func_handle, ind, wvec)  % specific indices
%
% Input:
% ------
%   obj         IX_detector_bank object
%
%   func_handle Function handle e.g. effic or mean, which follows one of
%               the syntax options:
%               	val = effic (obj, wvec)
%               	val = effic (obj, ind, wvec)
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
%   val         Array of output values.
%               The output is formed by stacking the output for each single
%               detector into a larger array, with the size of
%               the stacking array being whichever of ind or wvec is an
%               array.
%
%               Note:
%                 - if ind is a scalar, the calculation is performed for
%                  that value at each of the values of wvec
%                 - if wvec is a scalar, the calculation is performed for
%                  that value at each of the values of ind
%
%               If both ind and wvec are arrays, the shape is that of wvec


% Parse to get detector indices and wavevectors, and check consistency of sizes
[sz, ind, wvec] = parse_ind_wvec_ (obj.det, varargin{:});

% Unit vectors along the neutron path(s) in the detector coordinate frame(s)
npath = reshape (obj.dmat(1,:,ind(:)), [3,prod(sz)]);

% Compute the function for the detector(s)
val = func_handle (obj.det, ind, npath, wvec);
