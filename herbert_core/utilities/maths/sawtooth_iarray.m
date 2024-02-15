function ivout = sawtooth_iarray (n)
% Create column vector [1;2;3..n(1); 1;2;3...n(2); ...] from integer array n
%
%   >> ivout = sawtooth_iarray (n)
%
%
% Input:
% ------
%   n       Array with the lengths of each section of the output column vector.
%           - Each section is created as the column vector (1:n(i))'
%           - The elements of n should have integer values greater or equal to zero.
%           - Zeros correspond to zero length sections i.e. they are ignored).
%             This is consistent with Matlab which constructs M:N as an empty
%             array if N < M.
%
% Output:
% -------
%   ivout   Output array: always a column vector with length sum(n(:)).
%           It is constructed as:
%               ivout [1;2;3..n(1); 1;2;3...n(2); ...] 


n = n(:);
if any(n<0) || any(round(n)~=n)
    error('HERBERT:sawtooth_iarray:invalid_argument',...
        'The elements of the input argument must all be nonnegative integer values')
end

n = n(n>0);
if isempty(n)
    ivout = zeros(0,1);
elseif isscalar(n)
    ivout = (1:n)';
else
    offset = cumsum([0;n]);
    ivout = (1:offset(end))' - repelem(offset(1:end-1), n);
end
