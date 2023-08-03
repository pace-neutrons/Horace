function X = rand (obj, varargin)
% Return an array of random points in the old Tobyfit approx to a 3He cylindrical tube detector
%
%   >> X = rand (obj, npath, wvec)
%   >> X = rand (obj, ind, npath, wvec)
%
% Input:
% ------
%   obj         IX_det_TobyfitClassic object
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet) as a row vector.
%
%   npath       Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Vector length 3 or an array size [3,n]
%               where n is the number of indices (see ind below). If a vector
%               then npath is expanded internally to [3,n] array.
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


[sz, ind] = parse_ind_npath_wvec_ (obj, varargin{:});

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

sz_full = size_array_stack ([3,1], sz);
X = reshape ([x;y;z], sz_full);
