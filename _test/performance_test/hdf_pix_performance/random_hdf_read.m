function [time,real_sz]=random_hdf_read(filesize,block_size,n_blocks,job_num,n_call)
t0 = tic;
nl = numlabs;
if ~exist('job_num','var')
    id = labindex;
else
    id  = job_num;
end
if id == nl
    return;
end
if ~exist('n_call','var')
    n_call = 0;
end

f_name = sprintf('block_%d.hdf',id);


pos = floor((filesize-block_size)*rand(1,n_blocks))+1;

starts = sort(pos); % this should not and seems indeed does not make any
ends       = starts+block_size;
block_size = ends-starts;
[pos,block_size] = compact_overlapping(starts,block_size);

buf_size = 10000000;
if filesize < buf_size
    buf_size = filesize/2;
end

reader = hdf_pix_group(f_name);
completed = false;
real_sz = 0;
while(~completed )
    [pix_array,completed]=reader.read_pixels(pos,block_size,buf_size);
    real_sz  = real_sz+size(pix_array,2);
end


time = toc(t0);
