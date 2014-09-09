function rm_files(varargin)
% simple funciton which removes files from the list without issuing warning
% if the file is not present
%Usage:
%>>rm_files(file1,file2,file3,...)
% where file(N) if present --- the files to remove
%
for i=1:numel(varargin)
    if exist(varargin{i},'file')
        delete(varargin{i});
    end
end
