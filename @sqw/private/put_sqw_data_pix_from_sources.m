function [mess, pos_pix, fmt_pix, npixtot] = put_sqw_data_pix_from_sources (fid, fmt_ver, src, npix_accum, run_label, header, detpar)
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
%                   npix        npix array    (=[] if not stored in memory)
%                   npix_nz     npix_nz array (=[] if not stored in memory, or non-sparse format)
%                   pix_nz      pix_nz array  (=[] if not stored in memory, or non-sparse format)
%                   pix         pix array     (=[] if not stored in memory)
%
%   npix_accum  Array of number of pixels in each bin for the output sqw file.
%               This is assumed to be consistent with the information in src
%
%   run_label   Structure that defines how run indicies in the input sqw data must be
%               renumbered. Only one of these will be true/non-empty
%           run_label.nochange  true if the run indicies are to be left unchanged
%                              [this happens for example when combining sqw data
%                              from cuts all taken from the same master sqw file]
%           run_label.offset    If not empty, then contains array length equal to
%                              the number of data sources with offsets to add
%                              to the corresponding runs [this happens for example when
%                              combining sqw data with no common runs]
%           run_label.ix        If not empty, then is a cell array of length equal
%                              to the number of data sources, each entry being
%                              a column vector of the new labels for the corresponding
%                              run in the corresponding sqw data. That is, ix{i}(j)
%                              is the new run number for the jth run of the ith sqw file.
%
%   header      Header block for the combined sqw output data: scalar structure (if
%               single spe file) or cell array of structures, one per spe file
%
%   detpar      Detector parameter structure
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


% Get parameters
[nbin_buff_size,npix_buff_size]=get_buffer_parameters;

% Information from header
[ne,ecent,spec_to_pix]=get_en_and_spec_to_pix(header);

% List of upper bin indicies for blocks of pixels to buffer
srcind = sources_get_index_arrays(src,npix_accum,nbin_buff_size,npix_buff_size);

n_binbuff=numel(binbuff.iblo);
n_pixbuff=numel(pixbuff.ibhi);

% Loop over nbin_buff
i_max=0;
i_binbuff=0;
for i=1:n_pixbuff
    if i>i_max
        % Get next section of the npix arrays from all data sources, in non-sparse form
        i_binbuff=i_binbuff+1;
        i_max=ibhi_binbuff(i_binbuff);
        npix_section=sources_npix_section(src,srcind,i_binbuff);
    end
    
    % Fill pixel buffer
    pix_section=sources_pix_section(src,srcind,i,npix_section,detpar,ne,ecent,spec_to_pix);
    
    % Rearrange pixels into increasing bin number
    
    
    % Write pixel buffer
    
end

%==================================================================================================
function [ne,ecent,spec_to_pix]=get_en_and_spec_to_pix(h)
% Create information required to compute pixel coordinates
%
%   >> [ne,encent,spec_to_pix]=get_en_and_spec_to_pix(h)
%
% Input:
% ------
%   h               Header block for sqw data: scalar structure (if single spe
%                   file) or cell array of structures, one per spe file
%
%
% Output:
% -------
%   ne              Column vector with number of energy bins for each run in the header
%
%   ecent           Cell array of column vectors, one per run,  with centres of the energy bins
%
%   spec_to_pix     Cell array (column) of the matricies to convert spectrometer coordinates
%                   (x-axis along ki, z-axis vertically upwards) to pixel coordinates.
%                   Need to account for the possibility that the crystal has been reoriented,
%                   in which case the pixels are no longer in crystal Cartesian coordinates.

if ~iscell(h)
    ne=numel(h.en)-1;
    ecent={0.5*(h.en(2:end)+h.en(1:end-1))};
    [spec_to_xcart, xcart_to_rlu, spec_to_rlu] = calc_proj_matrix (h.alatt, h.angdeg,...
        h.cu, h.cv, h.psi, h.omega, h.dpsi, h.gl, h.gs);
    spec_to_pix=h.u_to_rlu(1:3,1:3)\spec_to_rlu;
else
    nspe=numel(h);
    ne=zeros(nspe,1);
    ecent=cell(nspe,1);
    spec_to_pix=cell(nspe,1);
    for i=1:numel(h)
        ne(i)=numel(h{i}.en)-1;
        ecent{i}={0.5*(h{i}.en(2:end)+h{i}.en(1:end-1))};
        [spec_to_xcart, xcart_to_rlu, spec_to_rlu] = calc_proj_matrix (h{i}.alatt, h{i}.angdeg,...
            h{i}.cu, h{i}.cv, h{i}.psi, h{i}.omega, h{i}.dpsi, h{i}.gl, h{i}.gs);
        spec_to_pix{i}=h{i}.u_to_rlu(1:3,1:3)\spec_to_rlu;
    end
end
