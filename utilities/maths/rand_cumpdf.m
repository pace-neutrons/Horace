function X = rand_cumpdf(xtab,varargin)
% Generate random numbers for a probability distribution given the cumulative pdf
%
%   >> X = rand_cumpdf (xtab)
%   >> X = rand_cumpdf (xtab, n)
%   >> X = rand_cumpdf (xtab, sz)
%   >> X = rand_cumpdf (xtab, sz1, sz2,...)
%
% Differs from sampling_table2 in that xtab is assumed to correspond to
% equally spaced intervals of the cumulative probability distribution between
% 0 and 1.
%
% Input:
% ------
%   xtab        x coordinates corresponding to equally spaced values
%              the cumulative pdf (column vector) between 0 and 1.
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


A_ran = rand(varargin{:});
npnt=numel(xtab);
cumpdf = [0; (1:npnt-2)'/(npnt-1); 1];
X = interp1(cumpdf,xtab,A_ran,'pchip','extrap');
