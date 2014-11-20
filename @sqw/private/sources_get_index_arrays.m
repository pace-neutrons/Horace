function [srcind,npixtot] = sources_get_index_arrays(src,npix_accum,nbin_buff_size,npix_buff_size)
% Get index arrays for the buffered sections of npix and pix to be written when combinng sqw data
%
%   >> srcind = sources_get_index_arrays(src,npix_all,nbin_buff_size,npix_buff_size)
%
% Input:
% ------
%   src         Array of structures, one per data source, with the following fields:
%                   S           sqwfile object for an open file (=[] if not file data source)
%                   sparse_fmt  true if sparse format object or file; false otherwise
%                   nfiles      number of contributing spe files in the data source
%                   npix        npix array    (=[] if not stored in memory)
%                   npix_nz     npix_nz array (=[] if not stored in memory, or non-sparse format)
%                   pix_nz      pix_nz array  (=[] if not stored in memory, or non-sparse format)
%                   pix         pix array     (=[] if not stored in memory)
%
%   npix_accum  Array of number of pixels in each bin for the output sqw data.
%               This is assumed to be consistent with the information in src
%   
%   nbin_buff_size  Maximum number of bins to be buffered in one chunk
%                   If Inf or empty, then make just one bin buffer
%
%   npix_buff_size  Maximum number of pixels to be buffered in one chunk
%                   If Inf or empty, then make just one buffer
%
%
% Output:
% -------
%   srcind      Structure with fields containing various index arrays defined below
%
%           any_sparse              True if one or more data sources is sparse
%                                   False otherwise
%
%           If we define:
%               Nb  number of blocks of npix to buffer
%               Np  number of blocks of pixels to buffer
%               Ns  number of data sources
%
%           then the returned arrays and sizes are:
%
%           Non-sparse and sparse data sets:
%           --------------------------------
%           blo_binbuff (1:Nb,1)    Lower and upper bin numbers for each of the blocks of npix
%           bhi_binbuff (1:Nb,1)   and npix_nz to buffer
%           np_binbuff (1:Nb,1)     Number of pixels in each bin buffer block
%
%           blo (1:Np,1)            Lower and upper bin numbers for each of the blocks of pixels
%           bhi (1:Np,1)           to buffer
%           np (1:Np,1)             Number of pixels in each pixel buffer block
%
%           plo (1:Ns,1:Np)         For each file, the lower and upper indicies of pix
%           phi (1:Ns,1:Np)        corresponding to each of the blocks of buffered pixels.
%           dp  (1:Ns,1:Np)         For each file, the number of pixels in each block of buffered pixels
%
%           For sparse data sets (fields set to [] if all non-sparse data sets:
%           --------------------
%           ilo_npix (1:Ns,1:Nb)    For each file, the lower and upper indicies into the list
%           ihi_npix (1:Ns,1:Nb)   of non-zero elements of npix corresponding to each of the
%                                   blocks of npix to buffer.
%
%           ilo_npix_nz (1:Ns,1:Nb) For each file, the lower and upper indicies into the list
%           ihi_npix_nz (1:Ns,1:Nb)of non-zero elements of npix corresponding to each of the
%                                   blocks of npix to buffer.
%
%           ilo_pix_nz (1:Ns,1:Np)  For each file, the lower and upper indicies of pix_nz
%           ihi_pix_nz (1:Ns,1:Np) corresponding to each of the blocks of buffered pixels.
%
%
%   npixtot     Total number of pixels

% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)


npix_accum_cumsum = cumsum(npix_accum(:));
if isinf(nbin_buff_size) || isempty(nbin_buff_size)
    nbin_buff_size=numel(npix_accum);       % total number of bins
end
if isinf(npix_buff_size) || isempty(npix_buff_size)
    npix_buff_size=npix_accum_cumsum(end);  % total number of pixels
end

% List of bin indicies for blocks of pixels to buffer
bhi=upper_bin_index(npix_accum_cumsum,npix_buff_size);
blo=[1;bhi(1:end-1)+1];

np=npix_accum_cumsum(bhi)-[0;npix_accum_cumsum(bhi(1:end-1))];  % Number of pixels in each pixel buffer block

% List of bin indicies for blocks of npix to buffer
ind=upper_bin_index(npix_accum_cumsum(bhi),nbin_buff_size);
bhi_binbuff=bhi(ind);
blo_binbuff=[1;bhi_binbuff(1:end-1)+1];

np_binbuff=npix_accum_cumsum(bhi_binbuff)-[0;npix_accum_cumsum(bhi_binbuff(1:end-1))];  % Number of pixels in each bin buffer block

% Compute pixel indexing arrays
nsource=numel(src);
n_binbuff=numel(bhi_binbuff);   % number of times the npix buffer will be filled
n_pixbuff=numel(bhi);           % number of times the pix buffer will be filled

phi=zeros(nsource,n_pixbuff);   % to hold upper indicies of pix

any_sparse=false;
for i=1:nsource
    % Get upper indicies of pix corresponding to each of the blocks of buffered pixels
    w=src(i);
    if isempty(w.npix)
        npix=get_sqw (w.S,'npix','-full');   % read npix from the sqw file
    else
        npix=w.npix;
        if issparse(npix), npix=full(npix); end
    end
    npix_cumsum=cumsum(npix(:));    % npix was made full as cumsum will be almost full anyway
    phi(i,:)=npix_cumsum(bhi);
    
    if w.sparse_fmt
        % Create index arrays if encounter a sparse data set
        if ~any_sparse
            any_sparse=true;
            ihi_npix=zeros(nsource,n_binbuff);
            ihi_npix_nz=zeros(nsource,n_binbuff);
            ihi_pix_nz=zeros(nsource,n_pixbuff);
        end
        
        % Get indicies of end of ranges of npix so we can read the correct section from file
        ihi_npix(i,:)=upper_index(find(npix),bhi_binbuff);
        
        % Get upper indicies of pix_nz corresponding to each of the blocks of buffered pixels
        if isempty(w.npix_nz)
            npix_nz=get_sqw (w.S,'npix_nz','-full');
        else
            npix_nz=w.npix_nz;
            if issparse(npix_nz), npix_nz=full(npix_nz); end
        end
        npix_nz_cumsum=cumsum(npix_nz(:));
        ihi_pix_nz(i,:)=npix_nz_cumsum(bhi);

        % Get indicies of end of ranges of npix_nz so we can read the correct section from file
        ihi_npix_nz(i,:)=upper_index(find(npix_nz),bhi_binbuff);
    end
end

% Get lower indicies of lookup ranges
plo=[ones(nsource,1),1+phi(:,1:end-1)];
dp=phi-plo+1;

if any_sparse
    ilo_npix=[ones(nsource,1),1+ihi_npix(:,1:end-1)];
    ilo_npix_nz=[ones(nsource,1),1+ihi_npix_nz(:,1:end-1)];
    ilo_pix_nz=[ones(nsource,1),1+ihi_pix_nz(:,1:end-1)];
else
    ilo_npix=[];    ihi_npix=[];
    ilo_npix_nz=[]; ihi_npix_nz=[];
    ilo_pix_nz=[]; ihi_pix_nz=[];
end

% Package the information
srcind.any_sparse = any_sparse;

srcind.blo_binbuff = blo_binbuff;
srcind.bhi_binbuff = bhi_binbuff;
srcind.np_binbuff  = np_binbuff;

srcind.blo = blo;
srcind.bhi = bhi;
srcind.np  = np;

srcind.plo = plo;
srcind.phi = phi;
srcind.dp  = dp;

srcind.ilo_npix = ilo_npix;
srcind.ihi_npix = ihi_npix;
srcind.ilo_npix_nz = ilo_npix_nz;
srcind.ihi_npix_nz = ihi_npix_nz;
srcind.ilo_pix_nz  = ilo_pix_nz;
srcind.ihi_pix_nz  = ihi_pix_nz;

npixtot = npix_accum_cumsum(end);
