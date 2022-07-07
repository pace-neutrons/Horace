function  tests_path = process_unit_test_path(init, set_path)
% method finds out path to unit tests and other admin folders  and,
% depending on init option, adds or removes this path from the Matlab
% search path
%
pths = paths;
rootpath = pths.root;
tests_path = fullfile(rootpath,'_test');
if ~(is_folder(tests_path))
    if init
        warning('HERBERT_INIT:invalid_setup',...
            'Can not set-up access to the unit tests as no unit tests at %s are available',...
            tests_path);
    end
    tests_path = '';
    return;
end
system_admin = fullfile(rootpath,'admin');
xunit_path = fullfile(rootpath, '_test', 'shared', 'matlab_xunit', 'xunit');  % path for unit tests harness
xunit_path_extras = fullfile(rootpath, '_test', 'shared', 'matlab_xunit_ISISextras');  % path for additional functions
% add to path the MPI unit tests as these have to be on the  path for all MPI workers
mpi_path = fullfile(tests_path,'test_mpi');

% if the connection is done dynamically, additional folders should be added to Horace too
% not a real dependency, though not nice Herbert knows about Horace.
hor_path = pths.horace;

if nargin>1
    common_path= fullfile(tests_path,'common_functions');   % path for unit tests
    if init
        addpath(common_path);
        addpath(xunit_path);
        addpath(xunit_path_extras);
        addpath(mpi_path);
        addpath(system_admin);
        if ~isempty(hor_uproot)
            addpath(fullfile(hor_uproot,'admin'));
            addpath(fullfile(hor_uproot,'_test','common_functions'));
        end
    else
        warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent path)
        rmpath(xunit_path_extras);
        rmpath(xunit_path);
        rmpath(common_path);
        rmpath(mpi_path);
        rmpath(system_admin);
        if ~isempty(hor_uproot)
            rmpath(fullfile(hor_uproot,'admin'));
            rmpath(fullfile(hor_uproot,'_test','common_functions'));
        end
        warning(warn_state);    % return warnings to initial state
        tests_path  = [];
    end
end
