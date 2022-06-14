function X = rand (self, varargin)
% Generate random points in an aperture
%
%   >> X = rand (aperture)                % generate a single random point
%   >> X = rand (aperture, n)             % n x n matrix of random points
%   >> X = rand (aperture, sz)            % array of size sz
%   >> X = rand (aperture, sz1, sz2,...)  % array of size [sz1,sz2,...]
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
%               The size of the array is [2,sz]. with any singleton
%               dimensions in sz squeezed away

if ~isscalar(self), error('Method only takes a scalar aperture object'), end

x = self.width_*(rand(varargin{:})-0.5);
y = self.height_*(rand(varargin{:})-0.5);

sz = size(x);
X = [x(:)'; y(:)'];
X = reshape(X,[2,sz]);
X = squeeze(X);
