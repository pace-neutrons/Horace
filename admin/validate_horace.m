function validate_horace(varargin)
% Run unit tests on Horace installation
%
%   >> validate_horace                  % Run full Horace validation
%
%   >> validate_herbert ('-parallel')   % Enables parallel execution of unit tests
%                                       % if the parallel computer toolbox is available


% Parse optional arguments
% ------------------------
options = {'-final_report','-parallel'};

if nargin==0
    final_report=false;
    parallel=false;
else
    [ok,mess,final_report,parallel]=parse_char_options(varargin,options);
    if ~ok
        error('VALIDATE_HORACE:invalid_argument',mess)
    elseif (final_report+parallel)>1
        error('VALIDATE_HORACE:invalid_argument','Only one of ''-final_report'' and ''-parallel'' is permitted')
    end
end

%==============================================================================
% Place list of test folders here (relative to the master _test folder)
% -----------------------------------------------------------------------------
% Still need to add: 'test_combine', test_rebin', 'test_transformation'
test_folders={...
    'test_ascii_column_data',...
    'test_change_crystal',...
    'test_file_input_methods',...
    'test_gen_sqw_for_powders',...
    'test_herbert_utilites',...
    'test_mslice_utilities',...
    'test_multifit',...
    'test_symmetrisation',...
    'test_sqw'...
    };

[mess,n_errors]=check_horace_mex();
if n_errors==0  % also check mex files against matlab versions, if mex functions are available
    test_folders{end+1}='test_mex_nomex';
else
    warning('VALIDATE_HORACE:mex','mex files are disabled, and will not be tested');
end
%=============================================================================

% Generate full test paths to unit tests:
horace_path = fileparts(which('horace_init'));
test_path=fullfile(horace_path,'_test');
test_folders_full = cellfun(@(x)fullfile(test_path,x),test_folders,'UniformOutput',false);


% On exit always revert to initial Horace and Herbert configurations
% ------------------------------------------------------------------
% (Validation must always return Horace and Herbert to their initial states, regardless
%  of any changes made in the test routines)

cur_herbert_conf=get(herbert_config,'-public');
cur_horace_config=get(hor_config,'-public');   % only get the public i.e. not sealed, fields

% Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj=onCleanup(@()validate_horace_cleanup(cur_herbert_conf,cur_horace_config,{}));


% Run unit tests
% --------------
% Set Horace and Herbert configurations to the defaults (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)
set(herbert_config,'defaults','-buffer');
set(hor_config,'defaults','-buffer');

% Set up other configuration options necessary for tests to run
set(herbert_config,'init_tests',1,'-buffer');       % initialise unit tests
set(herbert_config,'log_level',-1,'-buffer');       % minimise any diagnostic output
set(hor_config,'horace_info_level',-1,'-buffer');   % turn off Horace informational output


if parallel && license('checkout','Distrib_Computing_Toolbox')
    cores = feature('numCores');
    if matlabpool('SIZE')==0
        matlabpool(cores);
    end
    time=bigtic();
    parfor i=1:numel(test_folders_full)
        addpath(test_folders_full{i})
        runtests(test_folders_full{i})
        rmpath(test_folders_full{i})
    end
    bigtoc(time,'===COMPLETED UNIT TESTS IN PARALLEL');
else
    if ~final_report
        time=bigtic();
        for i=1:numel(test_folders_full)
            addpath(test_folders_full{i});
            runtests(test_folders_full{i})
            rmpath(test_folders_full{i})
        end
        bigtoc(time,'===COMPLETED UNIT TESTS RUN ');
    else
        runtests(test_folders_full{:});
    end
end


%=================================================================================================================
function validate_horace_cleanup(cur_herbert_config,cur_horace_config,test_folders)
% Reset the configurations, and remove unit test folders from the path
set(hor_config,cur_horace_config);
set(herbert_config,cur_herbert_config);

% Clear up the test folders, previously placed on the path
warn = warning('off','all'); % avoid varning on deleting non-existent path
for i=1:numel(test_folders)
    rmpath(test_folders{i});
end
warning(warn);
