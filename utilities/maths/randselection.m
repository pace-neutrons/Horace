function X = randselection (A, varargin)
% Generate random array of numbers selected from the array vals
%
%   >> X = randselection (A)                % generate a single random selection
%   >> X = randselection (A, n)             % n x n matrix of random selections
%   >> X = randselection (A, sz)            % array of size sz
%   >> X = randselection (A, sz1, sz2,...)  % array of size [sz1,sz2,...]
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
%   X           Array of random selections.


ind = randi(numel(A),varargin{:});
X = A(ind);
if ~isequal(size(ind),size(X))
    X = reshape(X,size(ind));
end
