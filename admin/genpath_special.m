function p = genpath_special (d)
% Generate recursive toolbox path excluding .svn or .git and service folders, which start from 
% symbol _
%
% Slightly modified version of Matlab intrinsic genpath.
%
%GENPATH Generate recursive toolbox path.
%   P = GENPATH returns a new path string by adding all the subdirectories
%   of MATLABROOT/toolbox, including empty subdirectories.
%
%   P = GENPATH(D) returns a path string starting in D, plus, recursively,
%   all the subdirectories of D, including empty subdirectories.
%
%   NOTE 1: GENPATH will not exactly recreate the original MATLAB path.
%
%   NOTE 2: GENPATH only includes subdirectories allowed on the MATLAB
%   path.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision:: 830 ($Date:: 2019-04-08 14:20:59 +0100 (Mon, 8 Apr 2019) $
%------------------------------------------------------------------------------

if nargin==0
    p = genpath(fullfile(matlabroot,'toolbox'));
    if length(p) > 1, p(end) = []; end % Remove trailing pathsep
    return
end

% initialise variables
classsep = '@';  % qualifier for overloaded class directories
packagesep = '+';  % qualifier for overloaded package directories
svn        = '.svn'; % subversion folder
service_dir = '_'; % qualifier for service folders

exclude_list  = {'.','@','+','.'};
p = '';           % path to be returned


% Generate path based on given root directory
files = dir(d);
if isempty(files)
    return
end

% Add d to the path even if it is empty.
p = [p d pathsep];

% set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
dirs = files(isdir); % select only directory entries from the current listing

for i=1:length(dirs)
    dirname = dirs(i).name(1);
    if  ~any(ismember(exclude_list,dirname))
        dirname = dirs(i).name;
        if ~strncmp( dirname,service_dir,1)
            if strcmp(dirname,'private'); continue; end
            
            p = [p genpath_special(fullfile(d,dirname))]; % recursive calling of this function.
        else
            if strcmpi(['_',computer],dirname)
                % if folder has form _PCWIN64 or underscore followed by another operating system,
                % put this and the relevant matlab mex file directory on the path
                p = [p fullfile(d,dirname) pathsep];
                matlab_dir_name=matlab_version_folder(dirname);
                if ~isempty(matlab_dir_name)
                    p = [p fullfile(d,dirname,matlab_dir_name) pathsep];
                end

            end
        end
        
    end
end
