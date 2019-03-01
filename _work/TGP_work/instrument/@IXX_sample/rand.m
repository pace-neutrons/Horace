function X = rand(self, varargin)
% Return an array of random points uniformly distributed in the sample
%
%   >> X = rand (sample)                % generate a single random point
%   >> X = rand (sample, n)             % n x n matrix of random points
%   >> X = rand (sample, sz)            % array of size sz
%   >> X = rand (sample, sz1, sz2,...)  % array of size [sz1,sz2,...]
%
% Input:
% ------
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


if ~isscalar(self), error('Method only takes a scalar sample object'), end
if ~self.valid_
    error('Sample object is not valid')
end

shapes= self.shapes_;
shape = self.shape_;

if shapes.match('cuboid',shape)             % plate-like sample
    X = cuboid_random_points (self.ps_, varargin{:});
    
elseif shapes.match('point',shape)          % point sample
    X = point_random_points (self.ps_, varargin{:});
    
else
    error('Unrecognised sample shape for computing random points')
end
