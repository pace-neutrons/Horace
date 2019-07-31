function val = var_w (obj, varargin)
% Variance of width of absorption in a cylindrical tube
%
%   >> val = var_w (obj, wvec)
%   >> val = var_w (obj, ind, wvec)
%
% Input:
% ------
%   obj         IX_He3tube object
%
%   ind         Indicies of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet)
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%
% If both ind and wvec are arrays, then they must have the same number of elements
%
%
% Output:
% -------
%   val         Variance of width of aborption (m^2)


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


[ind, sz] = parse_ind_and_wvec_ (obj, varargin{:});

% Take full width of 0.6 of diameter
if ~isscalar(ind)
    val = reshape(obj.dia_(ind),sz) / sqrt(12);
else
    val = obj.dia_(ind)*ones(sz) / sqrt(12);
end

