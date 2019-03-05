function val = var_d (obj, varargin)
% Variance of depth of absorbtion in a cylindrical tube along the neutron path
%
%   >> val = var_d (obj, wvec)
%   >> val = var_d (obj, ind, wvec)
%
% Note: the neutron path is assumed to be perpendicular to the tube axis
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
%   val         Variance of depth of aborption (m^2)


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


[ind, sz] = parse_ind_and_wvec_ (obj, varargin{:});

% Take full width of 0.6 of diameter
if ~isscalar(ind)
    val = reshape(0.6*obj.dia_(ind),sz) / sqrt(12);
else
    val = 0.6*obj.dia_(ind)*ones(sz) / sqrt(12);
end
