function [npix_nz,pix_nz,pixout] = pix_full_to_sparse(pix,npix,nrun,ne_max,ndet)
% Create sparse pix arrays from full npix and pix arrays
%
%   >> [npix_nz,pix_nz,pixout] = pix_full_to_sparse(pix,npix,nrun,ne,ndet)
%
% Note that this requires the entire npix and pix arrays; sections are not permitted
%
% Input:
% ------ 
%   pix             Array size [9,npixtot] with full pixel information
%
%   npix            Array of numbe of pixels in each bin
%
%   nrun            Number of contributing spe data sets (single spe=1, multiple spe=<anything else>)
%                  (This could be found by calculating max(pix(5,:)), but this takes a non-trivial
%                   amount of time, so pass into the function as already known from elsewhere)
%
%   ne_max          Number of energy bins in the spe data set with the most energy bins
%
%   ndet            Number of detectors (only required if more than one spe file)
%
%
% Output:
% -------
%   npix_nz         Number of non-zero pixels in each bin (sparse column vector)
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
%   pix_out         Pixel index array, sorted so that all the pixels in the first
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


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


% Information about contribution of pixels with non-zero counts to bins
nonempty=(pix(8,:)~=0 | pix(9,:)~=0);           % empty pixels have zero signal AND error
ibin=replicate_iarray(1:numel(npix),npix);      % bin indicies for all pixels
ibin_nz=ibin(nonempty);                         % bin indicies of pixels with non-zero signal or error
npix_nz=accumarray(ibin_nz,1,[numel(npix),1]);  % number of pixels with non-zero signal or error in each bin

npix_nz=sparse(npix_nz);

ipix_nz=find(nonempty);     % indicies of pixels with non-zero signal or error
if nrun==1
    pix_nz=[ceil(ipix_nz/ne_max); rem(ipix_nz-1,ne_max)+1; pix(8:9,nonempty)];
    pixout=(ne_max*(pix(6,:)-1) + pix(7,:))';
else
    ir=ceil(ipix_nz/(ndet*ne_max));
    irem=rem(ipix_nz-1,(ndet*ne_max))+1;
    id=ceil(irem/ne_max);
    ie=rem(irem-1,ne_max)+1;
    pix_nz=[ir; id; ie; pix(8:9,nonempty)];
    pixout=((ndet*ne_max)*(pix(5,:)-1) + ne_max*(pix(6,:)-1) + pix(7,:))';
end
