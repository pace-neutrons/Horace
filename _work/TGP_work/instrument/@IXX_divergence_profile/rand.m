function X = rand (self, varargin)
% Generate random numbers from the divergence profile
%
%   >> X = rand (divergence)                % generate a single random number
%   >> X = rand (divergence, n)             % n x n matrix of random numbers
%   >> X = rand (divergence, sz)            % array od size sz
%   >> X = rand (divergence, sz1, sz2,...)  % array of size [sz1,sz2,...]
%
% Input:
% ------
%   divergence  IX_divergence_profile object
%
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%   X           Array of random numbers


if ~isscalar(self), error('Method only takes a scalar divergence profile object'), end

X = rand (self.pdf_, varargin{:});
