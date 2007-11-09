function n=test_max_open_file(nout)
% Test how many files can be open at once, up to a maximum of nout
fid=zeros(nout,1);
for i=1:nout
    flname=['c:\temp\test_crap_',num2str(i),'.txt'];
    [fid(i),mess]=fopen(flname,'wt');
    if fid(i)<0
        n=i-1;
        disp(['Maximum number of files open at once is ',num2str(i-1)])
        disp(mess)
        fclose('all');
        return
    end
    n=i;
end
fclose('all');
