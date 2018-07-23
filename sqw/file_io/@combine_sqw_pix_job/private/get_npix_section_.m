function [npix_section,ibin_end]=get_npix_section_(fid,pos_npixstart,ibin_start,ibin_max,ibin_buffer_max_size)
% Fill a structure with sections of the npix arrays for all the input files. The positions of the
% pointers in the input files is left at the positions on entry (the algorithm requires them to be moved, but returns
% them at the end of the operation)
%
%   >> [npix_section,ibin_end,mess]=get_npix_section(fid,pos_npixstart,ibin_start,ibin_max)
%
% Input:
% ------
%   fid             Array of file identifiers for the input sqw files
%   ibin_start      Get section starting with this bin number
%   ibin_max        Maximum number of bins
%
% Output:
% -------
%   npix_section    npix_section{i} is the section npix(ibin_start:ibin_end) for the ith input file
%   ibin_end        Last bin number in the buffer - it is determined either by the maximum size of nbin in the
%                  files (as given by ibin_max), or by the largest permitted size of the buffer
%   mess            Error message: if all OK will be empty, if not OK will contain a message

% buffer size (in bytes) for holding section of npix arrays
if ~exist('ibin_buffer_max_size','var')
    ibin_buffer_max_size= config_store.instance().get_value('hor_config','mem_chunk_size');
end
ibin_buffer_max_size_bytes = ibin_buffer_max_size*8;

nfiles = numel(fid);
ibin_buffer_max_size = floor(ibin_buffer_max_size_bytes/(8*nfiles));    % max. no. of entries in buffer
ibin_buffer_fill = min(ibin_buffer_max_size,ibin_max-ibin_start+1);     % no. of elements of npix to read

% Fill output arguments:
ibin_end = ibin_start + ibin_buffer_fill - 1;
npix_section = int64(zeros(ibin_buffer_fill,nfiles));
for i=1:nfiles
    status=fseek(fid(i),pos_npixstart(i)+8*(ibin_start-1),'bof');    % location of npix for bin number ibin_start (recall written as int64)
    if status<0
        filename = fopen(fid);
        mess = ['Unable to find location of npix data in ',filename];
        error('SQW_BINFILE_IO:runtime_error',mess);
    end
    npix_section(:,i) = fread(fid(i),ibin_buffer_fill,'*int64');
    %
    [f_message,f_errnum] = ferror(fid(i));
    if f_errnum ~=0
        error('SQW_BINFILE_IO:runtime_error',f_message);
    end
    
end
