function X = rand (obj, varargin)
% Generate random numbers from the Fermi chopper pulse shape
%
%   >> X = rand (obj)                % generate a single random number
%   >> X = rand (obj, n)             % n x n matrix of random numbers
%   >> X = rand (obj, sz)            % array of size sz
%   >> X = rand (obj, sz1, sz2,...)  % array of size [sz1,sz2,...]
%
% Input:
% ------
%   obj         IX_fermi_chopper object (scalar)
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
    error('IX_fermi_chopper:rand:invalid_argument',...
        'Method only takes a scalar object')
end

X = rand (obj.pdf_, varargin{:});

end
