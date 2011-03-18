function copy_selected_files (source, root_source, root_target, varargin)
% Copy selected files from source to target directories, retaining relative paths
%
%   >> list = copy_selected_files (source, root_source, root_target)
%   >> list = copy_selected_files (source, root_source, root_target, include)
%   >> list = copy_selected_files (source, root_source, root_target, include, exclude)
%
% Input:
% --------
%   source          Source folder (full path)
%   root_source     Root folder from which to get relative path of source
%   root_target     Root folder for relative path to which to copy
%   include         List of file names to include (default: all)
%                   Format: e.g. 'temp.txt', 'te*.*; *mat*.m'
%                   If empty, then uses default
%   exclude         List of directory names to exclude (default: none)
%                   Format: e.g. 'temp.txt', 'te*.*; *mat*.m'
%
%   str_pattern     The first occurence of this string pattern in each filename
%                  will be replaced with the following:
%   str_replace     Replacement string

% *** make sure is synchronised with move_selected _files

narg=numel(varargin);
if narg>2
    if narg==4
        str_pattern=varargin{3};
        str_replace=varargin{4};
        rename=true;
    else
        error('Check number of optional arguments')
    end
else
    rename=false;
end
    
% Get list of files to copy
filename=file_name_list(source,varargin{1:min(narg,2)});  

% Copy files
if ~isempty(filename)
    relpath=relative_path(root_source,source);
    target=fullfile(root_target,relpath);
    if ~exist(target,'dir')
        ok=mkdir(target);
        if ~ok
            warning([' UNABLE TO CREATE FOLDER ',target,' - NO FILES COPIED'])
            return
        end
    end
    if ~rename
        for i=1:numel(filename)
            copyfile(fullfile(source,filename{i}),target,'f');
        end
    else
        n=numel(str_pattern);
        for i=1:numel(filename)
            if strncmp(str_pattern,filename{i},n)
                copyfile(fullfile(source,filename{i}),fullfile(target,[str_replace,filename{i}(n+1:end)]),'f');
            else
                copyfile(fullfile(source,filename{i}),target,'f');
            end
        end
    end
end
