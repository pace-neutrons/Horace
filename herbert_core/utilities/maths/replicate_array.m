function vout = replicate_array (v, n)
% Replicate array elements according to list of repeat indicies
%
%   >> vout = replicate_array (v, n)
%
% This is a legacy function retained for backwards compatibility. The same
% behaviour is accomplished with the Matlab intrinsic function repelem which was
% introduced in release R2015a:
%  Instead of:
%   >> vout = replicate_array (v, n)
%  use:
%   >> vout = repelem (v(:), n(:))
%
%
% Input:
% ------
%   v       Array of values
%   n       List of number of times to replicate each value
%
% Output:
% -------
%   vout    Output array: column vector
%               vout = [repmat(v(1),[n(1),1]); repmat(v(2),[n(2),1]); ...]
%
%           Note: In the case of vout being empty, this means that the output
%           has size [0,1]


if numel(n)==numel(v)
    vout = repelem(v(:), n(:));
else
    error('HERBERT:replicate_array:invalid_argument',...
        ['The number of elements in input array ''v'' (%d) is different from \n', ...
        'the number of elements in input array ''n'' (%d)'], numel(v),numel(n));
end
