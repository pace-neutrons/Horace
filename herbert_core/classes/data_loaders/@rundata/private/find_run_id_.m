function  id = find_run_id_(obj)
% calculate and return the index (numerical id which uniquely identifies the file) 
% of the file used as the source of the data
%
% Normally it picks up the numerical part of the file name
% if the loader is undefined, the run_id is empty
% if the file does not have numerical part, the id == 1
% if the loader exsisit bug has empty filename, the id = 0;
% 
%
if isempty(obj.loader)
    id = [];
    return
end
ld = obj.loader;
if isempty(ld.file_name)
    id = 0;
    return
end
id = obj.extract_id_from_filename(ld.file_name);
