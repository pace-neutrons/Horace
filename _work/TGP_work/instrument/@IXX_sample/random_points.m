function x = random_points(self, np)
% Return an array of random points uniformly distributed in the sample
%
%   >> x=random_points(sample,np)
%
% Input:
% -------
%   sample  IX_sample object
%   np      Number of points requested
%
% Output:
% -------
%   x       Array of coordinates, size [3,np]


if ~isscalar(self), error('Method only takes a scalar sample object'), end
if ~self.valid_
    error('Sample object is not valid')
end

shapes= self.shapes_;
shape = self.shape_;

if shapes.match('cuboid',shape)             % plate-like sample
    x = cuboid_random_points (self.ps_, np);
    
elseif shapes.match('point',shape)          % point sample
    x = point_random_points (self.ps_, np);
    
else
    error('Unrecognised sample shape for computing random points')
end
