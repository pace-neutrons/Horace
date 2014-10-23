function [mess, pos_pix, fmt_pix, npixtot] = put_sqw_data_pix_from_sources (fid, fmt_ver,...
    src, header, detpar, run_label, npix_accum)
% Write pixel information to an sqw file from various sources
%
%   >> [mess, pos_pix, fmt_pix, npixtot] = put_sqw_data_pix_from_sources (fid, fmt_ver, src, npix_accum, run_label)
%
% Input:
% ------
%   fid         File identifier of output file (opened for binary writing)
%
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
%   src         Array of structures, one per data source, with the following fields
%                   S           sqwfile object for an open file (=[] if not file data source)
%                   sparse_fmt  true if sparse format object or file; false otherwise
%                   nfiles      number of contributing spe files in the data source
%                   npix        npix array    (=[] if not stored in memory)
%                   npix_nz     npix_nz array (=[] if not stored in memory, or non-sparse format)
%                   pix_nz      pix_nz array  (=[] if not stored in memory, or non-sparse format)
%                   pix         pix array     (=[] if not stored in memory)
%
%   header      Header block for the combined sqw output data: scalar structure (if
%               single spe file) or cell array of structures, one per spe file
%
%   detpar      Detector parameter structure
%
%   run_label   Structure that defines how run indicies in the sqw data must be
%              renumbered. Arrays ix and ixarr are filled for all cases; For the
%              simple but frequent cases of nochange or simple offset
%              that information is stored too.
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
%           run_label.offset    If not empty, then contains array length equal to
%                              the number of input header blocks with offsets to add
%                              to the corresponding runs [this happens typically when
%                              using gen_sqw or accumulate_sqw, as every sqw file
%                              corresponds to a different spe file]
%
%   npix_accum  Array of number of pixels in each bin for the output sqw file.
%               This is assumed to be consistent with the information in src
%
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%
%   pos_pix     Position (in bytes from start of file) of the pix array
%
%   fmt_pix     Structure with format of pix array e.g. 'float32' (this is the
%               value for all file format up to and including '-v3.1'
%
%   npixtot     Total number of pixels actually written by the call to this function


% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)


% Initialise output arguments
mess='';
pos_pix=ftell(fid);
fmt_pix='float32';

% Get parameters
[nbin_buff_size,npix_buff_size] = get_buffer_parameters;

% Information from header
[kfix,emode,ne,k,en,spec_to_pix] = get_info_from_header (header);
detdcn = calc_detdcn(detpar);
ne_max=zeros(size(kfix));
for i=1:numel(ne_max)
    ne_max=max(ne(run_label.ix{i}));
end

% Determine if all sparse data sets (in memory or in file) come from a single run
sparse_single=true;
for i=1:numel(src)
    if src(i).sparse_fmt && ~src(i).nfiles==1
        sparse_single=false;
        break
    end
end

% Get indexing arrays
[srcind,npixtot] = sources_get_index_arrays (src, npix_accum, nbin_buff_size, npix_buff_size);


% Loop over pixel buffer blocks, writing to output
% ------------------------------------------------
bhi_binbuff=srcind.bhi_binbuff;
blo=srcind.blo;
bhi=srcind.bhi;
n_pixbuff=numel(bhi);

bhi_max=0;
i_binbuff=0;
for i=1:n_pixbuff
    if bhi(i)>bhi_max
        % Get next section of the npix arrays from all data sources, in non-sparse form
        % (By prior construction, the end of a bin buffer coincides with a pixel buffer)
        i_binbuff=i_binbuff+1;
        boffset=bhi_max;    % previous highest bin number whose pixels have been output
        bhi_max=bhi_binbuff(i_binbuff);
        npix = sources_npix_section (src, srcind, i_binbuff);
    end
    
    % Fill pixel buffer
    pix = sources_pix_section (src, srcind, i, run_label, ne_max, sparse_single,...
        kfix, emode, k, en, detdcn, spec_to_pix);
    
    % Rearrange pixels into increasing bin number
    brange=(blo(i)-boffset:bhi(i)-boffset);
    ind = index_hist_elements (npix(brange,:), 1);
    pix = pix(:,ind);
    
    % Write pixel buffer
    fwrite(fid,pix,fmt_pix);
    
end




%==================================================================================================
function [kfix,emode,ne,k,en,spec_to_pix]=get_info_from_header(h)
% Create information required to compute pixel coordinates
%
%   >> [efix,emode,ne,en,spec_to_pix]=get_info_from_header(h)
%
% Input:
% ------
%   h               Header block for sqw data: scalar structure (if single spe
%                   file) or cell array of structures, one per spe file
%
%
% Output:
% -------
%   kfix            Column vector with fixed wavevector for each run in the header (Ang^-1)
%
%   emode           Column vector with fixed emode (0,1,2) for each run in the header
%                   Direct geometry=1, indirect geometry=2, elastic=0
%
%   ne              Column vector with number of energy bins for each run in the header
%
%   k               Cell array of column vectors, one per run, with centres of the energy bins
%                   converted to wavevector (Ang^-1)
%
%   en              Cell array of column vectors, one per run, with centres of the energy bins
%                   in meV
%
%   spec_to_pix     Cell array (column) of the matricies to convert spectrometer coordinates
%                   (x-axis along ki, z-axis vertically upwards) to pixel coordinates.
%                   Need to account for the possibility that the crystal has been reoriented,
%                   in which case the pixels are no longer in crystal Cartesian coordinates.

c=neutron_constants;
k_to_e = c.c_k_to_emev;

if ~iscell(h)
    efix=h.efix;
    kfix=sqrt(efix/k_to_e);
    emode=h.emode;
    ne=numel(h.en)-1;
    en={0.5*(h.en(2:end)+h.en(1:end-1))};
    if emode==1
        k={sqrt((efix-en{1})/k_to_e)};
    elseif emode==2
        k={sqrt((efix+en{1})/k_to_e)};
    elseif emode==0
        k={(2*pi)./exp(en{1})};     % The en array is assumed to have bin centres as the logarithm of wavelength
    end
    [spec_to_xcart, xcart_to_rlu, spec_to_rlu] = calc_proj_matrix (h.alatt, h.angdeg,...
        h.cu, h.cv, h.psi, h.omega, h.dpsi, h.gl, h.gs);
    spec_to_pix=h.u_to_rlu(1:3,1:3)\spec_to_rlu;
else
    nspe=numel(h);
    kfix=zeros(nspe,1);
    emode=zeros(nspe,1);
    ne=zeros(nspe,1);
    k=cell(nspe,1);
    en=cell(nspe,1);
    spec_to_pix=cell(nspe,1);
    for i=1:numel(h)
        efix=h{i}.efix;
        kfix(i)=sqrt(efix/k_to_e);
        emode(i)=h{i}.emode;
        ne(i)=numel(h{i}.en)-1;
        en{i}=0.5*(h{i}.en(2:end)+h{i}.en(1:end-1));
        if emode(i)==1
            k{i}=sqrt((efix-en{i})/k_to_e);
        elseif emode(i)==2
            k{i}=sqrt((efix+en{i})/k_to_e);
        elseif emode(i)==0
            k{i}=(2*pi)./exp(en{i});    % The en array is assumed to have bin centres as the logarithm of wavelength
        end
        [spec_to_xcart, xcart_to_rlu, spec_to_rlu] = calc_proj_matrix (h{i}.alatt, h{i}.angdeg,...
            h{i}.cu, h{i}.cv, h{i}.psi, h{i}.omega, h{i}.dpsi, h{i}.gl, h{i}.gs);
        spec_to_pix{i}=h{i}.u_to_rlu(1:3,1:3)\spec_to_rlu;
    end
end
