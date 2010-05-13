function make_linux64_kit
% This is a script to create a Linux 64 installation of Horace
%
% Run from the root area of Horace as checked out from the SVN server
% It will convert the code as checked out into an installation with p-code
% files and m-file help

fileroot=pwd;

% Delete unwanted directories (with all their sub-directories)
% ------------------------------------------------------------
deldir{1}='developer_only';
deldir{2}='documentation';  % as for private consumption only at the moment
%deldir{3}='GUI';            % as prototype only at the moment
deldir{3}='test';
deldir{4}='work_in_progress';

for i=1:numel(deldir)
    directoryRecurse(fullfile(fileroot,deldir{i}),@rmdir,'s')
end


% Convert mfiles to p-files and help-only m-files in the following
% -----------------------------------------------------------------
filepath{1}='@d0d/private';
filepath{2}='@d1d/private';
filepath{3}='@d2d/private';
filepath{4}='@d3d/private';
filepath{5}='@d4d/private';
filepath{6}='@sqw';
filepath{7}='@sqw/private';
filepath{8}='@sigvar';
filepath{9}='@sigvar/private';

filepath{10}='libisis/@d1d';
filepath{11}='libisis/@d2d';
filepath{12}='libisis/@d3d';
filepath{13}='libisis/@sqw';
filepath{14}='private';

for i=1:numel(filepath)
    generate_pcode(fullfile(fileroot,filepath{i}))
end

% Remove all the .svn folders
directoryRecurse(fileroot,@remove_svn)

% Finally, delete this file (and similar windows kit)
delete 'make_win32_kit.m'
delete 'make_linux64_kit.m'

%===============================================================================
function generate_pcode(directory)
% Create p-code and m-file with only the help text for all m files in the given directory.

% Need to create p-files before creating the corresponding mfiles with only the help text
% to avoid getting matlab warnings that the pfiles may be out of date. Hence the cumbersome
% creation of the temporary area.

curr_dir = pwd;
fprintf('Converting m-files to p-code in %s:\n',pwd);

% Work to be done only if there is an m-file other than contents.m
mfiles=dir(fullfile(directory,'*.m'));
if isempty(mfiles) || (numel(mfiles)==1 && strcmpi(mfiles(1).name,'contents.m'))
    fprintf('No m-files to convert')
    return
end

% Create temporary directory in which to create .p files and copy mfiles to that temporary area
tmpdir = fullfile(curr_dir,'mfile_tmpdir');
if ~exist(tmpdir,'dir')
    mkdir(tmpdir);
else
    delete(fullfile(tmpdir,'*.*'))
end

copyfile(fullfile(directory,'*.m'),tmpdir,'f')
if exist(fullfile(tmpdir,'contents.m'),'file')     % delete contents.m from temporary area, as do not want to pcode it
    delete(fullfile(tmpdir,'contents.m'))
end


% Move to directory
cd(directory);

% Create help files and pcode files
for i=1:numel(mfiles)
    current_mfile = mfiles(i).name;
    if(~strcmpi(current_mfile,'contents.m'))
        fprintf('    %s\n',current_mfile);
        helptext = help(current_mfile);
        new_line = find(helptext==char(10));    % position of new lines
        helptext([1 new_line+1]) = '%';
        fid = fopen(current_mfile,'wt');
        fprintf(fid,'%s',helptext);
        fclose(fid);
    end
end

% Create pfiles (note: destination directory is the current directory when using pcode function)
cd(tmpdir)
warn_state=warning('off','all');    % turn of warnings (so don't get message if create file with name matching a built-in)
pcode *.m
copyfile('*.p',directory,'f')
warning(warn_state);    % return warnings to initial state
cd(curr_dir);
rmdir(tmpdir,'s')   % delete temporary area


%===============================================================================
function remove_svn (directory)
% If present, removes directory .svn from absolute directory name passed as argument
contents=dir(directory);
ind_svn=find(strcmpi('.svn',{contents([contents.isdir]).name}),1);
if ~isempty(ind_svn)
    rmdir(fullfile(directory,contents(ind_svn).name),'s')
end



%===============================================================================
% directoryRecurse - Recurse through sub directories executing function pointer
%===============================================================================
% Description   : Recurses through each directory, passing the full directory
%                 path and any extraneous arguments (varargin) to the specified
%                 function pointer
%
% Parameters    : directory        - Top level directory begin recursion from
%                 function_pointer - function to execute with each directory as
%                                    its first argument
%                 varargin         - Any extra arguments that should be passed
%                                    to the function pointer.
%
% Call Sequence : directoryRecurse(directory, function_pointer, varargin)
%
%                 IE: To execute the 'rmdir' command with the 's' parameter over
%                     'c:\tmp' and all subdirectories
%
%                     directoryRecurse('c:\tmp', @rmdir, 's')
%
% Author        : Rodney Thomson
%                 http://iheartmatlab.blogspot.com
%===============================================================================
function directoryRecurse(directory, function_pointer, varargin)

contents    = dir(directory);
directories = find([contents.isdir]);

% For loop will be skipped when directory contains no sub-directories
for i_dir = directories

    sub_directory  = contents(i_dir).name;
    full_directory = fullfile(directory, sub_directory);

    % ignore '.' and '..'
    if (strcmp(sub_directory, '.') || strcmp(sub_directory, '..'))
        continue;
    end

    % Recurse down
    directoryRecurse(full_directory, function_pointer, varargin{:});
end

% execute the callback with any supplied parameters.
% Due to recursion will execute in a bottom up manner
function_pointer(directory, varargin{:});

