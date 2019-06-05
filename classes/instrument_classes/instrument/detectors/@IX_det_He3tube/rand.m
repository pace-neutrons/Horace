function X = rand (obj, npath_in, varargin)
% Return an array of random points in a 3He cylindrical tube detector
%
%   >> X = rand (obj, npath, wvec)
%   >> X = rand (obj, npath, ind, wvec)
%
% Input:
% ------
%   obj         IX_det_He3tube object
%
%   npath       Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Vector length 3 or an array size [3,n]
%               where n is the number of indices (see ind below). If a vector
%               then npath is expanded internally to [3,n] array
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
%   X           Array of random points.
%               The size of the array is [3,size(ind)] with any singleton
%              dimensions in sz squeezed away
%               A single random point X = [x,y,z]' is in the frame
%                   x   In range -R to R, where R is the inner radius of the tube,
%                       and the x axis is the projection of the neutron direction
%                       of travel perpendicular to the tube axis in the plane of
%                       the tube axis and direction of travel
%                   y   In range -R to R, where y is perpendicular to the
%                       x-axis and the tube axis.
%                   z   Along the direction of the tube


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


[sz, npath, ind, wvec] = parse_npath_ind_wvec_ (obj, npath_in, varargin{:});
alf = macro_xs_dia (obj, npath, ind, wvec);

% Reduced units
[x,y] = rand_xy2 (alf(:));  

% Convert to true units
% (Note that we do not need to multiply by cosine to project perpendicular
% to the tube axis, as this projection is implicit when multiply by
% just inner_rad)
inner_rad = obj.inner_rad(ind(:));
X = [(inner_rad .* (2*x - sqrt(1-y.^2)))';...
    (inner_rad .* y)';...
    (obj.height_(ind(:)) .* (rand(numel(alf),1)-0.5))'];
X = reshape(X,[3,sz]);
X = squeeze(X);


%--------------------------------------------------------------------------
function [x,y] = rand_xy2(alf)
% Random points in the absorbing ellipsoid unit semi-major axis perpendicular
% to flightpath, and semi-major axis along the flightpath of alf/2
x = rand_truncexp2 (alf) ./ alf;
y = 2*rand(size(alf)) - 1;
reject = (x.^2 >= 1-y.^2);
if sum(reject(:))>0
    [x(reject),y(reject)]=rand_xy2(alf(reject));
end
