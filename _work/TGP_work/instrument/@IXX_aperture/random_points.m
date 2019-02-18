function x = random_points(self, np)
% Return an array of random points in an aperture
%
%   >> x=random_points(aperture,np)
%
% Input:
% -------
%   aperture    IX_aperture object
%   np          Number of points requested
%
% Output:
% -------
%   x           Array of coordinates, size [2,np]


if ~isscalar(self), error('Method only takes a scalar aperture object'), end

x = [self.width_*(rand(1,np)-0.5); self.height_*(rand(1,np)-0.5)];
