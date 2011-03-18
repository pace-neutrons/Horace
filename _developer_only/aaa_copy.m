function aaa_copy (rel_source_root_path,target_root_path,classname,option,public_target)
% Copy files from a class template directory and its sub-directories to a particular class
%
%   >> aaa_copy (rel_source_path, target_root_path, classname)
%
%   rel_source_root_path Source directory relative to folder containing this function
%                       The bottom-most directory name in this path is used as the
%                       source folder
%
%   target_root_path    The target is constructed from this path, followed by the
%                       lowest directory in rel_source_root_path, followed by @<classname>
%                       
%   classname           Name of class
%
% E.g.
%   >> aaa_copy ('stuff\ops','c:\my_app\classes','xye')
%
%   source is   ...\stuff\ops
%   target is   'c:\my_app\classes\ops\@xye
%
% Options:
% --------
%   >> aaa_copy (...,option)
%       - missing or empty (default)
%           Ignores any files beginning with '_a' (service files) and '__' (example files)
%
%           [Can use this option to update existing classes without copying annoying examples
%           that will clutter up the existing folder. However, chnges to the template may require
%           changes to the specific routines as well]
%
%       - option = 'examples'
%           Ignores service files but copies the examples files
%
%           [Create new classes, or update existing class with a copy of examples to use as
%            templates for specific required of optional files]
%
%       - option = 'test'
%           Ignores service files but copies the example files and removes the leading '__'
%
%           [The example files are for a valid class, so this will create that class]
%
%   >> aaa_copy (...,option, public_target)
%       - Any example files (i.e. beginning '__' in source_path but not its sub-directories
%         are copied to the directory <target_root_path>\<public_target>\<classname>. The
%         examples in the sub-directories of the source_path are still copied to the default
%         target defined earlier.
%
%           [The examples as assumed to all be destined to go to another folder for this to
%            be appropriate, and that any examples in sub-folders are not. This will 
%            generally be the case
%         
% E.g.
%   >> aaa_copy ('stuff\ops','c:\my_app\classes','xye','examples','methods')
%
%   source is   ...\stuff\ops
%   target is   'c:\my_app\classes\methods\@xye     for examples in  ...\stuff\ops
%   target is   'c:\my_app\classes\ops\@xye         for examples in sub-folders


[func_path, func_name] = fileparts(mfilename('fullpath'));
source_root_path=fullfile(func_path,rel_source_root_path);  % full source_path

ind=strfind(source_root_path,filesep);
target_root_path_true=fullfile(target_root_path,source_root_path(ind(end)+1:end),['@',classname]);
    
% Parse options
if exist('option','var') && ~isempty(option)
    if strncmpi('examples',option,numel(option))
        files_to_ignore='_a.*';
        rename=false;
    elseif strncmpi('test',option,numel(option))
        files_to_ignore='_a.*';
        rename=true;
    else
        error('Unrecognised option')
    end
else
    files_to_ignore='_a.*;__*.*';
    rename=false;
end

if exist('public_target','var')
    public_root_target=fullfile(target_root_path,public_target,['@',classname]);
    move=true;
else
    move=false;
end

% Copy files, and rename examples if requested
if ~move
    % Can copy, with rename if required
    if ~rename
        directory_recurse(source_root_path, @copy_selected_files, source_root_path, target_root_path_true, '', files_to_ignore);
    else
        directory_recurse(source_root_path, @copy_selected_files, source_root_path, target_root_path_true, '', files_to_ignore, '__', '');
    end
else
    % Copy required files only to temporary directory then move, with rename if required
    % This avoids any possible overwriting or creation of unwanted folders
    tmpdir=fullfile(tempdir,str_random);
    directory_recurse(source_root_path, @copy_selected_files, source_root_path, tmpdir, '', files_to_ignore);
    if ~rename
        move_selected_files(tmpdir, tmpdir, public_root_target, '__*.*')
        directory_recurse(tmpdir, @move_selected_files, tmpdir, target_root_path_true);
    else
        move_selected_files(tmpdir, tmpdir, public_root_target, '__*.*', '', '__', '')
        directory_recurse(tmpdir, @move_selected_files, tmpdir, target_root_path_true, '', '', '__', '');
    end
    directory_recurse(tmpdir, @rmdir, 's');  % delete the temporary directory
end
