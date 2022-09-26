function vout = replicate_array(v, npix)
% Replicate array elements according to list of repeat indicies
%
%   >> vout = replicate_array (v, n)
%
% Used to spread signal, calculated on dnd object's grid into all
% contributed pixels
%
% Input:
% ------
%   v       Array of values
%   n       List of number of times to replicate each value
%
% Output:
% -------
%   vout    Output array: column vector
%               vout=[v(1)*ones(1:n(1)), v(2)*ones(1:n(2), ...)]'

% Original author: T.G.Perring

if numel(npix)==numel(v)
    if ~isempty(npix)
        repl = arrayfun(@(x,y)ones(1,x)*y,npix(:),v(:),'UniformOutput',false);
        vout = [repl{:}]';
    else
        vout=zeros(0,1);
    end
else
    error('HERBERT:replicate_array:invalid_argument',...
        ['Number of elements in input array 1 (%d) '''...
        'different from number of elements in input array 2 (%d)'],...
        numel(npix),numel(v));
end
