function npix_section=sources_npix_section(src,srcind,i_binbuff)
% Buffer a block of npix in a cell array, one array per data source
%
%   >> npix_section=sources_npix_section(src,srcind,i_binbuff)
%
% Input:
% ------
%   src         Array of structures, one per data source, with the following fields:
%                   S           sqwfile object for an open file (=[] if not file data source)
%                   sparse_fmt  true if sparse format object or file; false otherwise
%                   npix        npix array    (=[] if not stored in memory)
%                   npix_nz     npix_nz array (=[] if not stored in memory, or non-sparse format)
%                   pix_nz      pix_nz array  (=[] if not stored in memory, or non-sparse format)
%                   pix         pix array     (=[] if not stored in memory)
%
%   srcind      Structure with fields containing various index arrays. See
%               the help to function sources_get_index_arrays for details
%
%   i_binbuff   Index of the buffer section of npix to be returned
%
% Output:
% -------
%   npix_section    Cell array of column vectors, each vector containing the
%                   section of npix for one data set


% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)


nsource=numel(src);
npix_section=cell(nsource,1);

blo=srcind.blo_binbuff(i_binbuff);
bhi=srcind.bhi_binbuff(i_binbuff);
if srcind.any_sparse        % at least one sparse data set
    ilo=srcind.ilo_npix(:,i_binbuff);
    ihi=srcind.ihi_npix(:,i_binbuff);
    irange=(ihi-ilo>=0);    % will be true for non-sparse data sets, but we don't use it with those
end

for i=1:nsource
    w=src(i);
    if w.sparse_fmt
        if isempty(w.npix)
            if irange(i)
                npix_section{i}=get_sqw(w.S,'npix',[blo,bhi],[ilo(i),ihi(i)],'-full');
            else
                npix_section{i}=zeros(bhi-blo+1,1); % no non-zero elements, so speed up construction
            end
        else
            npix_section{i}=full(w.npix(blo:bhi));  % ensure npix has full format
        end
    else
        if isempty(w.npix)
            npix_section{i}=get_sqw(w.S,'npix',[blo,bhi]);
        else
            npix_section{i}=w.npix(blo:bhi);
        end
    end
end

% Ensure npix sections are all column vectors
for i=1:nsource
    npix_section{i}=npix_section{i}(:);
end
