function err = validate_horace(varargin)
% Run unit tests on Horace installation
%
%   >> validate_horace                             % Run full Horace validation
%   >> validate_horace (foldname)                  %  Run Horace validation on the single named folder
%   >> validate_horace (foldname1, foldname2)      %  Run Horace validation on named folders
%   >> validate_horace (foldname_cell)             %  Run Horace validation on the folders named
%                                                  % in a cell array of names
%
% In addition, one of more options are allowed from the following
%
%   >> validate_horace (...'-parallel')            %  Enables parallel execution of unit tests
%                                                  % if the parallel computer toolbox is available
%   >> validate_horace (...'-talkative')%  Prints output of the tests and
%                                                  % horace commands (log_level is set to default,
%                                                  % not quiet)
%   >> validate_horace (...'-nomex')               %  Validate matlab code by forcefully
%                                                  % disabling mex even if mex files
%                                                  % are available
%   >> validate_horace (...'-forcemex')            %  Enforce use of mex files only. The
%                                                  % default otherwise for Horace to revert to
%                                                  % using matlab code.
%   >> validate_horace (...'-nodisp_skipped')      %  print only list of failed
%                                                  %        tests, ignoring skipped
%   >> validate_horace (...'-exit_on_completion')  % Exit Matlab when test suite ends.
%   >> validate_horace (...'-herbert_only')        % Run only tests related to herbert_core
%   >> validate_horace (...'-horace_only')        % Run only tests related to horace_core
% Exits with non-zero error code if any tests failed

if isempty(which('horace_init'))
    horace_on();
end

% Parse arguments
% ---------------
options = {'-parallel',  '-talkative',  '-nomex',  '-forcemex',...
    '-exit_on_completion','-no_system_tests','-nodisp_skipped','-herbert_only', '-horace_only'};
[ok, mess, parallel, talkative, nomex, forcemex, ...
 exit_on_completion,no_system,nodisp_skipped, ...
 herbert_only,horace_only,test_folders] = ...
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
        'test_converters',...
        'test_dnd_class', ...
        'test_experiment', ...
        'test_gen_sqw_for_powders', ...
        'test_rebin', ...
        'test_mex_nomex', ...
        'test_main_header',...
        'test_sqw', ...
        'test_sqw_class', ...
        'test_sqw_file', ...
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

hoc = hor_config();
hpc = hpc_config();
par = parallel_config();
% (Validation must always return Horace and Herbert to their initial states, regardless
%  of any changes made in the test routines)

% On exit always revert to initial Horace and Herbert configurations
% ------------------------------------------------------------------
initial_warn_state = warning();
warning('off', 'MATLAB:class:DestructorError');

% only get the public i.e. not sealed, fields
cur_horace_config = hoc.get_data_to_store();
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

argi = {'-verbose'};
if nodisp_skipped
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
        test_stage_reset(hoc, hpc, par, nomex, forcemex, talkative);
        test_ok(i) = runtests(test_folders_full{i}, argi{:});
    end

    bigtoc(time,  '===COMPLETED UNIT TESTS IN PARALLEL');

else

    test_ok = false(1, numel(test_folders_full));
    time = bigtic();

    for i = 1:numel(test_folders_full)
        test_stage_reset(hoc, hpc, par, nomex, forcemex, talkative);
        test_ok(i) = runtests(test_folders_full{i}, argi{:});
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

function test_stage_reset(hoc, hpc, par, nomex, forcemex, talkative)
% Run before each stage
% Set Horace configurations to the defaults (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)

    set(hoc, 'defaults');
    set(hpc, 'defaults');
    % set(par, 'defaults');

    % Special unit tests settings.
    hoc.init_tests = true; % initialise unit tests
    hoc.use_mex = ~nomex;
    hoc.force_mex_if_use_mex = forcemex;

    if talkative
        hoc.log_level = 1; % force log level high.
    else
        hoc.log_level = -1; % turn off informational output
    end

end


function validate_horace_cleanup(cur_horace_config, cur_hpc_config, cur_par_config, test_folders, initial_warn_state)
% Reset the configurations, and remove unit test folders from the path

set(hor_config, cur_horace_config);
set(hpc_config, cur_hpc_config);
set(parallel_config, cur_par_config);

warn = warning('off',  'all'); % avoid warning on deleting non-existent path

% Clear up the test folders, previously placed on the path
for i = 1:numel(test_folders)
    rmpath(test_folders{i});
end

warning(initial_warn_state);

end
