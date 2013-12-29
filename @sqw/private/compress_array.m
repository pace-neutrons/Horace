function vout = compress_array (v_in, npix, mask)
% Remove blocks from an array
%
%   >> vout = compress_array (v, npix, mask)
%
% Input:
% ------
%   v       Two dimensional array of values, v(:,ntot) where
%              ntot=sum(n)
%   n       List of number of elements along outer dimension of v
%          corresponding to one block
%   mask    Block indicies to remove. Must have size(mask)==size(n)
%          If an element==true, the corresponding block will be masked.
%
% Output:
% -------
%   vout    Output array, v(:,ntot_compress), where
%               ntot_compress = sum(n(~mask))

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

sz=size(v_in);
npixtot=sum(npix(:));
if npixtot==sz(end) && isequal(size(npix),size(mask))
    if any(mask)    % a common case will be nothing masked
        % Get the bin index for each pixel
        nend=cumsum(npix(:));
        nbeg=nend-npix(:)+1;   % nbeg(i)=nend(i)+1 if npix(i)==0, but that's OK below
        npixtot=nend(end);
        keep=true(npixtot,1);
        for i=find(mask(:))'    % needs to be a row vector for 'for' to work
            keep(nbeg(i):nend(i))=false;    % still works if npix(i)=0
        end
        v=reshape(v_in,sz(1:end-1),sz(end));    % reshape into 2D array
        vout=v(:,keep);
        vout=reshape(vout,[sz(1:end-1),size(vout,2)]);
    else
        vout=v_in;
    end
else
    error('Number of elements in input array(s) incompatible')
end
