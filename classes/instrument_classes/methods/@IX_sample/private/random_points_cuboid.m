function x=random_points_cuboid(ps,np)
% Return an array of random points uniformly distributed in a cuboidal sample
%
%   >> [dt,tav]=pulse_shape_ikcarp(pp,ei,t)
%
% Input:
% -------
%   ps      Arguments for cuboid sample
%               [wx,wy,wz] (full widths in meters)
%   np      Number of points
%
% Output:
% -------
%   x       Array of coordinates, size [3,np]

x=[ps(1)*(rand(1,np)-0.5); ps(2)*(rand(1,np)-0.5); ps(3)*(rand(1,np)-0.5)];
