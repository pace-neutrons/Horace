function X = rand_truncexp (x0,varargin)
% Generate random number from a truncated exponential distribution
%
%   >> X = rand_truncexp (x0, n)
%   >> X = rand_truncexp (x0, sz)
%   >> X = rand_truncexp (x0, sz1, sz2,...)
%
% Input:
% ------
%   x0          Truncation: random numbers are chosen in the range (0,x0) for
%              the normalised distribution A*exp(-x)  where A=1/(1-exp(-x0))
%               x0 >= 0 (including Inf)
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
%
%
% See also rand_truncexp2, which generates random points for an array of x0


% Original author: T.G.Perring 
% 
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


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
elseif x0==0
    X = zeros(varargin{:});
else
    error('The limit of the truncated exponential must be in range 0 to +Inf')
end

