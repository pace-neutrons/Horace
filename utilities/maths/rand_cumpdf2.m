function X = rand_cumpdf2(x,cumpdf,varargin)
% Generate random numbers from a probability distribution given the cumulative pdf
%
%   >> X = rand_cumpdf2 (x, cumpdf)
%   >> X = rand_cumpdf2 (x, cumpdf, n)
%   >> X = rand_cumpdf2 (x, cumpdf, sz)
%   >> X = rand_cumpdf2 (x, cumpdf, sz1, sz2,...)
%
% Differs from rand_cumpdf in that cumpdf is not assumed to correspond to
% equally spaced intervals between 0 and 1.
%
% The lookup table cumpdf should be a strictly monotonically increasing vector
% first element 0 last element 1
%
% Input:
% ------
%   x           x coordinates corresponding to values of cumulative probability
%              distribution in cumpdf (column vector)
%   cumpdf      Lookup table (column vector): a monotonically increasing
%              vector of at least four elements where the first element
%              must be zero and the last element unity.
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%   X           Array of random numbers

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


A_ran = rand(varargin{:});
X = interp1(cumpdf,x,A_ran,'pchip','extrap');
