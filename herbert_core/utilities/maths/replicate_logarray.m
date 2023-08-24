function vout = replicate_logarray (v, n)
% Replicate logical array elements according to list of repeat indicies
%
%   >> ivout = replicate_logarray (v, n)
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


if numel(n)==numel(v)
    vout = logical(replicate_iarray(double(v),n));
else
    error('HERBERT:replicate_logarray:invalid_argument',...
        ['The number of elements in input array ''v'' (%d) is different from \n', ...
        'the number of elements in input array ''n'' (%d)'], numel(iv),numel(n));
end
