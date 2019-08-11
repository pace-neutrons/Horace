function vout = replicate_logarray (v, n)
% Replicate logical array elements according to list of repeat indicies
%
%   >> ivout = replicate_logarray (iv, n)
%
% Input:
% ------
%   v       Array of logical values i.e. true or false
%   n       List of number of times to replicate each value
%
% Output:
% -------
%   vout    Output array: column vector
%               vout=[v(1)*ones(1:n(1)), v(2)*ones(1:n(2), ...)]'

% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)

if numel(n)==numel(v)
    vout = logical(replicate_iarray(double(v),n));
else
    error('Number of elements in input array(s) incompatible')
end
