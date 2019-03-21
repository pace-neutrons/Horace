function [time,size]=bin_writer(block_size,n_blocks,job_num)


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
t0 = tic;

f_name = sprintf('block_%d.bin',id);

fh = fopen(f_name,'wb');
if fh<1
    error('PARALLEL_WRITER:io_error','Can not open file %s',f_name);
end
clob = onCleanup(@()fclose(fh));
contents = single(id*ones(9,block_size));
for i=1:n_blocks
    contents(2,:) = single(contents(2,:)*i);
    fwrite(fh,contents,'float32');
end
size = block_size*n_blocks;
time = toc(t0);
clear('clob');
