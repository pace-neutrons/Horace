function vout = replicate_iarray (iv, n)
% Replicate integer array elements according to list of repeat indicies
%
%   >> ivout = replicate_iarray (iv, n)
%
% Input:
% ------
%   iv      Array of values
%   n       List of number of times to replicate each value
%
% Output:
% -------
%   ivout   Output array: column vector
%               ivout=[iv(1)*ones(1:n(1)), iv(2)*ones(1:n(2), ...)]'
%
% NOTE: This is designed for integer arrays only, as it assumes that
%       there are no rounding errors on addition.


% Original author: T.G.Perring


if numel(n)==numel(iv)
    if ~isempty(n)
        % Start and end indices for each range to replicate
        nend=cumsum(n(:));
        nbeg=nend-n(:)+1;    % nbeg(i)=nend(i)+1 if npix(i)==0, but that's OK below
        % Set up array of values to accumulate
        ok=(n~=0);
        dv=diff(iv(ok));
        vout=zeros(nend(end),1);
        vout(nbeg(ok))=[iv(find(ok,1));dv(:)];
        vout=cumsum(vout);
    else
        vout=zeros(0,1);
    end
else
    error('HERBERT:replicate_iarray:invalid_argument',...
        ['The number of elements in input array ''iv'' (%d) is different from \n', ...
        'the number of elements in input array ''n'' (%d)'], numel(iv),numel(n));
end
