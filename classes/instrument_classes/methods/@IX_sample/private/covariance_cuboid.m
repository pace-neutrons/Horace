function C = covariance_cuboid (ps)
% Return covariance matrix for cuboidal sample shape
%
%   >> C = covariance_cuboid (sample)
%
% Input:
% ------
%   sample  IX_sample object
%
% Output:
% -------
%   C       Covariance matrix: 3x3 matrix of covariance for the three axes

C = diag (ps.^2/12);
