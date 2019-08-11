function x=random_points(sample,np)
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

shape=sample.shape;
if strcmp(shape,'cuboid')           % plate-like sample
    x=random_points_cuboid(sample.ps,np);
else
    error('Unrecognised sample shape')
end
