function list=list_spe(inDir)
% the function returns the list of the all spe files in the directory inDir
% initially it tries to select all hdf files, which assumed to be an hdf versions of spe files
% then it tires asci spe files;
% $Revision: $ ($Date: $)
if(~isdir(inDir))
    error(' can not find directory %s',inDir);
end
isFullPath=fullPath(inDir);
if(~isFullPath)
    path = pwd;
    inDir=[path,filesep,inDir];
end
list=file_list(inDir,'h5');
if(size(list,2)==0)
        list=file_list(inDir,'spe');
end

for i=1:length(list)
    list{i}=[inDir,filesep,list{i}];
end
end
%%*************************************************
function isTrue=fullPath(inDir)
fs=filesep;
if(regexp(inDir,fs,'once'))
    isTrue=1;
else
    isTrue=0;
end
end

