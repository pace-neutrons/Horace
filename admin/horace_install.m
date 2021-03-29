function horace_install(varargin)
%HORACE_INSTALL install an instance of Horace
%
%  >> horace_install()
%  >> horace_install('herbert_root', /path/to/Herbert)
%  >> horace_install('horace_root', /path/to/Horace)
%  >> horace_install('herbert_root', /path/to/Herbert, 'horace_root', /path/to/Horace)
%
% Keyword Arguments:
% ------------------
%   herbert_root    The root directory of Herbert
%   horace_root     The root directory of Horace
%
HORACE_ON_PLACEHOLDER = '${Horace_CORE}';
HERBERT_ON_PLACEHOLDER = '${Herbert_CORE}';

install_root = fileparts(mfilename('fullpath'));
opts = parse_args(install_root, varargin{:});

% Find required files/directories
% Do this first before installing any files, so that we know we have everything
% before creating any files/directories
hor_init_dir = find_directory( ...
    'horace_init.m', ...
    {fullfile(install_root, 'Horace'), fullfile(opts.horace_root, 'horace_core')} ...
);
her_init_dir = find_directory( ...
    'herbert_init.m', ...
    {fullfile(install_root, 'Herbert'), fullfile(opts.herbert_root, 'herbert_core')} ...
);
horace_on_path = find_file( ...
    'horace_on.m.template', ...
    {install_root, fullfile(opts.horace_root, 'admin')} ...
);
herbert_on_path = find_file( ...
    'herbert_on.m.template', ...
    {install_root, fullfile(opts.herbert_root, 'admin')} ...
);
worker_path = find_file( ...
    'worker_v2.m.template', ...
    {install_root, fullfile(opts.horace_root, 'admin')} ...
);

% Find/create userpath - this is automatically added to Matlab path on launch
user_path = find_userpath();

% Install horace_on
install_file( ...
    horace_on_path, ...
    fullfile(user_path, 'horace_on.m'), ...
    {HORACE_ON_PLACEHOLDER, HERBERT_ON_PLACEHOLDER}, ...
    {hor_init_dir, her_init_dir} ...
);
% Install herbert_on
install_file( ...
    herbert_on_path, ...
    fullfile(user_path, 'herbert_on.m'), ...
    {HERBERT_ON_PLACEHOLDER}, ...
    {her_init_dir} ...
);
% Install worker_v2 script (required by parallel routines) to userpath
install_file(worker_path, fullfile(user_path, 'worker_v2.m'));

disp('Horace successfully installed.')
disp('Call ''horace_on'' to start using Horace.')

end


% -----------------------------------------------------------------------------
function opts = parse_args(install_root, varargin)
    %PARSE_ARGS parse install script options
    %
    % Use defaults that will work for the common Git checkout set-up, i.e.
    % Herbert and Horace cloned into a common directory
    %

    function validate_path(x, arg_name)
        validateattributes( ...
            x, {'string', 'char'}, {'scalartext'}, 'horace_install', arg_name ...
        );
    end

    hor_root_default = fileparts(install_root);
    her_root_default = fullfile(fileparts(hor_root_default), 'Herbert');

    parser = inputParser();
    % Default herbert_root is "<horace_root>/../Herbert"
    parser.addParameter( ...
        'herbert_root', ...
        her_root_default, ...
        @(x) validate_path(x, 'herbert_root') ...
    );
    % Default horace_root is one directory above this script
    parser.addParameter( ...
        'horace_root', ...
        hor_root_default, ...
        @(x) validate_path(x, 'horace_root') ...
    );
    parser.parse(varargin{:});
    opts = parser.Results;
end


function install_file(source, dest, placeholders, replace_strs)
    %INSTALL_FILE copy the given file to the given destination
    % if placeholders and replace_strs are given, then replace the string values
    % in placeholders with the string at the corresponding index in
    % replace_strs.
    %
    if ~exist('placeholders', 'var')
        copy_file(source, dest);
    else
        file_contents = fileread(source);
        for i = 1:numel(placeholders)
            file_contents = replace(file_contents, placeholders{i}, replace_strs{i});
        end
        write_file(dest, file_contents);
    end
end


function file_path = find_file(file_name, candidate_dirs)
    %FIND_FILE search for the given file name in the candidate directories
    % Throw 'HORACE:horace_install:file_not_found' if the file cannot be found.
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
            'HORACE:horace_install:file_not_found', ...
            ['Could not find file ''%s'' in any of the following ' ...
             'candidate paths:\n  %s'], ...
            file_name, ...
            strjoin(candidate_dirs, '\n  ') ...
        );
    end
end


function directory = find_directory(file_name, candidate_dirs)
    %FIND_DIRECTORY find the directory that contains the given file name
    % in 'candidate_dirs'
    %
    % Throw 'HORACE:horace_install:file_not_found' if a directory cannot be
    % found.
    %
    directory = fileparts(find_file(file_name, candidate_dirs));
end


function user_path = find_userpath()
    %FIND_USERPATH get the Matlab `userpath`
    % If the userpath does not exist, create it in the default place
    %
    % See `help userpath` for more info on Matlab's userpath.
    %
    user_path = userpath();
    if isempty(user_path)
        user_path = create_userpath();
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
                'HORACE:horace_install:io_error', ...
                'Could not create Matlab userpath directory ''%s'': %s.', ...
                user_path, err_msg ...
            );
        end
    end
    % Now add it to path so we don't need to restart Matlab
    addpath(userpath);
end


function write_file(file_path, contents)
    %WRITE_FILE create/overwrite file at the given path with the given text
    %
    [fid, err_msg] = fopen(file_path, 'w');
    if fid < 0
        error( ...
            'HORACE:horace_install:io_error', ...
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
            'HORACE:horace_install:io_error', ...
            'Could not copy file ''%s'' to ''%s'': %s.', ...
            source, dest, message ...
        );
    end
end
