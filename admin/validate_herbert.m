function err = validate_herbert(varargin)
% Run unit tests on Herbert installation
%
%   >> validate_herbert([test_directory1, test_directory2, mode_key1, mode_key2...])
%
% Arguments:
%
%  'test_folders' A list of test directories to run.
%                 These should be relative to Herbert's '_test' directory. If
%                 not specified, all test directories are run.
%
% possible input keys:
%
% '-parallel'   Enables parallel execution of unit tests if the parallel
%              computer toolbox is available. Needs large memory as some
%              tests start its own version of parallel computing toolbox.
%
% '-verbose'   prints output of the tests and
%              various herbert log messages (log_level in configurations
%              is set to default, not quiet as default)
%
% '-exit_on_completion'  exit Matlab when the tests are completed.
%               This option is useful when running tests from
%               a script or continuous integration tools.
% Returns:
%   err -- 0 if tests are successful and -1 if some tests have failed

% For running from shell script:
err = -1;
if isempty(which('herbert_init'))
    herbert_on();
end

% Parse arguments
% ---------------
options = {'-parallel', '-verbose', '-exit_on_completion'};
[ok, mess, parallel, talkative, exit_on_completion, test_folders] = ...
    parse_char_options(varargin, options);
if ~ok
    error('VALIDATE_HERBERT:invalid_argument', mess)
end


%==============================================================================
% Place list of test folders here (relative to the master _test folder)
% -----------------------------------------------------------------------------
if isempty(test_folders) % No tests specified on command line - run them all
    test_folders = { ...
        'test_data_loaders', ...
        'test_config', ...
        'test_IX_classes', ...
        'test_map_mask', ...
        'test_utilities', ...
        'test_geometry',...
        'test_instrument_classes', ...
        'test_docify', ...
        'test_admin', ...
        'test_multifit', ...
        'test_multifit_legacy', ...
        'test_mpi_wrappers', ...
        'test_mpi', ...
        'test_xunit_framework', ...
        };
end
%=============================================================================
initial_warn_state = warning();
warning('off', 'MATLAB:class:DestructorError');

% Set Herbert configuration to the default (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)
hc = herbert_config();
current_conf = hc.get_data_to_store();
hc.init_tests = 1; % initialize unit tests
hc.log_level = 1;
%
pcf = parallel_config();
par_config = pcf.get_data_to_store();
pcf.shared_folder_on_local = tmp_dir;

% Generate full test paths to unit tests:
rootpath = fileparts(fileparts(which('herbert_init')));
test_path = fullfile(rootpath, '_test'); % path to folder with all unit tests folders:
test_folders_full = cellfun(...
    @(x) fullfile(test_path, x), test_folders, 'UniformOutput', false);
%

cleanup_obj = onCleanup(@()herbert_test_cleanup(...
    current_conf, par_config,test_folders_full, initial_warn_state));

clear config_store;

% On exit always revert to initial Herbert configuration
% ------------------------------------------------------
% (Validation must always return Herbert to its initial state, regardless
%  of any changes made in the test routines. For example, as of 23/10/13
%  the call to @loader_ascii\load_data will set use_mex=false if a
%  problem is encountered, and will save the configuration. This is
%  appropriate action when deployed, but we do not want this to be done
%  during validation)


% Run unit tests
% --------------
if talkative
    argi = {'-verbose'};
else
    hc.log_level = -1; % turn off herbert informational output
    argi = {};    
end


if parallel && license('checkout', 'Distrib_Computing_Toolbox')
    cores = feature('numCores');
    if matlabpool('SIZE') == 0
        if cores > 12
            cores = 12;
        end
        matlabpool(cores);
    end

    test_ok = false(1, numel(test_folders_full));
    time = bigtic();
    parfor i = 1:numel(test_folders_full)
        addpath(test_folders_full{i})
        test_ok(i) = runtests(test_folders_full{i}, argi{:})
        rmpath(test_folders_full{i})
    end
    bigtoc(time, '===COMPLETED UNIT TESTS IN PARALLEL');
    tests_ok = all(test_ok);
else
    time = bigtic();
    tests_ok= runtests(test_folders_full{:}, argi{:});
%     test_ok = false(1,numel(test_folders_full));
%     for i=1:numel(test_folders_full)
%         fprintf('=== Starting tests for: %s\n',test_folders_full{i});
%         [test_ok(i),suite] = runtests(test_folders_full{i}, argi{:});
%         suite.delete();
%     end
%     tests_ok = all(test_ok);
    bigtoc(time, '===COMPLETED UNIT TESTS RUN ');

end

if tests_ok
    err = 0;
end
if exit_on_completion
    exit(err);
end

%==============================================================================
function herbert_test_cleanup(old_her_config,old_pc_config,test_folders, initial_warn_state)
% Reset the configuration
set(herbert_config, old_her_config);
set(parallel_config,old_pc_config);
% clear up the test folders, previously placed on the path
warning('off', 'all'); % avoid varnings on deleting non-existent path
for i = 1:numel(test_folders)
    rmpath(test_folders{i});
end
warning(initial_warn_state);
