function X = rand (obj, npath_in, varargin)
% Return an array of random points in a old Tobyfit approx to a 3He cylindrical tube detector
%
%   >> X = rand (obj, npath, wvec)
%   >> X = rand (obj, npath, ind, wvec)
%
% Input:
% ------
%   obj         IX_det_TobyfitClassic object
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


[sz, ~, ind] = parse_npath_ind_wvec_ (obj, npath_in, varargin{:});

% Take full width of 0.6 of diameter for depth; the diameter as FWHH for width
% Actually, we have always used dia = 25.4mm in the detector parameter files
% in cuts passed Tobyfit, but Tobyfit had 15mm hardwired in the code as the
% effective FWHH. So in fact, the factor is not 0.6 to convert, but (15/25.4)
% i.e. factor of 75/127
fac = 75/127;   % to get 15mm from a diameter of 25.4mm

n = prod(sz);
if ~isscalar(ind)
    x = reshape(fac*obj.dia_(ind),[1,n]) .* (rand(1,n)-0.5);
    y = reshape(obj.dia_(ind),[1,n]) .* (rand(1,n)-0.5);
    z = reshape(obj.height_(ind),[1,n]) .* (rand(1,n)-0.5);
else
    x = fac*obj.dia_(ind) * (rand(1,n)-0.5);
    y = obj.dia_(ind) * (rand(1,n)-0.5);
    z = obj.height_ * (rand(1,n)-0.5);
end

X = squeeze(reshape([x;y;z],[3,sz]));
