function host_files = find_and_return_host_files_(obj)
% list all files within the specific directory and select 
% the files which descript parallel configuration to be used 
all_files = dir(obj.config_folder_);
if ispc()
    conf_ext = '.win';
else
    conf_ext = '.lnx';
end

host_files = {'local'};
for i = 1:numel(all_files)
    the_file = all_files(i);
    if the_file.isdir
        continue;
    end
    [~,~,fe] = fileparts(the_file.name);
    if ~strcmpi(fe,conf_ext)
        continue;
    end
    host_files{end+1} = the_file.name;
end