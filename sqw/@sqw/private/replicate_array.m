function vout = replicate_array (v, npix)
% Replicate array elements according to list of repeat indicies
%
%   >> vout = replicate_array (v, n)
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
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)

if numel(npix)==numel(v)
    % Get the bin index for each pixel
    nend=cumsum(npix(:));
    nbeg=nend-npix(:)+1;    % nbeg(i)=nend(i)+1 if npix(i)==0, but that's OK below
    nbin=numel(npix);
    npixtot=nend(end);
    vout=zeros(npixtot,1);
    for i=1:nbin
        vout(nbeg(i):nend(i))=v(i);     % if npix(i)=0, this assignment does nothing
    end
else
    error('Number of elements in input array(s) incompatible')
end
