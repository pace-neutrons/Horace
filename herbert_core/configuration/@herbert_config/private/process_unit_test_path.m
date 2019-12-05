function  tests_path = process_unit_test_path(init,set_path)
% method finds out path to unit tests and other admin folders  and,
% depending on init option, adds or removes this path from the Matlab
% search path
%
rootpath = herbert_root();
tests_path = fullfile(rootpath,'_test');
system_admin = fullfile(rootpath,'admin');
xunit_path= fullfile(tests_path,'matlab_xunit','xunit');  % path for unit tests harness
xunit_path_extras= fullfile(tests_path,'matlab_xunit_ISISextras');  % path for additional functions
% add to path the MPI unit tests as these have to be on the  path for all MPI workers
mpi_path = fullfile(tests_path,'test_mpi');

% if the connection is done dynamically, additional folders should be added to Horace too
% not a real dependency, thouth not nice Herbert knows about Horace.
hor_path = which('horace_init');
if isempty(hor_path)
    hor_uproot = '';
else
    hor_uproot = fileparts(hor_path);
end


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
        end
        warning(warn_state);    % return warnings to initial state
        tests_path  = [];
    end
end
