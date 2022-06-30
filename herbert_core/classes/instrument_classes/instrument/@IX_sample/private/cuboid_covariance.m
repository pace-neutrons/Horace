function C = cuboid_covariance (ps)
% Return covariance matrix for cuboidal sample shape
%
%   >> C = cuboid_covariance (ps)
%
% Input:
% ------
%   ps      Arguments for cuboid sample
%               [wx,wy,wz] (full widths in meters)
%
% Output:
% -------
%   C       Covariance matrix: 3x3 matrix of covariance for the three axes

C = diag (ps.^2/12);
