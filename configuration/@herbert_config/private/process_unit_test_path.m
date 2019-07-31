function  tests_path = process_unit_test_path(init,set_path)
% method finds out path to unit tests and, depending on
% init, adds or removes this path from matlab search path
%
rootpath = fileparts(which('herbert_init'));
tests_path = fullfile(rootpath,'_test');
xunit_path= fullfile(tests_path,'matlab_xunit','xunit');  % path for unit tests harness
xunit_path_extras= fullfile(tests_path,'matlab_xunit_ISISextras');  % path for additional functions
% add to path the MPI unit tests as these have to be on the  path for all MPI workers
mpi_path = fullfile(tests_path,'test_mpi');


if nargin>1
    common_path= fullfile(tests_path,'common_functions');   % path for unit tests
    if init
        addpath(common_path);
        addpath(xunit_path);
        addpath(xunit_path_extras);
        addpath(mpi_path);
    else
        warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent path)
        rmpath(xunit_path_extras);
        rmpath(xunit_path);
        rmpath(common_path);
        rmpath(mpi_path);
        warning(warn_state);    % return warnings to initial state
        tests_path  = [];
    end
end
