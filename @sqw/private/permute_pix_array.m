function pixout = permute_pix_array (pix, npix, order)
% Permute the pixel information array elements according to list of permutations of the plot axes
% Arrays pix and npix are assumed to be compatible, and order too - not all checks are done !
%
%   >> pixout = permute_pix_array (pix, npix, order)
%
%   pix     Array of pixel information values (9 x npixtot)
%   npix    List of number of pixels contributing to each bin.
%   order   Rearrangement of axes, foolowing usual convention of matlab intrinsic PERMUTE
%          e.g. if npix is 3D with size [13,17,22], then 
%          order [2,3,1] rearranges pix so that it corresponds to a new npix with size [17,22,13]
%
%   pixout  Output array (9 x npixtot)

% Original author: T.G.Perring
% $Revision$ ($Date$)

if ~isvector(npix)  % work needs to be done
    if numel(size(npix))==length(order) && sum(npix(:))==size(pix,2)
        nend=cumsum(npix(:));
        nbeg=nend-npix(:)+1;    % nbeg(i)=nend(i)+1 if npix(i)==0, but that's OK below
        nbin=numel(npix);
        ind=permute(reshape(1:nbin,size(npix)),order); % ind(i) is index of bin into unpermuted array
        npixout=permute(npix,order);
        nendout=cumsum(npixout(:));
        nbegout=nendout-npixout(:)+1;
        pixout=zeros(size(pix));
        for i=1:nbin
            pixout(:,nbegout(i):nendout(i))=pix(:,nbeg(ind(i)):nend(ind(i)));     % if npix(i)=0, this assignment does nothing
        end
    else
        error('Number of elements in input array(s) and/or dimensions incompatible')
    end
end
