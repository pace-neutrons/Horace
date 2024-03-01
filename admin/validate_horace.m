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
    herbert_only, horace_only,combile_all, test_folders] = ...
    parse_char_options(varargin, options);

if ~ok
    error('HORACE:validate_horace:invalid_argument', mess)
end

%==============================================================================
% Place list of test folders here (relative to the master _test folder)
% -----------------------------------------------------------------------------
if isempty(test_folders)
    % no tests specified on command line - run them all
    herbert_tests = {...
        'test_admin', ...
        'test_xunit_framework', ...
        'test_data_loaders', ...
        'test_config', ...
        'test_IX_classes', ...
        'test_map_mask', ...
        'test_multifit_herbert', ...
        'test_utilities_herbert', ...
        'test_serializers', ...
        'test_instrument_classes', ...
        'test_unique_objects_container', ...
        'test_docify', ...
        'test_geometry',...
        'test_mpi_wrappers', ...
        'test_mpi', ...
        };

    horace_tests = {...
        'test_admin', ...
        'test_xunit_framework', ...
        'test_algorithms',...
        'test_ascii_column_data', ...
        'test_change_crystal', ...
        'test_combine', ...
        'test_dnd_class', ...
        'test_experiment', ...
        'test_gen_sqw_for_powders', ...
        'test_rebin', ...
        'test_mex_nomex', ...
        'test_main_header',...
        'test_sqw', ...
        'test_sqw_class', ...
        'test_sqw_file', ...
        'test_sqw_pageOpMethods',...
        'test_sqw_pixels', ...
        'test_sym_op', ...
        'test_symmetrisation', ...
        'test_transformation', ...
        'test_utilities', ...
        'test_multifit', ...
        'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_mex', ...
        'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_nomex', ...
        'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert', ...
        'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_parpool', ...
        'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_slurm' ...
        'test_TF_components', ...
        'test_TF_let', ...
        'test_TF_refine_crystal' ...
        };

    if herbert_only && ~horace_only
        test_folders = herbert_tests;
    elseif horace_only && ~herbert_only
        test_folders = horace_tests;
    else
        test_folders = unique([herbert_tests, horace_tests], 'stable');
    end

end

system_tests = { ...
    'test_mpi', ...
    'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_mex', ...
    'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_nomex', ...
    'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert', ...
    'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_parpool', ...
    'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_slurm' ...
    'test_TF_components', ...
    'test_TF_let', ...
    'test_TF_refine_crystal' ...
    };

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
    if combile_all
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


%-------------------------------------------------------------------------------
function test_stage_reset(icount, hor, hpc, par, nomex, forcemex, talkative)
% Run before each stage
% Set Horace configurations to the defaults (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)

% Set the default configurations, printing warning only the first time round to
% avoid copious warning messages
warn_state = warning();
cleanup_obj = onCleanup(@()warning(warn_state));
if icount>1
    warning('off',  'all');
end

set(hor, 'defaults');
set(hpc, 'defaults');
% set(par, 'defaults');

% Return warning state to incoming state
warning(warn_state)

% Special unit tests settings.
hor.init_tests = true; % initialise unit tests
hor.use_mex = ~nomex;
hor.force_mex_if_use_mex = forcemex;

if talkative
    hor.log_level = 1; % force log level high.
else
    hor.log_level = -1; % turn off informational output
end

end


%-------------------------------------------------------------------------------
function validate_horace_cleanup(cur_horace_config, cur_hpc_config, ...
    cur_par_config, test_folders, initial_warn_state)
% Reset the configurations, and remove unit test folders from the path

set(hor_config, cur_horace_config);
set(hpc_config, cur_hpc_config);
set(parallel_config, cur_par_config);

warning('off',  'all'); % avoid warning on deleting non-existent path

% Clear up the test folders, previously placed on the path
for i = 1:numel(test_folders)
    rmpath(test_folders{i});
end

warning(initial_warn_state);

end
