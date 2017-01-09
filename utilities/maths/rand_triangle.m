function X = rand_triangle (varargin)
% Generate random number from a triangle distribution with unit full width half height
%
%   >> X = rand_triangle            % generate a single random number
%   >> X = rand_triangle (n)
%   >> X = rand_triangle (sz)
%   >> X = rand_triangle (sz1, sz2,...)
%
% The distribution is:
%       /\
%      /  \
%    --    --
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

X = rand(varargin{:});
gthalf = (X>0.5);
X(~gthalf) = sqrt(2*X(~gthalf)) - 1;
X(gthalf) = 1 - sqrt(2*(1-X(gthalf)));
