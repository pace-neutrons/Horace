function X = rand (obj, npath_in, varargin)
% Return an array of random points in a slab detector
%
%   >> X = rand (obj, npath, wvec)
%   >> X = rand (obj, npath, ind, wvec)
%
% Input:
% ------
%   obj         IX_det_slab object
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
%                   x   In range -depth/2 to +depth/2, where depth is the full
%                       thickness of the detector mperpendicular to the face
%                   y   In range -width/2 to width/2
%                   z   In range -height/2 to height/2


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


[sz,npath,ind,wvec] = parse_npath_ind_wvec_ (obj, npath_in, varargin{:});
alf = macro_xs_thick (obj, npath, ind, wvec);

xscalefactor = (obj.atten_(ind(:)).*npath(1,:)');
thickness = obj.depth_(ind(:));
width = obj.width_(ind(:));
height = obj.height_(ind(:));

X = [xscalefactor.*rand_truncexp2 (alf(:)') - 0.5*thickness;...
    width.*(rand(1,prod(sz))-0.5);...
    height.*(rand(1,prod(sz))-0.5)];
X = reshape(X,[3,sz]);
X = squeeze(X);
