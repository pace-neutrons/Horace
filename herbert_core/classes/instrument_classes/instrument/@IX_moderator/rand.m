function X = rand (obj, varargin)
% Generate random numbers from the moderator pulse shape
%
%   >> X = rand (moderator)                % generate a single random number
%   >> X = rand (moderator, n)             % n x n matrix of random numbers
%   >> X = rand (moderator, sz)            % array of size sz
%   >> X = rand (moderator, sz1, sz2,...)  % array of size [sz1,sz2,...]
%
% Input:
% ------
%   obj         IX_moderator object (scalar)
%
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%   X           Array of random times (microseconds)


if ~isscalar(obj)
    error('HERBERT:IX_moderator:invalid_argument',...
        'Method only takes a scalar object')
end

X = rand (obj.pdf_, varargin{:});

end
