function test_rotation_vector_transformation
% Check that rotation vectors tranform just like any other vector
%
% n0    Rotation vector that determines the orientation of S' w.r.t. S
%       Just used to generate an orthogonal matrix
%
% n     Rotation vector

n = [-42,-33.4,273.8]';
n0 = [-111.3, 51.5, 34]';

O = rotvec_to_rotmat(n0);

% Tranform n into new coordinate frame and get rotation matrix
nprime = O*n;
rprime = rotvec_to_rotmat(nprime);

% Get equivalent transformation working in initial frame
rtrans = O*rotvec_to_rotmat(n)*O';

% Check equality
assertEqualToTol(rtrans,rprime,'tol',1e-14)
