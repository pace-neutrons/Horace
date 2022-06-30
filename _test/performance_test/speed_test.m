% simple test to verify single threaded write speed
% 
% May be useful in checking file system performance wrt Matlab operations
%
folder = fileparts(mfilename('fullpath'));
n_runs = 100;
npixels = 1000000;
fh = cell(1,n_runs);
for i=1:n_runs
    fh{i} = fopen(fullfile(folder,...
        sprintf('speed_test_N%d.bin',i)),'w+');
end
data = cell(1,n_runs);
for i=1:n_runs
    data{i} = rand(9,npixels);
end
tc = tic();
for i=1:n_runs
    %fwrite(fh{i},(data{i}),'float32');
    fwrite(fh{i},single(data{i}),'float32');    
end
tc = toc(tc)
fprintf('Write speed is %GMB/sec\n',(npixels*9*4)/tc/(1024*1024))

for i=1:n_runs
    fn = fopen(fh{i});
    fclose(fh{i});
%    delete(fn);
end
