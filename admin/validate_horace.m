function err = validate_horace(varargin)
% Run unit tests on Horace installation
%
%   >> validate_horace                 % Run full Horace validation
%   >> validate_horace (foldname)       %  Run Horace validation on the single named folder
%   >> validate_horace (foldname1, foldname2)  %  Run Horace validation on named folders
%   >> validate_horace (foldname_cell)  %  Run Horace validation on the folders named
%                                       % in a cell array of names
%
% In addition, one of more options are allowed fromt he following
%
%   >> validate_horace (...'-parallel') %  Enables parallel execution of unit tests
%                                      % if the parallel computer toolbox is available
%   >> validate_horace (...'-talkative')%  Prints output of the tests and
%                                       % horace commands (log_level is set to default,
%                                       % not quiet)
%   >> validate_horace (...'-nomex')    %  Validate matlab code by forcefully
%                                      % disabling mex even if mex files
%                                       % are available
%   >> validate_horace (...'-forcemex') %  Enforce use of mex files only. The
%                                       % default otherwise for Horace to revert to
%                                       % using matlab code.
%   >> validate_horace (...'-nodisp_skipped') %  print only list of failed
%                                       %        tests, ignoring skipped
%   >> validate_horace (...'-exit_on_completion') % Exit Matlab when test suite ends.
% Exits with non-zero error code if any tests failed

err = -1;

if isempty(which('horace_init'))
    horace_on();
end

% Parse arguments
% ---------------
options = {'-parallel',  '-talkative',  '-nomex',  '-forcemex',...
    '-exit_on_completion','-no_system_tests','-nodisp_skipped'};
[ok, mess, parallel, talkative, nomex, forcemex, ...
    exit_on_completion,no_system,nodisp_skipped,test_folders] = ...
    parse_char_options(varargin, options);

if ~ok
    error('VALIDATE_HORACE:invalid_argument', mess)
end

%==============================================================================
% Place list of test folders here (relative to the master _test folder)
% -----------------------------------------------------------------------------
if isempty(test_folders)% no tests specified on command line - run them all
    test_folders = {...
        'test_admin',...
        'test_main_header',...
        'test_ascii_column_data', ...
        'test_change_crystal', ...
        'test_combine', ...
        'test_configuration',...
        'test_converters',...
        'test_dnd', ...
        'test_dnd_class', ...
        'test_experiment', ...
        'test_gen_sqw_for_powders', ...
        'test_herbert_utilites', ...
        'test_mex_nomex', ...
        'test_multifit', ...
        'test_rebin', ...
        'test_sym_op', ...
        'test_symmetrisation', ...
        'test_transformation', ...
        'test_utilities', ...
        'test_sqw', ...
        'test_sqw_file', ...
        'test_sqw_class', ...
        'test_sqw_pixels', ...
        'test_tobyfit', ...
        'test_gen_sqw_workflow' ...
        % 'test_spinw_integration', ...
        };
end
system_tests = {'test_tobyfit','test_gen_sqw_workflow'};
if no_system
    no_sys = ~ismember(test_folders,system_tests);
    test_folders = test_folders(no_sys );
end

% Generate full test paths to unit tests
% --------------------------------------
horace_path = horace_root();
test_path = fullfile(horace_path,  '_test');
test_folders_full = cellfun(@(x)fullfile(test_path, x), test_folders, ...
    'UniformOutput', false);

hec = herbert_config();
hoc = hor_config();
hpc = hpc_config();
% (Validation must always return Horace and Herbert to their initial states, regardless
%  of any changes made in the test routines)

% On exit always revert to initial Horace and Herbert configurations
% ------------------------------------------------------------------
cur_herbert_conf = hec.get_data_to_store();
cur_horace_config = hoc.get_data_to_store(); % only get the public i.e. not sealed, fields
cur_hpc_config = hpc.get_data_to_store();
% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;


% Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@() ...
    validate_horace_cleanup(cur_herbert_conf, cur_horace_config, cur_hpc_config, {}));

% Run unit tests
% --------------
% Set Horace and Herbert configurations to the defaults (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)

set(hec,  'defaults');
set(hoc,  'defaults');

% Special unit tests settings.
hec.init_tests = true; % initialise unit tests
hoc.use_mex = ~nomex;
hoc.force_mex_if_use_mex = forcemex;

if talkative
    hec.log_level = 1; % force log level high.
else
    hec.log_level = -1; % turn off informational output
end
if nodisp_skipped
    argi = {'-verbose','-nodisp_skipped'};
else
    argi = {'-verbose'};
end

if parallel && license('checkout',  'Distrib_Computing_Toolbox')
    cores = feature('numCores');
    if verLessThan('matlab',  '8.4')
        if matlabpool('SIZE') == 0

            if cores > 12
                cores = 12;
            end

            matlabpool(cores);
        end
    else
        if isempty(gcp('nocreate'))
            if cores > 12
                cores = 12;
            end
            parpool(cores);
        end
    end

    test_ok = false(1, numel(test_folders_full));

    time = bigtic();

    parfor i = 1:numel(test_folders_full)
        test_ok(i) = runtests(test_folders_full{i}, argi{:})
    end

    bigtoc(time,  '===COMPLETED UNIT TESTS IN PARALLEL');
    tests_ok = all(test_ok);
else
    time = bigtic();
    tests_ok = runtests(test_folders_full{:},  argi{:});
    bigtoc(time,  '===COMPLETED UNIT TESTS RUN ');

end

close all
clear config_store;

if tests_ok
    err = 0;
end

if exit_on_completion
    exit(err);
end

%=================================================================================================================
function validate_horace_cleanup(cur_herbert_config, cur_horace_config, cur_hpc_config, test_folders)
warn = warning('off',  'all'); % avoid warning on deleting non-existent path
% Reset the configurations, and remove unit test folders from the path
set(herbert_config, cur_herbert_config);
set(hor_config, cur_horace_config);
set(hpc_config, cur_hpc_config);

% Clear up the test folders, previously placed on the path
for i = 1:numel(test_folders)
    rmpath(test_folders{i});
end

warning(warn);
