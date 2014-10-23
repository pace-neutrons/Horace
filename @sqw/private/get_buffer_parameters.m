function [nbin_buff_size,npix_buff_size] = get_buffer_parameters
% Return the number of bins and pixels that can be buffered
%
%   >> [nbin_buff_size,npix_buff_size] = get_buffer_parameters


% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)


% Investigation of the number of file access operations when generating an sqw
% file (T.G.Perring notes September 2014) leads to recommendation that 
% nbin_buff_size=npix_buff_size. Depending on the fraction of sparse files
% the memory needed to buffer sections of npix and pix in bytes is about
% 100 times nbin_buff_size=npix_buff_size. This allows for overheads when unpacking 
% sparse data, but not for any further manipulations of the data.

nbin_buff_size = get(hor_config,'mem_chunk_size');
npix_buff_size = nbin_buff_size;
