function val = del_d (obj, varargin)
% Mean depth of absorption in a 3He cylindrical tube along the neutron path
%
%   >> val = del_d (obj, wvec)
%   >> val = del_d (obj, ind, wvec)
%
% Note: this is along the neutron path, not perpendicular to the tube axis
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
%   val         Mean depth of aborption with respect to axis of tube (m)


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)


[ind, wvec] = parse_ind_and_wvec_ (obj, varargin{:});
alf = macro_xs_dia (obj, ind, wvec);

if ~isscalar(ind)
    scale = reshape(obj.inner_rad(ind)./obj.sintheta_(ind), size(alf));
else
    scale = obj.inner_rad(ind)/obj.sintheta_(ind);
end
val = scale .* del_d_alf(alf);

