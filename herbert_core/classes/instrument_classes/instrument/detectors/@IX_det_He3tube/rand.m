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
%               then npath is expanded internally to [3,n] array.
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
%   X           Array of random points in the detector coordinate frame(s).
%               The output is a stack of column 3-vectors, with the size of 
%               the stacking array being whichever of ind or wvec is an
%               array. A leading singleton dimension is squeezed away.
%
%               EAMPLES
%                   size(wvec) == [2,5]     ==> size(X) == [3,2,5]
%                   size(wvec) == [1,5]     ==> size(X) == [3,5]
%                   size(wvec) == [1,1,5]   ==> size(X) == [3,1,5]
%
%               Note:
%                 - if ind is a scalar, the calculation is performed for
%                  that value at each of the values of wvec
%                 - if wvec is a scalar, the calculation is performed for
%                  that value at each of the values of ind
%
%               If both ind and wvec are arrays, the shape is that of wvec.
%
%               A single random point X = [x,y,z]' is in the frame
%                   x   In range -R to R, where R is the inner radius of the tube,
%                       and the x axis is the projection of the neutron direction
%                       of travel perpendicular to the tube axis in the plane of
%                       the tube axis and direction of travel
%                   y   In range -R to R, where y is perpendicular to the
%                       x-axis and the tube axis.
%                   z   Along the direction of the tube axis


% Original author: T.G.Perring


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
sz_full = size_array_stack ([3,1], sz);
X = reshape(X, sz_full);


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
