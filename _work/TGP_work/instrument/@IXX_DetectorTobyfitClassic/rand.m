function X = rand (obj, varargin)
% Return an array of random points in a 3He cylindrical detector
%
% Scalar wvec and sintheta:
%   >> X = rand (obj, wvec)
%   >> X = rand (obj, ind, wvec)
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
%   X           Array of random points.
%               The size of the array is [3,size(ind)]. with any singleton
%              dimensions in sz squeezed away
%               A single random point X = [x,y,z]' are in the frame
%                   x   In range -R to R, where R is the inner radius of the tube,
%                       and the x axis is the projection of the neutron direction
%                       of travel perpendicular to the tube axis in the plane of
%                       the tube axis and direction of travel
%                   y   In range -R to R, where y is perpendicular to the
%                       x-axis and the tube axis.
%                   z   Along the direction of the tube


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


[ind, sz] = parse_ind_and_wvec_ (obj, varargin{:});

% Take full width of 0.6 of diameter for depth; the diameter as FWHH for width
n = prod(sz);
if ~isscalar(ind)
    x = reshape(0.6*obj.dia_(ind),[1,n]) .* (rand(1,n)-0.5);
    y = reshape(obj.dia_(ind),[1,n]) .* (rand(1,n)-0.5);
    z = reshape(obj.height_(ind),[1,n]) .* (rand(1,n)-0.5);
else
    x = 0.6*obj.dia_(ind) * (rand(1,n)-0.5);
    y = obj.dia_(ind) * (rand(1,n)-0.5);
    z = obj.height_ * (rand(1,n)-0.5);
end

X = squeeze(reshape([x;y;z],[3,sz]));

