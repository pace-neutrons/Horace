function pix = transform_pix (obj, upix_to_rlu, upix_offset, pix_in)
% Transform pixels into symmetry related coordinates
%
%   >> pix = transform_pix (obj, upix_to_rlu, upix_offset, pix_in)
%
% Input:
% ------
%   obj         Symmetry operator or array of symmetry operators
%               If an array, then they are applied in order obj(1), obj(2),...
%
%   upix_to_rlu Matrix to convert components of a vector in pixel coordinate
%              frame into rlu
%
%   upix_offset Offset of origin of pixel coordinate frame (rlu)
%
%   pix_in      Pixel coordinates 3 x n array
%
% Output:
% -------
%   pix_out     Transformed pixel array.

% Get transformation
n = numel(obj);
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
dp = Minv*(usym_offset - upix_offset);
O = dp - R\dp;
