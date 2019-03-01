function X = point_random_points (ps, varargin)
% Return an array of random points uniformly distributed in a point sample
%
%   >> X = point_random_points (ps)                % generate a single random point
%   >> X = point_random_points (ps, n)             % n x n matrix of random points
%   >> X = point_random_points (ps, sz)            % array of size sz
%   >> X = point_random_points (ps, sz1, sz2,...)  % array of size [sz1,sz2,...]
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


X = zeros(varargin{:});
sz = size(X);
X = squeeze(reshape(repmat(X,3,1),[3,sz]));
