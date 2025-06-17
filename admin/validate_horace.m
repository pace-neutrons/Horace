function err = validate_horace(varargin)
% Run unit tests on Horace installation
%
%   >> validate_horace                             %  Run full Horace validation
%   >> validate_horace (foldname)                  %  Run Horace validation on the named folder
%   >> validate_horace (foldname1, foldname2)      %  Run Horace validation on named folders
%   >> validate_horace (foldname_cell)             %  Run Horace validation on the folders named
%                                                  % in a cell array of names
%
% In addition, one of more options are allowed from the following
%
%   >> validate_horace (...'-parallel')            %  Enables parallel execution of unit tests
%                                                  % if the parallel computer toolbox is available
%   >> validate_horace (...'-talkative')           %  Prints output of the tests and horace
%                                                  % commands (log_level is set to default,not quiet)
%   >> validate_horace (...'-nomex')               %  Validate matlab code by forcefully disabling
%                                                  % mex even if mex files are available
%   >> validate_horace (...'-forcemex')            %  Enforce use of mex files only. The default
%                                                  % otherwise for Horace to revert to using
%                                                  % matlab code.
%   >> validate_horace (...'-disp_skipped')        %  Print list of both failed and skipped tests
%                                                  % (the default is not to print skipped test listing)
%   >> validate_horace (...'-exit_on_completion')  %  Exit Matlab when test suite ends
%   >> validate_horace (...'-no_system_tests')     %  Do not perform system tests (mpi, gen_sqw
%                                                  % and Tobyfit tests)
%   >> validate_horace (...'-herbert_only')        %  Run only tests related to herbert_core
%   >> validate_horace (...'-horace_only')         %  Run only tests related to horace_core
%   >> validate_horace (...'-combine_all')         % Combine all requested tests together
%                                                  % and run them in commonworkspace rather then
%                                                  % each test folder separately
%
% Exits with non-zero error code if any tests failed

if isempty(which('horace_init'))
    horace_on();
end

            
% Parse arguments
% ---------------
options = {'-parallel',  '-talkative',  '-nomex',  '-forcemex',...
    '-disp_skipped','-exit_on_completion','-no_system_tests',...
    '-herbert_only', '-horace_only','-combine_all'};
[ok, mess, parallel, talkative, nomex, forcemex, ...
    disp_skipped, exit_on_completion, no_system, ...
    herbert_only, horace_only,combine_all, test_folders] = ...
    parse_char_options(varargin, options);

if ~ok
    error('HORACE:validate_horace:invalid_argument', mess)
end

%==============================================================================
% Place list of test folders here (relative to the master _test folder)
% -----------------------------------------------------------------------------
if isempty(test_folders)
    % No tests specified on command line - run them all
    % read the tests from CMakeLists.txt
    [horace_tests, herbert_tests, system_tests] = read_tests_from_CMakeLists;

    if herbert_only && ~horace_only
        test_folders = herbert_tests;
    elseif horace_only && ~herbert_only
        test_folders = horace_tests;
    else
        test_folders = unique([herbert_tests, horace_tests], 'stable');
    end

end

if no_system
    no_sys = ~ismember(test_folders, system_tests);
    test_folders = test_folders(no_sys);
end

% Generate full test paths to unit tests
% --------------------------------------
pths = horace_paths;
test_path = pths.test;
test_folders_full = fullfile(test_path, test_folders);

hor = hor_config();
hpc = hpc_config();
par = parallel_config();
% Validation must always return Horace and Herbert to their initial states,
% regardless of any changes made in the test routines

% On exit always revert to initial Horace and Herbert configurations
% ------------------------------------------------------------------
initial_warn_state = warning();
warning('off', 'MATLAB:class:DestructorError');

% only get the public i.e. not sealed, fields
cur_horace_config = hor.get_data_to_store();
cur_hpc_config = hpc.get_data_to_store();
cur_par_config = par.get_data_to_store();

% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;

% Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@() ...
    validate_horace_cleanup(cur_horace_config, ...
    cur_hpc_config, ...
    cur_par_config, ...
    test_folders, ...
    initial_warn_state));

% Run unit tests
% --------------
argi = {};
if talkative
    argi = [argi, {'-verbose'}];
end
if ~disp_skipped
    argi = [argi, '-nodisp_skipped'];
end

if parallel && license('checkout',  'Distrib_Computing_Toolbox')
    cores = feature('numCores');
    cores = min(cores, 12);

    if verLessThan('matlab',  '8.4') && matlabpool('SIZE') == 0
        matlabpool(cores);
    elseif isempty(gcp('nocreate'))
        parpool(cores);
    end

    test_ok = false(1, numel(test_folders_full));
    time = bigtic();

    parfor i = 1:numel(test_folders_full)
        test_stage_reset(i, hor, hpc, par, nomex, forcemex, talkative);
        test_ok(i) = runtests(test_folders_full{i}, argi{:});
    end

    bigtoc(time,  '===COMPLETED UNIT TESTS IN PARALLEL');

else

    test_ok = false(1, numel(test_folders_full));
    time = bigtic();
    if combine_all
        test_stage_reset(1, hor, hpc, par, nomex, forcemex, talkative);
        test_ok = runtests(test_folders_full{:}, argi{:});
    else
        for i = 1:numel(test_folders_full)
            test_stage_reset(i, hor, hpc, par, nomex, forcemex, talkative);
            test_ok(i) = runtests(test_folders_full{i}, argi{:});
        end
    end
    bigtoc(time,  '===COMPLETED UNIT TESTS RUN ');

end

close all
clear config_store;

err = ~all(test_ok);

if exit_on_completion
    exit(err);
end

end
