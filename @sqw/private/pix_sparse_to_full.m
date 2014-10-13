function pixout = pix_sparse_to_full(pix,pix_nz,ind_beg,ne,ndet)
% Create full pix array from sparse format representation
%
%   >> pixout = pix_sparse_to_full(pix,pix_nz,ind_beg,ne,ndet)
%
% The input arguments can define the entire pix array, or a section of the array.
%
% Input:
% ------ 
%   pix             Pixel index array, sorted so that all the pixels in the first
%                  bin appear first, then all the pixels in the second bin etc. (column vector)
%                   The pixel index is defined by the energy bin number and detector number:
%                           ipix = ien + ne*(idet-1)
%                       where
%                           ien     energy bin index
%                           idet    detector index into list of all detectors (i.e. masked and unmasked)
%                           ne      number of energy bins
%
%                   If more than one run contributed, then
%                           ipix = ien + max(ne)*(idet-1) + ndet*max(ne)*(irun-1)
%                       where in addition
%                           irun    run index
%                           ne      array with number of energy bins for each run
%
%   pix_nz          Array with columns containing [id,ie,s,e]' for the pixels with non-zero
%                  signal sorted so that all the pixels in the first bin appear first, then
%                  all the pixels in the second bin etc. Here
%                           ie      In the range 1 to ne (the number of energy bins
%                           id      In the range 1 to ndet (the number of detectors)
%                  but these are NOT the energy bin and detector indicies of a pixel; instead
%                  they are the pair of indicies into the location in the pix array below.
%                           ind = ie + ne*(id-1)
%
%                   If more than one run contributed, array contains ir,id,ie,s,e, where
%                           ir      In the range 1 to nrun (the number of runs)
%                  In this case, ir adds a third index into the pix array, and 
%                           ind = ie + max(ne)*(id-1) + ndet*max(ne)*(ir-1)
%
%   ind_beg         Index of first element of pix within the entire pix array. This is needed because
%                  pix and pix_nz may only refer to a section of the complete pix array. If not a 
%                  section, then ind_beg=1
%
%   ne              Column vector with number of energy bins for each contributing spe file
%
%   ndet            Number of detectors
%
% Output:
% -------
%   pixout          Array size [9,npix] with columns [0,0,0,0,irun,idet,ien,s,e] for all pixels
%                  in the same order as pix


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


npixtot=numel(pix);

if numel(ne)==1     % single run
    % Create output pix array (use: idet= ceil(pix/ne); ien = rem(pix-1,ne)+1;)
    pixout = [zeros(4,npixtot); ones(1,npixtot); ceil(pix'/ne); rem(pix'-1,ne)+1; zeros(2,npixtot)];
    
    % Get index of pixels with non-zero signal (offset to start of pix array if it is a section)
    if ind_beg==1    % no offset needed, so keep code fast
        ind = ne*(pix_nz(1,:)-1) + pix_nz(2,:);
    else
        ind = (ne*(pix_nz(1,:)-1) + pix_nz(2,:)) - (ind_beg-1);
    end
    
    % Fill signal and error for non-zero pixels
    pixout(8:9,ind) = pix_nz(3:4,:);
    
else
    nemax = max(ne);
    % Create output pix array
    irun = ceil(pix'/(ndet*nemax));
    irem = rem(pix'-1,(ndet*nemax))+1;
    idet = ceil(irem/nemax);
    ien  = rem(irem-1,nemax)+1;
    pixout = [zeros(4,npixtot); irun; idet; ien; zeros(2,npixtot)];
    
    % Get index of pixels with non-zero signal (offset to start of pix array if it is a section)
    if ind_beg==1    % no offset needed, so keep code fast
        ind = (ndet*nemax)*(pix_nz(1,:)-1) + nemax*(pix_nz(2,:)-1) + pix_nz(3,:);
    else
        ind = ((ndet*nemax)*(pix_nz(1,:)-1) + nemax*(pix_nz(2,:)-1) + pix_nz(3,:)) - (ind_beg-1);
    end
    
    % Fill signal and error for non-zero pixels
    pixout(8:9,ind) = pix_nz(4:5,:); 
    
end
