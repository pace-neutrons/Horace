function rotmat = rotvec_to_rotmat (theta, varargin)
% Convert rotation vectors to rotation matricies
%
% The rotation matrix relates the components of a vector expressed in a
% coordinate frame S to those in a frame S' that is obtained from S by the
% rotation vector (whose components are given in S). The relationship is
% v'(i) = R(i,j) v(j).
%
%   >> rotmat = rotvec_to_rotmat (theta)
%   >> rotmat = rotvec_to_rotmat (theta, algorithm)
%
% Input:
% ------
%   theta       Rotation vector or set of rotation vectors:
%               Vector length 3 , or 3 x m array, where m is the number of vectors
%               A rotation vector defines the orientation of a coordinate frame
%              S' with respect to a frame S by rotation about a unit vector
%              (n(1),n(2),n(3)) in S by angle THETA (in a right-hand sense).
%               This defines a 3-vector:
%                 (THETA(1), THETA(2), THETA(3)) where THETA(i) = THETA*n(i).
%
%               In this function the units are degrees.
% Optional:
%   algorithm   Method for algorithm
%                 =0  Fast method due to T.G.Perring (default)
%                 =1  Generic method based on matrix exponentiation
%
% Output:
% -------
%   rotmat      Rotation matrix or set of rotation matricies: 3 x 3 x m array
%               Relates the components of a vector v expressed in the
%              two coordinate frames by:
%                   v'(i) = R(i,j) v(j)
%
% Note:
%   rotvec_to_rotmat      this function  -- input rotation vector in degrees
%   rotvec_to_rotmat_rad  sister function-- input rotation vector in radians

theta=deg2rad(theta);   % convert to radians
rotmat = rotvec_to_rotmat_rad(theta, varargin{:});
