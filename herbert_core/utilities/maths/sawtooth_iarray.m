function ivout = sawtooth_iarray (n)
% Create column vector [1;2;3..n(1); 1;2;3...n(2); ...] from integer array n
%
%   >> ivout = sawtooth_iarray (n)
%
% This is a 'sawtooth' array as each element n(i) defines a right angle triangle
% with length n and values 1,2,3,...n(i).
%
%
% Input:
% ------
%   n       Array with the lengths of each sawtooth section
%           Elements should have integer values greater or equal to zero.
%           Zeros correspond to zero length sections i.e. they are
%           effectively ignored).
%
% Output:
% -------
%   ivout   Output array: always a column vector
%           It is constructed as
%               ivout [(1:n(1))'; (1:n(2))'; ...] 
%           Non-integer values of n are rounded down to the next smaller
%           integer, and any negative values are treated as zero
%           Note: if the output is empty then it is still a column with zero
%           length i.e. has size = [0,1]
%
% EXAMPLES
%   ivout = sawtooth_iarray(n)
%
%   n                 ivout
% ----------------------------------------------------------------------
%   0               zeros(0,1)      % column vector with zero length
%   [2,3,1]         [1;2;1;2;3;1]
%   [2,0,1]         [1;2;1]         % zero length middle sawtooth section
%   [2.3,-0.7,3.99] [1;2;1;2;3]     % reals rounded downwards


n = floor(n(:));
n = n(n>0);
if isempty(n)
    ivout = zeros(0,1);
elseif isscalar(n)
    ivout = (1:n)';
else
    offset = cumsum([0;n]);
    ivout = (1:offset(end))' - repelem(offset(1:end-1), n);
end
