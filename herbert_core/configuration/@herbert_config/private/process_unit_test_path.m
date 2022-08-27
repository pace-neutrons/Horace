function  tests_path = process_unit_test_path(init, set_path)
% method finds out path to unit tests and other admin folders  and,
% depending on init option, adds or removes this path from the Matlab
% search path
%
pths = horace_paths;

if isempty(pths.horace) % Horace not initialised
    global root_path
    root_path = fileparts(pths.herbert);
    clobj = onCleanup(@() clear('global','root_path'));
end

rootpath = pths.root;
tests_path = pths.test;

if ~is_folder(tests_path)
    if init
        warning('HERBERT_INIT:invalid_setup',...
            'Can not set-up access to the unit tests as no unit tests at %s are available',...
            tests_path);
    end
    tests_path = '';
    return;
end

system_admin = pths.admin;
xunit_path = fullfile(pths.test, 'shared', 'matlab_xunit', 'xunit');  % path for unit tests harness
xunit_path_extras = fullfile(pths.test, 'shared', 'matlab_xunit_ISISextras');  % path for additional functions
% add to path the MPI unit tests as these have to be on the  path for all MPI workers
mpi_path = fullfile(pths.test,'test_mpi');

if nargin>1
    common_path = pths.test_common_func;   % path for unit tests
    if init
        addpath(common_path);
        addpath(xunit_path);
        addpath(xunit_path_extras);
        addpath(mpi_path);
        addpath(system_admin);
        if ~isempty(rootpath)
            addpath(pths.admin);
            addpath(pths.test_common_func);
        end
    else
        warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent path)
        rmpath(xunit_path_extras);
        rmpath(xunit_path);
        rmpath(common_path);
        rmpath(mpi_path);
        rmpath(system_admin);
        if ~isempty(rootpath)
            rmpath(pths.admin);
            rmpath(pths.test_common_func);
        end
        warning(warn_state);    % return warnings to initial state
        tests_path  = [];
    end
end
