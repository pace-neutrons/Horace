function check_rotation_vector_transformation (n,n0)
% Check that 
%
% n0    Rotation vector that determines the orientation of S' w.r.t. S
%       Just used to generate an orthogonal matrix
%
% n     Rotation vector

n = n(:); n0 = n0(:);

O = rotvec_to_rotmat(n0);

nprime = O*n;
rprime = rotvec_to_rotmat(nprime);

rtrans = O*rotvec_to_rotmat(n)*O';

rtrans - rprime
