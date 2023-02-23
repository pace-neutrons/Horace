function the_dir = tmp_dir()
% Substitute standard tmp folder with users tmp folder
% for iDaaaS machines where standard tmp folder is randomly clearned up.
%
% Returns:
% tmp_dir   tempdir value on any machine
%
%            userpath()/tmp/   (usually /home/user_name/Documents/MATLAB/tmp/)
%            folder if the machine is identified as iDaaaaS machine.
%
%            workspace_location/tmp/ if the machine is identified as Jenkins

% Catch case of Jenkins
[is_jenk, ~, workspace] = is_jenkins();
if is_jenk
    the_dir = build_tmp_dir (workspace, 'tmp');
    return
end

% All other machines
folder_name = ['Horace_', herbert_version()];

if is_idaaas()
    location = userpath();
    if isempty(location)
        location = fileparts(which('startup.m'));
        if isempty(location)
            location = getenv('HOME');
        end
    end
    the_dir = build_tmp_dir (location, fullfile('tmp', folder_name));
    
else
    the_dir = build_tmp_dir (tempdir(), folder_name);
end

% -------------------------------------------------------------------------
function the_dir = build_tmp_dir (location, folder_name)
% Create new folder fullfile(location,folder_name) if doesn't already exist.

the_dir = fullfile (location, folder_name);
if ~is_folder(the_dir)
    [ok, the_dir, mess] = try_to_create_folder (location, folder_name);
    if ~ok
        warning('HERBERT:tmp_dir:runtime_error',...
            ' Can not create temporary folder in user directory: %s. Reason: %s Reverting to system tmp folder',...
            location,mess);
        the_dir = tempdir();
    end
end

% Dereference simulinks and obtain real path
[~, values] = fileattrib (the_dir);
the_dir = [values.Name, filesep];
if ~is_folder(the_dir)
    mkdir(the_dir);
end
