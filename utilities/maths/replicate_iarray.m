function vout = replicate_iarray (v, npix)
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
%
% $Revision: 815 $ ($Date: 2013-12-29 19:40:56 +0000 (Sun, 29 Dec 2013) $)

if numel(npix)==numel(v)
    if ~isempty(npix)
        % Start and end pixels for each bin
        nend=cumsum(npix(:));
        nbeg=nend-npix(:)+1;    % nbeg(i)=nend(i)+1 if npix(i)==0, but that's OK below
        % Set up array of values to accumulate
        ok=(npix~=0);
        dv=diff(v(ok));
        vout=zeros(nend(end),1);
        vout(nbeg(ok))=[v(find(ok,1));dv(:)];
        vout=cumsum(vout);
    else
        vout=zeros(0,1);
    end
else
    error('Number of elements in input array(s) incompatible')
end
