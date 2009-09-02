function list=file_list(indir,ext)
% the function return the list of files with given extention in the
% directory indir;
% $Revision$ ($Date$)
%
if(~isdir(indir))
    error(' can not find the directory: %s \n',indir);
end
fs=filesep; % identify the file separator of the current operating system
path = [indir,fs,'*.',ext];
files = dir(path);
list=cell(1,length(files));
for i=1:length(files)
    list{i}=files(i).name;
end
end

