function X = cuboid_random_points (ps, varargin)
% Return an array of random points uniformly distributed in a cuboidal sample
%
%   >> X = cuboid_random_points (ps)                % generate a single random point
%   >> X = cuboid_random_points (ps, n)             % n x n matrix of random points
%   >> X = cuboid_random_points (ps, sz)            % array of size sz
%   >> X = cuboid_random_points (ps, sz1, sz2,...)  % array of size [sz1,sz2,...]
%
% Input:
% -------
%   ps      Arguments for cuboid sample
%               [wx,wy,wz] (full widths in meters)
%
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%   X           Array of random points.
%               The size of the array is [3,sz]. with any singleton
%               dimensions in sz squeezed away


x = ps(1)*(rand(varargin{:})-0.5);
y = ps(2)*(rand(varargin{:})-0.5);
z = ps(3)*(rand(varargin{:})-0.5);

sz = size(x);
X = [x(:)'; y(:)';z(:)'];
X = reshape(X,[3,sz]);
X = squeeze(X);
