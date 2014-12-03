function pix = sources_pix_section (src, srcind, i_pixbuff, run_label,...
    ne_max, sparse_all_single, kfix, emode, k, en, detdcn, spec_to_pix)
% Buffer a block of pix in a cell array, one array per data source
%
% If no data is sparse:
%   >> pix = sources_pix_section (src, srcind, i_pixbuff, run_label)
%
% If one or more data sources are sparse:
%   >> pix = sources_pix_section (src, srcind, i_pixbuff, run_label,...
%                       ne_max, sparse_single, kfix, emode, k, en, detdcn, spec_to_pix)
%
% Input:
% ------
%   src             Array of structures, one per data source, with the following fields:
%                       S           sqwfile object for an open file (=[] if not file data source)
%                       sparse_fmt  true if sparse format object or file; false otherwise
%                       nfiles      number of contributing spe files in the data source
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
%   run_label       Structure that defines how run indicies in the sqw data must be
%                  renumbered. Arrays ix and ixarr are filled for all cases; For the
%                  simple but frequent cases of nochange or simple offset
%                  that information is stored too.
%           run_label.ix        Cell array with length equal to the number of data sources,
%                              each entry being a column vector of the new labels for the
%                              corresponding run in the output sqw data. That is, ix{i}(j)
%                              is the new run number for the jth run of the ith sqw file.
%           run_label.ixarr     Alternative representation of the same information: an
%                              array with size [<max_number_runs_in_a_header_block>,
%                              <number_of_header_blocks>] so that each column contains the
%                              new labels for the corresponding run in the output sqw data.
%                              That is, ix(i,j) is the index of the entry in header_out
%                              corresponding to the ith run of the jth input sqw file.
%           run_label.nochange  true if the run indicies in all header blocks are
%                              to be left unchanged [this happens when combining
%                              sqw data from cuts taken from the same master sqw file]
%           run_label.offset    If not empty, then contains column vector length equal to
%                              the number of input header blocks with offsets to add
%                              to the corresponding runs [this happens typically when
%                              using gen_sqw or accumulate_sqw, as every sqw file
%                              corresponds to a different spe file]
%
%   ne_max          Column vector, one element per data set, containing the number of energy bins
%                   for the contributing run with the most energy bins
%
%   sparse_all_single True if all sparse data (in memory or in file) come from a single run
%                   false otherwise
%
%   kfix            Column vector with fixed wavevector for each run in the header (Ang^-1)
%
%   emode           Column vector with fixed emode (0,1,2) for each run in the header
%                   Direct geometry=1, indirect geometry=2, elastic=0
%
%   k               Cell array of column vectors, one per run, with centres of the energy bins
%                   converted to wavevector (Ang^-1)
%
%   en              Cell array of column vectors, one per run, with the centres of the energy bins
%                   in meV
%
%   detdcn          Direction of detector in spectrometer coordinates ([3 x ndet] array)
%                       [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%
%   spec_to_pix     Cell array (column) of the matricies to convert spectrometer coordinates
%                   (x-axis along ki, z-axis vertically upwards) to pixel coordinates.
%                   Need to account for the possibility that the crystal has been reoriented,
%                   in which case the pixels are no longer in crystal Cartesian coordinates.
%
% Output:
% -------
%   pix             Section of the pix array for the i_pixbuff buffer


% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)


nsource=numel(src);

plo=srcind.plo(:,i_pixbuff);
phi=srcind.phi(:,i_pixbuff);
dp =srcind.dp(:,i_pixbuff);
if srcind.any_sparse        % at least one sparse data set
    ndet=size(detdcn,2);
    ilo=srcind.ilo_pix_nz(:,i_pixbuff);
    ihi=srcind.ihi_pix_nz(:,i_pixbuff);
end

% Get pixels from each source
pix=zeros(9,srcind.np(i_pixbuff));
noffset=[0;cumsum(dp(1:end-1))];
for i=1:nsource
    w=src(i);
    jlo=noffset(i)+1;
    jhi=noffset(i)+dp(i);
    if jhi>=jlo
        if w.sparse_fmt
            % Get pix section
            if isempty(w.pix_nz) && isempty(w.pix)
                pix_block = get_sqw (w.S,'pix',[plo(i),phi(i)]);
                pix_nz = get_sqw (w.S,'pix_nz',[ilo(i),ihi(i)]);
                pix(:,jlo:jhi) = pix_sparse_to_full(pix_block,pix_nz,plo(i),ne_max(i),ndet);
            elseif isempty(w.pix)
                pix_block = get_sqw (w.S,'pix',[plo(i),phi(i)]);
                pix(:,jlo:jhi) = pix_sparse_to_full(pix_block,w.pix_nz(:,ilo(i):ihi(i)),plo(i),ne_max(i),ndet);
            elseif isempty(w.pix_nz)
                pix_nz = get_sqw (w.S,'pix_nz',[ilo(i),ihi(i)]);
                pix(:,jlo:jhi) = pix_sparse_to_full(w.pix(plo(i):phi(i)),pix_nz,plo(i),ne_max(i),ndet);
            else
                pix(:,jlo:jhi) = pix_sparse_to_full(w.pix(plo(i):phi(i)),w.pix_nz(:,ilo(i):ihi(i)),plo(i),ne_max(i),ndet);
            end
            % Compute pixel projections
            if sparse_all_single
                irun=run_label.ix{i}(1);
                pix(1:4,jlo:jhi) = ...
                    calc_ucoords (kfix(irun), emode, k{irun}, en{irun}, detdcn, spec_to_pix{irun}, pix(6,jlo:jhi), pix(7,jlo:jhi));
            else
                error('Combining sparse data sets with at least one made from multiple spe runs not implemented yet')
            end
            
        else
            if isempty(w.pix)
                pix(:,jlo:jhi) = get_sqw (w.S,'pix',[plo(i),phi(i)]);
            else
                pix(:,jlo:jhi) = w.pix(:,plo(i):phi(i));
            end
        end
    end
    
end

% Re-number the runs to match the order of the headers in the combined header block
if ~run_label.nochange
    if ~isempty(run_label.offset)
        pix(5,:) = pix(5,:) + replicate_iarray (run_label.offset, dp)';
        
    elseif ~isempty(run_label.ix)
        isource = replicate_iarray (1:numel(dp), dp)';
        ind = sub2ind (size(run_label.ix), pix(5,:), isource);
        pix(5,:) = run_label.ix(ind);
        
    else
        error('Logic error - see T.G.Perring')  % nochange==true should be the only remaining possibility
        
    end
end
