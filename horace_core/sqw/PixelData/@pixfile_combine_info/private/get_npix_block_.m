function npix_block = get_npix_block_(obj,ds_num,ibin_start,ibin_end)
% Read npix block describing the distribution of pixels over
% image bins
%
%   >> npix_block =get_npix_section_(obj,ds_num,ibin_start,ibin_max)
%
% Input:
% ------
%   ds_num      -- number of dataset to read
%   ibin_start  -- First bin of data to read
%   ibin_max    -- last bin of data to read
%
% Output:
% -------
%   npix_block -- the block npix(ibin_start:ibin_end) for
%                  n_file's input file
fid = obj.loaders_list_{ds_num};
pos_npix = obj.pos_npixstart_(ds_num);
nbin_buf_size = ibin_end-ibin_start+1;

do_fseek(fid,pos_npix +8*(ibin_start-1),'bof'); % location of npix for bin number ibin_start

npix_block = fread(fid,nbin_buf_size,'uint64');
%
[f_message,f_errnum] = ferror(fid);
if f_errnum ~=0
    error('HORACE:pixfile_combine_info:io_error',f_message);
end
