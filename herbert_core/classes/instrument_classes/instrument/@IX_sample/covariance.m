function C = covariance (self)
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


if ~isscalar(self)
    error('HERBERT:IX_sample:invalid_argument', ...
        'Method only takes a scalar sample object')
end


shapes= self.shapes_;
shape = self.shape_;

if shapes.match('cuboid',shape)             % plate-like sample
    C = cuboid_covariance (self.ps_);

elseif shapes.match('point',shape)          % point sample
    C = point_covariance (self.ps_);

else
    error('HERBERT:IX_sample:invalid_argument', ...
        'Unrecognised sample shape for computing shape covariance')
end
