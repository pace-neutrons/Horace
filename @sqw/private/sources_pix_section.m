function pix_section=sources_pix_section(src,srcind,i_pixbuff,npix_section,detpar,ne,ecent,spec_to_pix)
% Buffer a block of pix in a cell array, one array per data source
%
%   >> pix_section=sources_pix_section(src,srcind,i_pixbuff)
%
% Input:
% ------
%   src             Array of structures, one per data source, with the following fields:
%                       S           sqwfile object for an open file (=[] if not file data source)
%                       sparse_fmt  true if sparse format object or file; false otherwise
%                       npix        npix array    (=[] if not stored in memory)
%                       npix_nz     npix_nz array (=[] if not stored in memory, or non-sparse format)
%                       pix_nz      pix_nz array  (=[] if not stored in memory, or non-sparse format)
%                       pix         pix array     (=[] if not stored in memory)
%
%   srcind          Structure with fields containing various index arrays. See
%                   the help to function sources_get_index_arrays for details
%
%   i_pixbuff       Index of the buffer section of pix to be returned
%
%   npix_section    Cell array of column vectors, each vector containing the
%                   section of npix for one data set
%
%   detpar          Detector parameter structure
%
%   ne              Column vector with number of energy bins for each run in the header
%
%   ecent           Cell array of column vectors, one per run,  with centres of the energy bins
%
%   spec_to_pix     Cell array (column) of the matricies to convert spectrometer coordinates
%                   (x-axis along ki, z-axis vertically upwards) to pixel coordinates.
%                   Need to account for the possibility that the crystal has been reoriented,
%                   in which case the pixels are no longer in crystal Cartesian coordinates.
%
% Output:
% -------
%   pix_section     Section of the pix array for the i_pixbuff buffer


% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)


nsource=numel(src);
ndet=numel(detpar.x2);

pix_section=zeros(9,srcind.np(i_pixbuff));

noffset=[0;cumsum(srcind.dp(1:end-1,i_pixbuff))];

plo=srcind.plo(:,i_pixbuff);
phi=srcind.phi(:,i_pixbuff);
if srcind.any_sparse        % at least one sparse data set
    ilo=srcind.ilo_pix_nz(:,i_pixbuff);
    ihi=srcind.ihi_pix_nz(:,i_pixbuff);
end

for i=1:nsource
    w=src(i);
    if w.sparse_fmt
        % Get pix section
        if isempty(w.pix_nz) && isempty(w.pix)
            pix_section(:,noffset(i)+plo(i):noffset(i)+phi(i))=...
                get_sqw(w.S,'pix',[plo(i),phi(i)],[ilo(i),ihi(i)]);
        elseif isempty(w.pix)
            pix=get_sqw(w.S,'pix',[plo(i),phi(i)]);     % get without resolving non-zero pixels
            pix_section(:,noffset(i)+plo(i):noffset(i)+phi(i))=...
                pix_sparse_to_full(pix,w.pix_nz(ilo(i):ihi(i)),plo(i),ne,ndet);
        elseif isempty(w.pix_nz)
            pix_nz=get_sqw(w.S,'pix_nz',[ilo(i),ihi(i)]);
            pix_section(:,noffset(i)+plo(i):noffset(i)+phi(i))=...
                pix_sparse_to_full(w.pix(plo(i):phi(i)),pix_nz,plo(i),ne,ndet);
        else
            pix_section(:,noffset(i)+plo(i):noffset(i)+phi(i))=...
                pix_sparse_to_full(w.pix(plo(i):phi(i)),w.pix_nz(ilo(i):ihi(i)),plo(i),ne,ndet);
        end
        % Compute pixel projections
        npix=npix_section{i};
        
    else
        if isempty(w.pix)
            pix_section(:,noffset(i)+plo(i):noffset(i)+phi(i))=get_sqw(w.S,'pix',[plo(i),phi(i)]);
        else
            pix_section(:,noffset(i)+plo(i):noffset(i)+phi(i))=w.pix(:,plo(i):phi(i));
        end
    end

end
