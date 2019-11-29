function X = rand (self, varargin)
% Generate random numbers from the Fermi chopper pulse shape
%
%   >> X = rand (fermi)                % generate a single random number
%   >> X = rand (fermi, n)             % n x n matrix of random numbers
%   >> X = rand (fermi, sz)            % array of size sz
%   >> X = rand (fermi, sz1, sz2,...)  % array of size [sz1,sz2,...]
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
%   X           Array of random times (microseconds)


if ~isscalar(self), error('Method only takes a scalar Fermi chopper object'), end

X = rand (self.pdf_, varargin{:});
