function X = rand (self, varargin)
% Generate random numbers from the moderator pulse shape
%
%   >> X = rand (moderator)                % generate a single random number
%   >> X = rand (moderator, n)             % n x n matrix of random numbers
%   >> X = rand (moderator, sz)            % array od size sz
%   >> X = rand (moderator, sz1, sz2,...)  % array of size [sz1,sz2,...]
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
%   X           Array of random numbers


if ~isscalar(self), error('Method only takes a scalar moderator object'), end
if ~self.valid_
    error('Moderator object is not valid')
end

X = rand (self.pdf_, varargin{:});
