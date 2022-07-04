function C = covariance (sample)
% Return covariance matrix for the sample shape
%
%   >> C = covariance (sample)
%
% Input:
% ------
%   sample  IX_sample object
%
% Output:
% -------
%   C       Covariance matrix: 3x3 matrix of covariance for the three axes

shape = sample.shape;
if strcmp(shape,'cuboid')           % plate-like sample
    C = covariance_cuboid (sample.ps);
else
    error('Unrecognised sample shape')
end
