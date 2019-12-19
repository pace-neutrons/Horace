function pix = transform_pix (obj, upix_to_rlu, upix_offset, pix_in)
% Transform pixel coordinates into symmetry related coordinates
%
% The transformation converts the components of a vector which is 
% related by the symmetry operation into the equivalent vector. For example,
% if the symmetry operation is a rotation by 90 degrees about
% [0,0,1] in a cubic lattice with lattice parameter 2*pi, the point [0.3;0.1;2]
% is transformed into [0.1;-0.3;2].
%
%   >> pix = transform_pix (obj, upix_to_rlu, upix_offset, pix_in)
%
% Input:
% ------
%   obj         Symmetry operator or array of symmetry operators
%               If an array, then they are applied in order obj(1), obj(2),...
%
%   upix_to_rlu Matrix to convert components of a vector in pixel coordinate
%              frame (which is an orthonormal frame) into rlu (3x3 matrix)
%
%   upix_offset Offset of origin of pixel coordinate frame (rlu) (vector length 3)
%
%   pix_in      Pixel coordinates (3 x n array).
%
% Output:
% -------
%   pix_out     Transformed pixel array (3 x n array).


% Check input
if numel(size(upix_to_rlu))~=2 || ~all(size(upix_to_rlu)==[3,3])
    error('Check upix_to_rlu is a 3x3 matrix')
elseif ~(numel(upix_offset)==3 || numel(upix_offset)==4)
    error('Check upix_offset is a vector length 3')
end

% Get transformation
n = numel(obj);
if n<1
    error('Empty symmetry operation object array')
end
Minv = upix_to_rlu(1:3,1:3)\eye(3);  % seems to be slightly better than inv(M)
Rtot = calculate_transform (obj(n), Minv);
Om = offset (Rtot, Minv, upix_offset(1:3), obj(n).uoffset_(:));
for i=n-1:-1:1
    R = calculate_transform (obj(i), Minv);
    O = offset (R, Minv, upix_offset(1:3), obj(i).uoffset_(:));
    Rtot = Rtot * R;
    Om = R\Om + O;
end

% Transform pixels
pix = bsxfun (@plus, Rtot\pix_in, Om);     % bsxfun not needed for 2016b and later

%------------------------------------------------------------------------------
function O = offset (R, Minv, upix_offset, usym_offset)
dp = Minv*(usym_offset - upix_offset(:));
O = dp - R\dp;
