function [init_folder,hor_init_dir,use_old_init_path] = ...
    horace_install(varargin)
% Install and initialize Horace at the location, where the Horace package
% has been unpacked.
%
% Usage:
%  >>horace_install()
%  >>horace_install('horace_root',/path/to/Horace)
%  >>horace_install(__,'init_folder',/path/to/place/where/init_files/to_be_installed)
%
% Optional arguments:
% ------------------
% horace_root --   The root directory where Horace code is unpacked.
%                  Necessary only if run horace_install from non-standard
%                  location, where it has been unpacked from archive or
%                  not from <>/Horace/admin folder.
% init_folder --   The folder, where init files (horace_on,herbert_on,worker)
%                  to be installed. If missing,
%                  <path to Horace code>/../ISIS folder is selected.
%                  This folder will be added to Matlab search path.
%
% test_mode   -- if true, do not install Horace but return installation
%              folders, i.e. the folder where Horace and horace_on
%              would be located on installation.
%              Used to test the script. Should not be used in production
%
% Defaults (no arguments)
%  the horace_install script is located either in the folder, where Horace
%  and  Herbert folders are extracted to (installation archive) or in
%  /Horace/admin folder (cloned from the Github directly)
%
% Output parameters:
%  Expected to be used in test mode only.
%
HORACE_ON_PLACEHOLDER = '${Horace_CORE}';

% presumably the code root is where this file is located
code_root = fileparts(mfilename('fullpath'));
% but, are we installing the package cloned from git repository?
[code_root,hor_checkup_folder] = check_layout_options(code_root);

% is there an old installation present? Use old Horace init directory not
% to create mess
old_horace_on = which('horace_on');
old_init_folder = fileparts(old_horace_on);
%
% Are some path or parameters provided as input? If not, use defaults
opt = parse_args(code_root,old_init_folder,...
    hor_checkup_folder,varargin{:});
%
if ~isempty(old_horace_on)
    if ~opt.test_mode
        delete(old_horace_on);
    end
    [~,ERRID]=lastwarn;
    if strcmp(ERRID,'MATLAB:DELETE:Permission') && exist(old_horace_on,'file')==2
        % attempt to install custom Horace from an account without the root
        % access but having Horace already installed under administrator.
        % Use custom location and note that Horace parallel extensions will
        % unlikely work
        warning('HORACE:installation',...
            ['Installing Horace on a machine without administrative access',...
            ' where another Horace has been installed by administrator\n',...
            'Parallel extensions will not usually work properly']);
        % it should already be false, but let's reinforce it
        opt.use_old_init_path = false;
    end
end
use_old_init_path = opt.use_old_init_path;
init_folder= opt.init_folder;


if ~opt.test_mode
    try
        horace_off();
    catch  % ignore errors if the code has not been installed before and script
    end    % has not been found
    %

    % remove herbert_on which may be left from previous installations
    old_herbert_on = which('herbert_on');
    if ~isempty(old_herbert_on)
        delete(old_herbert_on);
    end

    if ~exist(init_folder,'dir')
        mkdir(init_folder);
    end
    %if use_existing_path path have already been modified. Do not create mess
    %
    if ~use_old_init_path
        if ~isempty(old_init_folder)
            rmpath(old_init_folder);
        end
        addpath(init_folder);
        err = savepath();
        if err
            userpath = find_userpath();
            warning('HORACE:installation',...
                ['Can not save installation-modified pathdef into system-restricted area.',...
                ' Saving modified pathdef.m into userpath: %s'],...
                userpath);
            savepath(fullfile(userpath,'pathdef.m'));
        end
    end
end

% Find required files/directories
% Do this first before installing any files, so that we know we have everything
% before creating any files/directories
hor_init_dir = find_directory( ...
    'horace_init.m', ...
    {opt.horace_root,fullfile(opt.horace_root,'horace_core')}...
    );

horace_on_path = find_file( ...
    'horace_on.m.template', ...
    {code_root, fullfile(opt.horace_root, 'admin')} ...
    );
% take worker_v4 template from Horace/admin
worker_path = find_file( ...
    'worker_v4.m.template', ...
    {code_root, fullfile(opt.horace_root, 'admin')} ...
    );
if opt.test_mode
    return;
end
% Install horace_on
install_file( ...
    horace_on_path, ...
    fullfile(init_folder, 'horace_on.m'), ...
    {HORACE_ON_PLACEHOLDER}, {hor_init_dir} ...
    );
% Install worker_v4 script (required by parallel routines) to user-path
install_file(worker_path, fullfile(init_folder, 'worker_v4.m'));

% Validate the installation
validate_function(@horace_on, @horace_off);

disp('Horace successfully installed.')
disp('Call ''horace_on'' to start using Horace.')

end
% -----------------------------------------------------------------------------
function [code_root,hor_checkup_folder] = check_layout_options(code_root)
% Check various code layout options in case installation is performed from
% zip file, Github or by Jenkins
%
if exist(fullfile(code_root,'Horace'),'dir')==7 && ... % zip file installation
        exist(fullfile(code_root,'Herbert'),'dir')==7
    hor_checkup_folder = 'Horace';
    return;
end
% Github or Jenkins installation
[path,folder_name] = fileparts(code_root);
if strcmp(folder_name,'admin')
    [path1,hor_checkup_folder] = fileparts(path);
    if strcmpi(hor_checkup_folder,'Horace')
        % yes, we use clone from GitHub into Horace folder
        code_root = path1; % make the location of the code init routine
        % one level up then Horace code tree itself
    else % cloned directly into some root folder (Jenkins)
        code_root = path;
        hor_checkup_folder = '';
    end
else
    hor_checkup_folder = 'Horace'; % when installed from zip file, this is where
    % Horace is located, and install script is one level above
end

end

% -----------------------------------------------------------------------------
function opts = parse_args(code_root,init_folder_default,...
    hor_checkup_folder, varargin)
% Parse install script options and identify default package
% location(s)
%
    test_mode = ismember('-test_mode',varargin);
    if test_mode
        tm = ismember(varargin,'-test_mode');
        argi = varargin(~tm);
    else
        argi = varargin;
    end

    function validate_path(x, arg_name)

        validateattributes( ...
            x, {'string', 'char'}, {'scalartext'},...
            'horace_install', arg_name );

    end

    % Default horace_root is "<check_up_folder_name>/Horace", but Jenkins
    % checks it up directly into check_up_folder_name.
    hor_root_default = fullfile(code_root, hor_checkup_folder);
    % Default init folder location is either init folder where previous Horace
    % init files are located or, if clean installation, "<horace_root>/../ISIS"

    use_old_init_path = ~isempty(init_folder_default);
    if ~use_old_init_path
        init_folder_default = fullfile(code_root,'ISIS');
    end

    parser = inputParser();
    % Default horace_root is one directory above this script
    parser.addParameter( ...
        'horace_root', ...
        hor_root_default, ...
        @(x) validate_path(x, 'horace_root') ...
                       );
    parser.addParameter( ...
        'init_folder', ...
        init_folder_default, ...
        @(x) validate_path(x, 'init_folder') ...
                       );

    parser.parse(argi{:});

    opts = parser.Results;

    opts.test_mode = test_mode;
    % check if user provided some specific location for init folder, different
    % from the previous default location
    if ~strcmp(opts.init_folder, init_folder_default)
        use_old_init_path = false;
        % if user provided init folder without ISIS extension, add ISIS
        % extension to the folder name
        [~,folder_name] = fileparts(opts.init_folder);
        if ~strcmp(folder_name,'ISIS')
            opts.init_folder = fullfile(opts.init_folder,'ISIS');
        end
    end
    opts.use_old_init_path = use_old_init_path;
    opts.herbert_root = opts.horace_root;

end

function install_file(source, dest, placeholders, replace_strs)
% copy the given file to the given destination
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
% Create the Matlab userpath directory in the default place
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


function directory = find_directory(file_name, candidate_dirs)
% Find the directory that contains the given file name
% in 'candidate_dirs'
%
% Throw 'HORACE:horace_install:file_not_found' if a directory cannot be
% found.
%
directory = fileparts(find_file(file_name, candidate_dirs));
end


function write_file(file_path, contents)
% Create/overwrite file at the given path with the given text
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
%Copy the file 'source' to 'dest', throw an error if unsuccessful
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

function validate_function(func, post_func)
% validate the given function can be called
% The second argument is called after the first, with the intended purpose
% being clean up.
%
try
    func();
catch ME
    ERR = MException('HORACE:horace_install:failure', ...
        'Installation failed, error calling function: %s', ...
        ME.message);
    ERR=ERR.addCause(ME);
    throw(ERR);
end
post_func();
end
