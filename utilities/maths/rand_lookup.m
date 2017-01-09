function X = rand_lookup(table,varargin)
% Generate random numbers from a normalised area lookup table
%
%   >> X = rand_lookup (table
%   >> X = rand_lookup (table, n)
%   >> X = rand_lookup (table, sz)
%   >> X = rand_lookup (table, sz1, sz2,...)
%
% The lookup table should be a monotonically 
%
% Input:
% ------
%   table       Lookup table (column vector): a monotonically increasing
%              vector of at least two elements. This holds the values of
%              the independent variable for for equally spaced values of
%              the cumulative probability distribution [0,d,2*d,3*d,...,1]
%              where d = 1/(numel(table)-1)
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%   X           Array of random numbers

npnt = size(table,1);
x = 1+(npnt-1)*rand(varargin{:});   % position in open interval (1,npnt)
ix = floor(x);    % interval number in table
dx = mod(x,1);    % distance from lower index

X = (1-dx).*table(ix) + dx.*table(ix+1);
