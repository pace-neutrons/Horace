function move_selected_files (source, root_source, root_target, varargin)
% move selected files from source to target directories, retaining relative paths
%
%   >> list = move_selected_files (source, root_source, root_target)
%   >> list = move_selected_files (source, root_source, root_target, include)
%   >> list = move_selected_files (source, root_source, root_target, include, exclude)
%
% Input:
% --------
%   source          Source folder (full path)
%   root_source     Root folder from which to get relative path of source
%   root_target     Root folder for relative path to which to move
%
% Optional:
% ---------
%   include         List of file names to include (default: all)
%                   Format: e.g. 'temp.txt', 'te*.*; *mat*.m'
%                   If empty, then uses default
%   exclude         List of directory names to exclude (default: none)
%                   Format: e.g. 'temp.txt', 'te*.*; *mat*.m'
%
%   str_pattern     The first occurence of this string pattern in each filename
%                  will be replaced with the following:
%   str_replace     Replacement string

% *** make sure is synchronised with copy_selected _files

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
    
% Get list of files to move
filename=file_name_list(source,varargin{1:min(narg,2)});  

% Move files
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
            movefile(fullfile(source,filename{i}),target,'f');
        end
    else
        n=numel(str_pattern);
        for i=1:numel(filename)
            if strncmp(str_pattern,filename{i},n)
                movefile(fullfile(source,filename{i}),fullfile(target,[str_replace,filename{i}(n+1:end)]),'f');
            else
                movefile(fullfile(source,filename{i}),target,'f');
            end
        end
    end
end
