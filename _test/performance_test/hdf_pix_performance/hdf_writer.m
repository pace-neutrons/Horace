function [time,size]=hdf_writer(block_size,n_blocks,job_num,chunk_size)
her_loc = which('herbert_init.m');
if isempty(her_loc)
    horace_on();
end

nl = numlabs;
if ~exist('job_num','var')
    id = labindex;
else
    id  = job_num;
end

if id == nl
    time = 0;
    size = 0;
    return;
end
if ~exist('chunk_size','var')
    chunk_size = block_size;
end

t0 = tic;

f_name = sprintf('block_%d.hdf',id);

writer = hdf_pix_group(f_name,n_blocks*block_size,chunk_size);

% write PIXELS

contents = single(id*ones(9,block_size));
pix_min  = min(contents,[],2);
for i=1:n_blocks
    contents(2,:) = single(contents(2,:)*i);
    start_pos = (i-1)*block_size+1;
    writer.write_pixels(start_pos,contents)
end
size = block_size*n_blocks;

delete(writer)

time = toc(t0);
