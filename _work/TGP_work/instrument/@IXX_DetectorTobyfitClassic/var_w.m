function val = var_w (obj, varargin)
% Variance of width of absorbtion in a cylindrical tube
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
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


[ind, sz] = parse_ind_and_wvec_ (obj, varargin{:});

% Take full width of 0.6 of diameter
if ~isscalar(ind)
    val = reshape(obj.dia_(ind),sz) / sqrt(12);
else
    val = obj.dia_(ind)*ones(sz) / sqrt(12);
end
