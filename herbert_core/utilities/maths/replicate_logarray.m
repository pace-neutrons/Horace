function vout = replicate_logarray (v, n)
% Replicate logical array elements according to list of repeat indicies
%
%   >> vout = replicate_logarray (v, n)
%
% This is a legacy function retained for backwards compatibility. The same
% behaviour is accomplished with the Matlab intrinsic function repelem which was
% introduced in release R2015a:
%  Instead of:
%   >> vout = replicate_logarray (v, n)
%  use:
%   >> vout = repelem (logical(v(:)), n(:)) % conversion to logical is needed
%                                           % if the class of v is not 'logical'
%
%
% Input:
% ------
%   v       Array of logical values i.e. true or false
%           If the class of v is not 'logical', an attempt to convert is mode.
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
    if isa(v, 'logical')
        vout = repelem(v(:), n(:));
    else
        vout = repelem(logical(v(:)), n(:));
    end
else
    error('HERBERT:replicate_logarray:invalid_argument',...
        ['The number of elements in input array ''v'' (%d) is different from \n', ...
        'the number of elements in input array ''n'' (%d)'], numel(v),numel(n));
end
