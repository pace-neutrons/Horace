function horace_install()
%HORACE_INSTALL install this instance of Horace
%
HORACE_ON_SUB_PATTERN = '${Horace_CORE}';
HERBERT_ON_SUB_PATTERN = '${Herbert_CORE}';

install_root = fileparts(mfilename('fullpath'));

% Find directories containing herbert/horace_init.m
hor_init_dir = find_init_dir('Horace');
her_init_dir = find_init_dir('Herbert');

% Find and update horace_on
horace_on_path = find_file('horace_on.m.template', {install_root});
horace_on_contents = fileread(horace_on_path);
new_hor_on_contents = replace(horace_on_contents, HORACE_ON_SUB_PATTERN, hor_init_dir);
new_hor_on_contents = replace(new_hor_on_contents, HERBERT_ON_SUB_PATTERN, her_init_dir);

% Find and update herbert_on
herbert_on_path = find_file('herbert_on.m.template', {install_root});
herbert_contents = fileread(herbert_on_path);
new_her_on_contents = replace(herbert_contents, HERBERT_ON_SUB_PATTERN, her_init_dir);

% Find/create userpath - this is automatically added to Matlab path on launch
user_path = find_userpath();

% Write the herbert/horace_on files (containing paths to package) into userpath
write_file(fullfile(user_path, 'horace_on.m'), new_hor_on_contents);
write_file(fullfile(user_path, 'herbert_on.m'), new_her_on_contents);

% Copy worker_v2 script (required by parallel routines) to userpath
worker_path = find_file('worker_v2.m.template', {install_root});
copy_file(worker_path, fullfile(user_path, 'worker_v2.m'));

end


% -----------------------------------------------------------------------------
function init_dir = find_init_dir(package_name, install_root)
    %FIND_INIT find the directory that contains <package_name>_init.m
    %
    candidate_dirs = {fullfile(install_root, package_name)};

    init_name = sprintf('%s_init.m', lower(package_name));
    init_dir = fileparts(find_file(init_name, candidate_dirs));
end


function file_path = find_file(file_name, candidate_dirs)
    %FIND_FILE search for the given file name in the candidate directories
    % Throw 'HORACE:INSTALL:file_not_found' if the file cannot be found.
    %
    file_dir = '';
    for i = 1:numel(candidate_dirs)
        candidate_file_path = fullfile(candidate_dirs{i}, file_name);
        if exist(candidate_file_path, 'file') == 2
            file_path = candidate_file_path;
            return
        end
    end
    if isempty(file_dir)
        error( ...
            'HORACE:INSTALL:file_not_found', ...
            ['Could not find file ''%s'' in any of the following ' ...
             'candidate paths:\n  %s'], ...
            file_name, ...
            strjoin(candidate_dirs, '\n  ') ...
        );
    end
end


function user_path = find_userpath()
    %FIND_USERPATH get the Matlab `userpath`
    % If the userpath does not exist, create it in the default place
    %
    % See `help userpath` for more info on Matlab's userpath.
    %
    user_path = userpath();
    if isempty(user_path)
        user_path = create_userpath;
    end
end


function user_path = create_userpath()
    %CREATE_USERPATH create the Matlab userpath directory in the default place
    %
    if ispc
        user_dir = getenv('USERPROFILE');
    else
        user_dir = getenv('HOME');
    end
    user_path = fullfile(user_dir, 'Documents', 'MATLAB');
    if ~exist(user_path, 'dir')
        [ok, err_msg] = mkdir(user_path);
        if ~ok
            error( ...
                'HORACE:INSTALL:io_error', ...
                'Could not create Matlab userpath directory ''%s'': %s.', ...
                user_path, err_msg ...
            );
        end
    end
end


function write_file(file_path, contents)
    %WRITE_FILE create/overwrite file at the given path with the given text
    %
    [fid, err_msg] = fopen(file_path, 'w');
    if fid < 0
        error( ...
            'HORACE:INSTALL:io_error', ...
            'Could not create file ''%s'': %s.', ...
            file_path, err_msg ...
        );
    end
    cleanup_fid = onCleanup(@() fclose(fid));
    fprintf(fid, '%s', contents);
end


function copy_file(source, dest)
    %COPY_FILE copy the file 'source' to 'dest', throw an error if unsuccessful
    %
    [ok, message] = copyfile(source, dest);
    if ~ok
        error( ...
            'HORACE:INSTALL:io_error', ...
            'Could not copy file ''%s'' to ''%s'': %s.', ...
            source, dest, message ...
        );
    end
end
