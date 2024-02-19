function ivout = replicate_iarray (iv, n)
% Replicate integer array elements according to list of repeat indicies
%
%   >> ivout = replicate_iarray (iv, n)
%
% This is a legacy function retained for backwards compatibility. The same
% behaviour is accomplished with the Matlab intrinsic function repelem which was
% introduced in release R2015a:
%  Instead of:
%   >> ivout = replicate_iarray (iv, n)
%  use:
%   >> ivout = repelem (iv(:), n(:))
%
%
% Input:
% ------
%   iv      Array of values
%   n       List of number of times to replicate each value
%
% Output:
% -------
%   ivout   Output array: column vector
%               ivout = [repmat(iv(1),[n(1),1]); repmat(iv(2),[n(2),1]); ...]
%
%           Note: In the case of vout being empty, this means that the output
%           has size [0,1]


if numel(n)==numel(iv)
    ivout = repelem(iv(:), n(:));
    if isrow(ivout)
        ivout = ivout(:);
    end
else
    error('HERBERT:replicate_iarray:invalid_argument',...
        ['The number of elements in input array ''iv'' (%d) is different from \n', ...
        'the number of elements in input array ''n'' (%d)'], numel(iv),numel(n));
end
