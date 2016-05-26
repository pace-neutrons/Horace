function X = rand_truncexp (x0,varargin)
% Generate random number from a truncated exponential distribution
%
%   >> X = rand_truncexp (x0,n)
%   >> X = rand_truncexp (x0,sz)
%
% Input:
% ------
%   x0          Truncation: random numbers are chosen in the range (0,x0) for
%              the normalised distribution A*exp(-x)  where A=1/(1-exp(-x0))
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


if x0==Inf
    % Full range of exponential: (0,Inf)
    X=-log(rand(varargin{:}));
elseif x0>0.01
    % Truncate exponential away from limiting case of x0<<1
    X=-log(1-(1-exp(-x0))*rand(varargin{:}));
elseif x0>0
    % Case when x0 is small: the above loses significant digits
    X = x0*rand(varargin{:});
    y = rand(varargin{:});
    reject = (y>exp(-X));
    n=sum(reject(:));
    if n>0
        X(reject)=rand_truncexp(x0,[n,1]); % recursively replace rejected points
    end
else
    error('x0 must be greater than zero')
end
