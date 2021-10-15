function [install_root,her_init_dir,hor_init_dir] = ...
    horace_install(varargin)
% Install an instance of Horace at the place, where the Horace package have
% been unpacked.
% Usage
%  >>horace_install()
%  >>horace_install('herbert_root',/path/to/Herbert)
%  >>horace_install('horace_root',/path/to/Horace)
%  >>horace_install('herbert_root',/path/to/Herbert,'horace_root',/path/to/Horace)
%
% Optional arguments:
% ------------------
% herbert_root--   The root directory of Herbert code
% horace_root --   The root directory of Horace code
% test_mode   -- if true, do not install Horace but return installation
%              folders, i.e. the folder where Horace/Herbert and horace_on
%              herbert_on would be located on installation.
%              Used to test the script
%
% Defaults (no arguments)
%  the horace_install script is located either in the folder, where Horace
%  and  Herbert folders are extracted to (installation archive) or in
%  /Horace/admin folder (cloned from the Github directly)
%
HORACE_ON_PLACEHOLDER = '${Horace_CORE}';
HERBERT_ON_PLACEHOLDER = '${Herbert_CORE}';

code_root = fileparts(mfilename('fullpath'));
% are we installing the package cloned from git repository?
[path,folder_name] = fileparts(code_root);
if strcmp(folder_name,'admin')
    [path,folder_name] = fileparts(path);
    if strcmp(folder_name,'Horace')
        % yes, we use clone from Github
        code_root = path; % make the location of the code init routne
        % one level up then Horace code tree itself
    end
end
opt = parse_args(code_root,varargin{:});

% is there an old installation present?
old_horace_on = which('horace_on');
if ~isempty(old_horace_on)
    if ~opt.test_mode
        delete(old_horace_on);
    end
    [~,ERRID]=lastwarn;
    if strcmp(ERRID,'MATLAB:DELETE:Permission') && exist(old_horace_on,'file')==2
        % attempt to install custom Horace from an account without the root
        % access but having Horace already installed under administrator.
        % Use custom location and note that horace parallel extensions will
        % unlikely work
        warning('HORACE:installation',...
            ['Installing Horace on a machine without administrative access where another Horace has been installed by administrator\n',...
            'Parallel extensions will not work properly']);
        use_existing_path = false;
        install_root= fullfile(code_root,'ISIS');
    else
        use_existing_path = true;
        install_root = fileparts(old_horace_on);
    end
else
    use_existing_path = false;
    install_root= fullfile(code_root,'ISIS');
end


if ~opt.test_mode
    try % remove from search path any possible previous version of Horace/Herbert
        herbert_off();
    catch % ignore errors if the code has not been installed before and script
    end   % has not been found
    try
        horace_off();
    catch  % ignore errors if the code has not been installed before and script
    end    % has not been found
    %
    
    old_herbert_on = which('herbert_on');
    if ~isempty(old_herbert_on)
        delete(old_herbert_on);
    end
    
    if ~exist(install_root,'dir')
        mkdir(install_root);
    end
    if ~use_existing_path % path have already been modified. Do not create mess
        addpath(install_root);
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
    {fullfile(code_root, 'Horace'), fullfile(opt.horace_root, 'horace_core')} ...
    );
her_init_dir = find_directory( ...
    'herbert_init.m', ...
    {fullfile(code_root, 'Herbert'), fullfile(opt.herbert_root, 'herbert_core')} ...
    );
horace_on_path = find_file( ...
    'horace_on.m.template', ...
    {code_root, fullfile(opt.horace_root, 'admin')} ...
    );
herbert_on_path = find_file( ...
    'herbert_on.m.template', ...
    {code_root, fullfile(opt.herbert_root, 'admin')} ...
    );
worker_path = find_file( ...
    'worker_v2.m.template', ...
    {code_root, fullfile(opt.horace_root, 'admin')} ...
    );
if opt.test_mode
    return;
end
% Install horace_on
install_file( ...
    horace_on_path, ...
    fullfile(install_root, 'horace_on.m'), ...
    {HORACE_ON_PLACEHOLDER, HERBERT_ON_PLACEHOLDER}, ...
    {hor_init_dir, her_init_dir} ...
    );
% Install herbert_on
install_file( ...
    herbert_on_path, ...
    fullfile(install_root, 'herbert_on.m'), ...
    {HERBERT_ON_PLACEHOLDER}, ...
    {her_init_dir} ...
    );
% Install worker_v2 script (required by parallel routines) to userpath
install_file(worker_path, fullfile(install_root, 'worker_v2.m'));

% Validate the installation
validate_function(@herbert_on, @herbert_off);
validate_function(@horace_on, @horace_off);

disp('Horace successfully installed.')
disp('Call ''horace_on'' to start using Horace.')

end


% -----------------------------------------------------------------------------
function opts = parse_args(code_root, varargin)
% Parse install script options and identify default package
% location(s)
%
if ismember('-test_mode',varargin)
    tm = ismember(varargin,'-test_mode');
    argi = varargin(~tm);
    test_mode = true;
else
    argi = varargin;
    test_mode = false;
end


    function validate_path(x, arg_name)
        validateattributes( ...
            x, {'string', 'char'}, {'scalartext'},...
            'horace_install', arg_name );
    end

hor_root_default = fullfile(code_root, 'Horace');
% Default herbert_root is "<horace_root>/../Herbert"
her_root_default = fullfile(code_root, 'Herbert');

parser = inputParser();
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
parser.parse(argi{:});
%
opts = parser.Results;
opts.test_mode = test_mode;

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
% validate the given function can ve called
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
