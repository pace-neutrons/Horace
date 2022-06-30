function C = point_covariance (ps)
% Return covariance matrix for cuboidal sample shape
%
%   >> C = point_covariance (ps)
%
% Input:
% ------
%   ps      Arguments for point sample. Empty array [].
%
% Output:
% -------
%   C       Covariance matrix: 3x3 matrix of covariance for the three axes

C = zeros(3);
