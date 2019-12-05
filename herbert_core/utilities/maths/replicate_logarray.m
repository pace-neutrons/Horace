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
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)

if numel(n)==numel(v)
    vout = logical(replicate_iarray(double(v),n));
else
    error('Number of elements in input array(s) incompatible')
end

