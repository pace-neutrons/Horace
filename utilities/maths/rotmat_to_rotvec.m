function theta = rotmat_to_rotvec (rotmat, algorithm)
% Convert rotation matricies to rotation vectors
%
% The rotation matrix relates the components of a vector expressed in a
% coordinate frame S to those in a frame S' by v'(i) = R(i,j) v(j).
%
%   >> theta = rotmat_to_rotvec (rotmat)
%   >> theta = rotmat_to_rotvec2 (rotmat, algorithm)
%
% Input:
% ------
%   rotmat      Rotation matricies: 3x3 (siugle matrix) or 3 x 3 x m array
%               Relates the components of a vector v expressed in the two
%              coordinate frames by:
%                   v'(i) = R(i,j) v(j)
%
%   algorithm   Method for algorithm
%                 =0  Fast method due to T.G.Perring (default)
%                 =1  Generic method based on matrix exponentiation
%
% Output:
% -------
%   theta       Rotation vector: vector length 3 (single rotation vector)
%              or 3 x m array (m is the number of vectors).
%               A rotation vector defines the orientation of a coordinate frame
%              S' with respect to a frame S by rotation about a unit vector
%              (n(1),n(2),n(3)) in S by angle THETA (in a right-hand sense).
%               This defines a 3-vector:
%                 (THETA(1), THETA(2), THETA(3)) where THETA(i) = THETA*n(i).
%
%               In this function the units are degrees.
%
% Note:
%   rotmat_to_rotvec    Rotation vector in degrees
%   rotmat_to_rotvec2   Rotation vector in radians

if nargin==1
    theta = rotmat_to_rotvec2 (rotmat);
else
    theta = rotmat_to_rotvec2 (rotmat, algorithm);
end
theta=theta*(180/pi);   % convert to degrees
