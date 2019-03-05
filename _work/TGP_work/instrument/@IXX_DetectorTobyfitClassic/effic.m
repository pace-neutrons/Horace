function val = effic (obj, varargin)
% Efficiency of a cylindrical tube
%
%   >> val = effic (obj, wvec)
%   >> val = effic (obj, ind, wvec)
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
%   val         Efficiency (in range 0 to 1) averaged across the width of
%              the tube(s).


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


[~, sz] = parse_ind_and_wvec_ (obj, varargin{:});
val = ones(sz);
