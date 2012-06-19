function theta = rotmat_to_rotvec2 (rotmat)
% Convert rotation matricies to rotation vectors
%
%   >> theta = rotmat_to_rotvec (rotmat)
%
%   rotmat  Rotation matricies: 3x3 (siugle matrix) or 3 x 3 x m array
%           Relates the components of a vector v expressed in the two coordinate frames by
%               v'(i) = R(i,j) v(j)
%
%   theta   Rotation vector: vector length 3 (single rotation vector) or 3 x m array (m vectors)
%           Coordinate frame S' is related to S by rotation about a unit vector (n(1),n(2),n(3))
%           in S by angle THETA in radians (in a right-hand sense). This defines a 3-vector
%           (THETA(1), THETA(2), THETA(3)) where THETA(i) = THETA*n(i).
%
% Differs from rotmat_to_rotvec in the units of theta (here radians, there degrees)

sz=size(rotmat);
if numel(sz)==2 && sz(1)==3 && sz(2)==3
    tmp=logm(rotmat);
    theta=[tmp(8);tmp(3);tmp(4)];
elseif numel(sz)==3 && sz(1)==3 && sz(2)==3 && sz(3)>1
    theta=zeros(3,sz(3));
    for i=1:sz(3)
        tmp=logm(rotmat(:,:,i));
        theta(:,i)=[tmp(8);tmp(3);tmp(4)];
    end
else
    error('Check size of input argument')
end
