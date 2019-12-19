function fcloser_(fid)
% close imput fid-s
nfiles = numel(fid);
for j=1:nfiles
    fclose(fid(j));
end
