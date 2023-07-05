function [time,read_sz]=random_bin_read(filesize,block_size,n_blocks,job_num)


nl = numlabs;
if ~exist('job_num','var')
    id = labindex;
else
    id  = job_num;
end
if id == nl
    time = 0;
    read_sz = 0;
    return;
end
t0 = tic;

f_name = sprintf('block_%d.bin',id);


fh = sqw_fopen(file, 'rb');
clob = onCleanup(@()fclose(fh));
%do_fseek(fh,0,'eof');
%fsize = ftell(fh);


pos = floor((filesize-block_size)*rand(1,n_blocks));
pos = sort(pos);
ends       = pos+block_size;
block_size = ends-pos;
[pos,block_size] = compact_overlapping(pos,block_size);

pos = pos*(9*4);
n_blocks = numel(pos);
read_sz = 0;
for i=1:n_blocks
    stat=do_fseek(fh,pos(i),'bof');
    if stat ~=0
        mess=ferror(fh,'clear');
        warning('can not move to the requested random position Err: %s',mess)

        continue;
    end
    cont = fread(fh,[9,block_size(i)],'*float32');
    read_sz = read_sz+size(cont,2);
end

time = toc(t0);
clear('clob');
