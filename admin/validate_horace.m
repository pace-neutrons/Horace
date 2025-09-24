function err = validate_horace(varargin)
% Runs some or all of the unit tests on a Horace installation.
%
% It is recommended to use validate_horace rather than the xunit function runtests
% as this will ensure that the horace configurations, warning state and working
% directory are returned to their initial states regardless of any changes that
% the tests may have made or if errors are thrown. This is not necessarily the
% case if the tests are run directly using runtests.
%
% Remember to ensure that the Horace configuration parameter 'init_tests' has
% been set to true before calling validate_horace:
%
%   >> set(hor_config, 'init_tests', 1)
%
%
% Usage:
% ======
% Run the full Horace validation suite of tests, from any location:
%
%   >> validate_horace
%
%
% Run named tests from any location:
% Folder names are always relative to the master Horace test folder, <root_dir>/_test)
% 
%   >> validate_horace ('dirname')                      %  Run all tests in the named folder
%   >> validate_horace ('dirname/mfilename')            %  Run all tests in the named test suite
%                                                       % in the named folder
%   >> validate_horace ('dirname/mfilename:testname')   %  Run one particular test in the named
%                                                       % test suite in the named folder
%   >> validate_horace (arg1, arg2, ...)                %  Run a sequence of tests, with any of
%                                                       % the syntaxes above
%   >> validate_horace ({arg1, arg2,})                  %  Run a sequence of tests, with any of
%                                                       % the syntaxes above in a cell array
%
%
% Run tests that are in the present working directory:
%   >> validate_horace ('mfilename')                    %  Run all tests in the named test suite
%   >> validate_horace ('mfilename:testname')           %  Run one particular test in the named
%
%   [Note that if mfilename is the same as the name as a test folder in the
%   master Horace test folder, <root_dir>/_test), then the ambiguity is resolved
%   in favour of performing all the tests in the test folder. For example, there
%   is a folder c:\myprogs\horace\_test\test_rebin in the Horace test suite. If
%   your pwd contains an m-file called test_rebin.m, then 
%       >> validate_horace ('test_rebin')
%   will run all the test suites in the folder c:\myprogs\horace\_test\test_rebin
%   rather than the test suite in test_rebin.m in the pwd.]
%   
%
% Esamples:
% =========
%   >> validate_horace ('test_IX_classes')
%
%   >> validate_horace ('test_IX_classes/test_IX_axis')
%
%   >> validate_horace ('test_IX_classes/test_IX_axis')
%
%   >> validate_horace ('test_IX_classes/test_IX_axis:test_constructor')
%
%   >> validate_horace ('test_sym_op/test_cut_sqw_sym', ...
%                           'test_admin/test_paths:test_roots_same')
%
%   >> validate_horace ({'test_docify', 'test_IX_classes/test_plot_singleton'})
%
%
% In addition, any one or more of the following options can be used to control the
% tests:
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
%                                                  % and run them in common workspace rather then
%                                                  % each test folder separately
%
% Exits with a non-zero error code if any tests failed

if isempty(which('horace_init'))
    horace_on();
end

            
% Parse arguments
% ---------------
% Get value of options and which tests to perform if different from the default.
options = {'-parallel',  '-talkative',  '-nomex',  '-forcemex',...
    '-disp_skipped','-exit_on_completion','-no_system_tests',...
    '-herbert_only', '-horace_only','-combine_all'};
[ok, mess, parallel, talkative, nomex, forcemex, ...
    disp_skipped, exit_on_completion, no_system, ...
    herbert_only, horace_only, combine_all, test_folders] = ...
    parse_char_options(varargin, options);

if ~ok
    error('HORACE:validate_horace:invalid_argument', mess)
end

if isempty(test_folders)
    % No tests were specified on command line - so run them all.
    % Read the tests from CMakeLists.txt
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


% Prepare for performing tests
% ----------------------------
% Generate full test paths to unit tests
pths = horace_paths;
test_path = pths.test;
test_folders_full = cellfun(@(x)(validate_horace_convert_arg(test_path, x)), ...
    test_folders, 'UniformOutput', false);
% test_folders_full = fullfile(test_path, test_folders);

% Get instances of the current configurations of Horace and Herbert.
hor = hor_config();
hpc = hpc_config();
par = parallel_config();

% Extract the public (i.e. not sealed) fields
cur_horace_config = hor.get_data_to_store();
cur_hpc_config = hpc.get_data_to_store();
cur_par_config = par.get_data_to_store();

% Turn off a class destructor error warning and remove configurations from
% memory. Ensures only stored configurations are retained.
initial_warn_state = warning();     % hold the current warning state
warning('off', 'MATLAB:class:DestructorError');
clear config_store;

% Validation must always return Horace and Herbert to their initial states,
% regardless of any changes made in the test routines.
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
