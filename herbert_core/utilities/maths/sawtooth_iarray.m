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

if isempty(n)
    % No values of n: empty column vector output
    ivout = zeros(0,1);
    
elseif isscalar(n)
    % Single value of n: return is (1:n)'. Note: this is correct when n = 0 as
    % well
    ivout = (1:n)';
    
else
    % How the following two lines work:
    % * First step is to create the array (1:sum(n(:))'. 
    % * To get the required output, it is necessary to subtract n(1) from
    % elements with indices (n(1)+1) to (n(1)+n(2)), then subtract
    % (n(1)+n(2)) from the elements with indices (n(1)+n(2)+1) to
    % (n(1)+n(2)+n(3)) etc. This can be achieved by feeding the cumulative sum
    % of [0; n(:)] into the function repelem with repeat values n:
    % - First elements are: 0  repeated n(1) times
    % -        followed by: n(1)  repeated n(2) times
    % -        followed by: n(1)+n(2)  repeated n(3) times
    %                etc
    % This algorithm works even when there are some or all n(i) == 0
    offset = cumsum([0;n]);
    ivout = (1:offset(end))' - repelem(offset(1:end-1), n);
end
