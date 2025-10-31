function [err, suite] = validate_horace(varargin)
% Runs some or all of the unit tests on a Horace installation.
%
% Remember to ensure that the Horace configuration parameter 'init_tests' has
% been set to true before calling validate_horace:
%
%   >> set(hor_config, 'init_tests', 1)
%
% Usage:
% ======
%   validate_horace                                 % run all Horace tests
%   validate_horace(arg2, arg2, ...)                % run sequence of specific tests
%   validate_horace(..., option1, option2, ...)     % with one or more options
%   [err, suite] = validate_horace(...)             % with optional output
%
% It is recommended to use validate_horace rather than the xunit function runtests
% as this will ensure that the horace configurations, warning state and working
% directory are returned to their initial states on exit, regardless of any changes
% that the tests may have made or if errors are thrown. This is not necessarily
% the case if the tests are run directly using runtests.
%
%
% Input:
% ------
%   See below for full details and examples.
%
% Output:
% -------
%   err     If all tests passed: err = false;
%           If one or more test failed: err = true;
%
%   suite   Suite of tests as run by runtests.
%           - Is a single test suite if there is only one input test argument,
%             or if the option '-combine_all' is given.
%           - Is a cell array of test suites, one per input test argument.
%
%
% Usage:
% ======
% - Run the full Horace validation suite of tests, from any location:
%
%   >> validate_horace
%
%   Note: The full suite of tests is contained in the file CMakeLists.txt in the
%   root Horace tests folder: <root_path>/_test.
%
%
% - Run named tests from any location:
% Folder names are always relative to the master Horace test folder, <root_dir>/_test)
%
%   >> validate_horace ('dirname')                      %  Run all tests in the named folder.
%   >> validate_horace ('dirname/mfilename')            %  Run all tests in the named test suite
%                                                       % in the named folder.
%   >> validate_horace ('dirname/mfilename:testname')   %  Run one particular test in the named
%                                                       % test suite in the named folder.
%   >> validate_horace (arg1, arg2, ...)                %  Run a sequence of tests, where arg1,
%                                                       % arg2, arg3,... are each any one of
%                                                       % the syntaxes above.
%
% - Run tests that are in the present working directory:
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
% ---------
% Tests with the directory name given:
%
%   >> validate_horace ('test_IX_classes')
%   >> validate_horace ('dirname')                      %  Run all tests in the named folder.
%   >> validate_horace ('dirname/mfilename')            %  Run all tests in the named test suite
%                                                       % in the named folder.
%   >> validate_horace ('dirname/mfilename:testname')   %  Run one particular test in the named
%                                                       % test suite in the named folder.
%   >> validate_horace (arg1, arg2, ...)                %  Run a sequence of tests, where arg1,
%                                                       % arg2, arg3,... are each any one of
%                                                       % the syntaxes above.
%
% Run tests that are in the present working directory:
%   >> validate_horace ('mfilename')                    %  Run all tests in the named test suite
%   >> validate_horace ('mfilename:testname')
%
%   >> validate_horace ('test_IX_classes/test_IX_axis')
%
%   >> validate_horace ('test_IX_classes/test_IX_axis:test_constructor')
%
%   >> validate_horace ('test_sym_op/test_cut_sqw_sym', ...
%                           'test_admin/test_paths:test_roots_same')
%
% Tests in the current working directory:
%   If in the folder <root_dir>/_test/test_IX_classes (where root_dir is the
%   root Horace installation location e.g. could be 'C:\myprogs\Horace' on a Windows PC):
%
%   >> validate_horace('test_IX_axis')
%
%   >> validate_horace('test_IX_axis:test_constructor')
%
%
% Optional arguments:
% ===================
% In addition, any one or more of the following options, in any order, can be used
% to control the tests:
%
% -Filter tests if running the full Horace test suite:
%   >> validate_horace (...'-herbert_only')        %  Run only tests related to herbert_core
%                                                  % in CmakeLists.txt.
%   >> validate_horace (...'-horace_only')         %  Run only tests related to horace_core
%                                                  % in CmakeLists.txt.
%   >> validate_horace (...'-no_system_tests')     %  Do not perform tests indicated as system
%                                                  % tests in CmakeLists.txt.
%   >> validate_horace (...'-system_tests_only')   %  Only perform tests indicated as system
%                                                  % tests in CmakeLists.txt.
%
% -Execution control:
%   >> validate_horace (...'-nomex')               %  Validate matlab code by forcefully disabling
%                                                  % mex even if mex files are available.
%   >> validate_horace (...'-forcemex')            %  Enforce use of mex files only. The default
%                                                  % otherwise for Horace to revert to using
%                                                  % matlab code.
%   >> validate_horace (...'-combine_all')         %  Combine all requested tests together
%                                                  % and run them in a common workspace rather then
%                                                  % each test argument in separate calls to runtests.
%   >> validate_horace (...'-parallel')            %  Enables parallel execution of unit tests
%                                                  % if the distributed computing toolbox is available.
%
% -Output control:
%   >> validate_horace (...'-talkative')           %  Prints verbose output of the validation tests and
%                                                  % the output of Horace algorithms.
%   >> validate_horace (...'-disp_skipped')        %  Prints the listings of both failed and skipped tests.
%                                                  % (The default is not to print skipped test listing.)
%   >> validate_horace (...'-logfile', filename)   %  Write runtests output to a logfile instead of
%                                                  % to the screen.
%
% -Completion control:
%   >> validate_horace (...'-exit_on_completion')  %  Exit Matlab when validate_horace finishes.
%
%
% Examples:
% ---------
%   >> validate_horace ('-horace_only', '-system_tests_only')
%
%   >> validate_horace ('test_IX_classes', '-disp_skipped', '-nomex')
%
%
% Optional arguments for use when testing validate_horace:
% ========================================================
% These are not designed for general use, but only for use by the validation
% tests on validate_horace itself.
%
% Override the default location of the Horace tests:
%   >> validate_horace (...'-root_test_path', dirname)
%
% Override the default file that contains the full Horace suite of tests:
%   [Note: filename should contain the absolute path as well as the file name.]
%
%   >> validate_horace (...'-CMakeLists_file', filename)


if isempty(which('horace_init'))
    horace_on();
end
pths = horace_paths;


% ------------------------------------------------------------------------------
% Parse arguments
% ------------------------------------------------------------------------------
% Get value of options and which tests to perform if different from the default.
% Use parse_arguments with options that ensure that a logical flag name can only
% be true if present.
val_default = struct('herbert_only', 0, 'horace_only', 0, ...
    'no_system_tests', 0, 'system_tests_only', 0, ...
    'nomex', 0, 'forcemex', 0, ...
    'combine_all', 0, 'parallel', 0, ...
    'talkative', 0, 'disp_skipped', 0, 'logfile', '', ...
    'exit_on_completion', 0, ...
    'root_test_path', '', 'CMakeLists_file', '');

flag_names = {'herbert_only', 'horace_only', 'no_system_tests', 'system_tests_only'...
    'nomex', 'forcemex', 'combine_all', 'parallel', ...
    'talkative', 'disp_skipped', 'exit_on_completion'};

opt = struct('prefix', '-', 'prefix_req', true, 'flags_noneg', true, 'flags_noval', true);
[test_args, val, present, ~, ok, mess] = ...
    parse_arguments (varargin, val_default, flag_names, opt);
if ~ok
    error('HORACE:validate_horace:invalid_argument', mess)
end


% ------------------------------------------------------------------------------
% Prepare the cell array of test arguments for runtests
% ------------------------------------------------------------------------------
if isempty(test_args)
    % No tests were specified on command line - so run them all, subject to
    % exclusions indicated by optional arguments.
    
    % Read the tests from CMakeLists.txt
    if ~present.CMakeLists_file
        % Use the 'production' folder for CMakeLists.txt with the full list of
        % tests
        CMakeLists_file = fullfile(pths.test, 'CMakeLists.txt');
    else
        CMakeLists_file = val.CMakeLists_file;
    end
    
    [herbert_tests, herbert_system_tests, horace_tests, horace_system_tests] = ...
        validate_horace_read_CMakeLists (CMakeLists_file);
    
    % Filter on system tests
    if present.no_system_tests && present.system_tests_only
        error('HERBERT:validate_horace:invalid_argument', ...
            'Options ''-no_system_tests'' and ''-system_tests_only'' cannot both be specified.')
        
    elseif present.no_system_tests
        herbert_tests_to_run = herbert_tests;
        horace_tests_to_run = horace_tests;
        
    elseif present.system_tests_only
        herbert_tests_to_run = herbert_system_tests;
        horace_tests_to_run = horace_system_tests;
        
    else
        herbert_tests_to_run = [herbert_tests, herbert_system_tests];
        horace_tests_to_run = [horace_tests, horace_system_tests];
    end
    
    % Filter on herbert or horace tests only
    if present.herbert_only && present.horace_only
        % herbert_only and horace_only cannot both be specified, as this leaves no
        % tests to be run
        error('HERBERT:validate_horace:invalid_argument', ...
            'Options ''-herbert_only'' and ''-horace_only'' cannot both be specified.')
        
    elseif present.herbert_only
        test_args = herbert_tests_to_run;
        
    elseif present.horace_only
        test_args = horace_tests_to_run;
        
    else
        test_args = [herbert_tests_to_run, horace_tests_to_run];
    end
    
else
    % Test cases are explicitly specified; some options are not permissible
    if present.herbert_only
        error('HERBERT:validate_horace:invalid_argument', ...
            'Option ''-herbert_only'' is not permitted if tests are explicitly named.')
    end
    if present.horace_only
        error('HERBERT:validate_horace:invalid_argument', ...
            'Option ''-horace_only'' is not permitted if tests are explicitly named.')
    end
    if present.no_system_tests
        error('HERBERT:validate_horace:invalid_argument', ...
            'Option ''-no_system_tests'' is not permitted if tests are explicitly named.')
    end
    if present.system_tests_only
        error('HERBERT:validate_horace:invalid_argument', ...
            'Option ''-system_tests_only'' is not permitted if tests are explicitly named.')
    end
end

% Remove duplicate tests to avoid repeating tests if there are repeated input
% arguments or CMakeLists.txt was ill-constructed.
test_args = unique(test_args, 'stable');

% Generate full test paths to unit tests
if ~present.root_test_path
    % Use the 'production' root folder for tests
    root_test_path = pths.test;
else
    % Override the 'production' root folder - useful when testing validate_horace
    root_test_path = val.root_test_path;
end

test_args_full = cellfun(@(x)(validate_horace_convert_arg(root_test_path, x)), ...
    test_args, 'UniformOutput', false);

if isempty(test_args_full)  % no tests to be performed
    disp('=== NO UNIT TESTS PROVIDED')
    return
end

n_test_args = numel(test_args_full);


% ------------------------------------------------------------------------------
% Check consistency of optional arguments
% ------------------------------------------------------------------------------
if present.nomex && present.forcemex
    error('HERBERT:validate_horace:invalid_argument', ...
        'Options ''-nomex'' and ''-forcemex'' cannot both be specified.')
end

if present.combine_all && present.parallel
    error('HERBERT:validate_horace:invalid_argument', ...
        'Options ''-combine_all'' and ''-parallel'' cannot both be specified.')
end


% ------------------------------------------------------------------------------
% Prepare optional argument list(s) for calls to runtests
% ------------------------------------------------------------------------------
opt_args = {};

if present.talkative
    opt_args = [opt_args, '-verbose'];
end

if ~present.disp_skipped
    opt_args = [opt_args, '-nodisp_skipped'];
end

log_filename_tmp = {};
if present.logfile
    filename = ['validate_horace_log_', str_random(12)];    % temporary file name
    if ~isempty(val.logfile)
        log_filename = val.logfile;
    else
        log_filename = fullfile(tmp_dir, [filename, '.txt']);
    end
    if n_test_args>1 && ~present.combine_all
        % A different log file will be created for each call to runtests that is
        % made in the loop over the tests. Combine all the log files once the
        % tests have been completed.
        % Construct temporary log_filenames with suffix '___1', '___2' ... added
        % to the log file name, one temporary log file for each call to runtests.
        % Then append the logfile option to opt_args to get the optional
        % argument list unique to each call to run_tests
        log_filename_tmp = arrayfun(...
            @(k)(fullfile(tmp_dir, [filename, '___', num2str(k), '.txt'])), 1:n_test_args, ...
            'UniformOutput', false);
        opt_args = cellfun(@(x)([opt_args, '-logfile', x]), log_filename_tmp, ...
            'UniformOutput', false);
    else
        % Just one call to runtests will be made; write straight to the final
        % output log file.
        opt_args = [opt_args, '-logfile', log_filename];
    end
end

opt_args_is_cell_of_cells = ~isempty(opt_args) && all(cellfun(@iscell, opt_args));


% ------------------------------------------------------------------------------
% Get current Horace and warnings configurations, and create cleanup object
% ------------------------------------------------------------------------------
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
cleanup_obj = onCleanup(@()validate_horace_cleanup( ...
    cur_horace_config, ...
    cur_hpc_config, ...
    cur_par_config, ...
    test_args, ...
    initial_warn_state, ...
    pwd(), ...
    log_filename, ...
    log_filename_tmp));


% ------------------------------------------------------------------------------
% Perform the unit tests
% ------------------------------------------------------------------------------
if n_test_args>1 && present.parallel && license('checkout',  'Distrib_Computing_Toolbox')
    % Only call parallel tool box if there is more than one call to runtests
    cores = feature('numCores');
    cores = min(cores, 12);
    
    if verLessThan('matlab',  '8.4') && matlabpool('SIZE') == 0
        matlabpool(cores);
    elseif isempty(gcp('nocreate'))
        parpool(cores);
    end
    
    test_ok = false(1, n_test_args);
    time = bigtic();
    
    suite = cell(1, n_test_args);
    parfor i = 1:n_test_args
        validate_horace_test_stage_reset(i, hor, hpc, par, present.nomex, present.forcemex, ...
            present.talkative);
        if opt_args_is_cell_of_cells
            [test_ok(i), suite{i}] = runtests(test_args_full{i}, opt_args{i}{:});
        else
            [test_ok(i), suite{i}] = runtests(test_args_full{i}, opt_args{:});
        end
    end
    bigtoc(time,  '=== COMPLETED UNIT TESTS RUN IN PARALLEL');
    
else
    test_ok = false(1, n_test_args);
    time = bigtic();
    if n_test_args==1 || present.combine_all
        % All tests run in a single call to runtests
        validate_horace_test_stage_reset(1, hor, hpc, par, present.nomex, present.forcemex, ...
            present.talkative);
        [test_ok, suite] = runtests(test_args_full{:}, opt_args{:});
        
    else
        % Multiple calls to runtests to run all the tests
        suite = cell(1, n_test_args);
        for i = 1:n_test_args
            fprintf(1,['\n\n',...
                '======================================================================\n',...
                '===\n', '=== Test argument: %s\n', '===\n'], test_args_full{i})
            validate_horace_test_stage_reset(i, hor, hpc, par, present.nomex, present.forcemex, ...
                present.talkative);
            if opt_args_is_cell_of_cells
                [test_ok(i), suite{i}] = runtests(test_args_full{i}, opt_args{i}{:});
            else
                [test_ok(i), suite{i}] = runtests(test_args_full{i}, opt_args{:});
            end
        end
    end
    bigtoc(time,  '=== COMPLETED UNIT TESTS RUN ');
    
end

close all   % close all figures
clear config_store;

err = ~all(test_ok);

if present.exit_on_completion
    exit(err);
end

end
