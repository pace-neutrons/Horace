function C = covariance (self)
% Return covariance matrix for the sample shape
%
%   >> C = covariance (aperture)
%
% Input:
% ------
%   aperture    IX_aperture object
%
% Output:
% -------
%   C           Covariance matrix: 2x2 matrix of covariance for the two axes


if ~isscalar(self), error('Method only takes a scalar aperture object'), end

C = zeros(2);
C(1,1) = (self.width)^2/12;
C(2,2) = (self.height)^2/12;
