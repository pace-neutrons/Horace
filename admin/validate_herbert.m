function validate_herbert(varargin)
% Run unit tests on Herbert installation
%
%   >> validate_herbert                 % Run full Herbert validation
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
        error('VALIDATE_HERBERT:invalid_argument',mess)
    elseif (final_report+parallel)>1
        error('VALIDATE_HERBERT:invalid_argument','Only one of ''-final_report'' and ''-parallel'' is permitted')
    end
end


%==============================================================================
% Place list of test folders here (relative to the master _test folder)
% -----------------------------------------------------------------------------
test_folders={...
    'test_admin',...
    'test_data_loaders',...
    'test_IX_classes',...
    'test_map_mask',...
    'test_mslice_objects',...
    'test_multifit',...
    'test_utilities',...
    };
%=============================================================================

% Generate full test paths to unit tests:
rootpath = fileparts(which('herbert_init'));
test_path=fullfile(rootpath,'_test');   % path to folder with all unit tests folders:
test_folders_full = cellfun(@(x)fullfile(test_path,x),test_folders,'UniformOutput',false);


% On exit always revert to initial Herbert configuration
% ------------------------------------------------------
% (Validation must always return Herbert to its initial state, regardless
%  of any changes made in the test routines. For example, as of 23/10/13
%  the call to @loader_ascii\load_data will set use_mex_C=false if a
%  problem is encountered, and will save the configuration. This is
%  appropriate action when deployed, but we do not want this to be done
%  during validation)

cur_config=get(herbert_config,'-public');
cleanup_obj=onCleanup(@()validate_herbert_cleanup(cur_config,test_folders_full));


% Run unit tests
% --------------
% Set Herbert configuration to the default (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)
set(herbert_config,'defaults','-buffer');


% Set up other configuration options necessary for tests to run
set(herbert_config,'init_tests',1,'-buffer');       % initialise unit tests
set(herbert_config,'log_level',-1,'-buffer');       % minimise any diagnostic output


if parallel && license('checkout','Distrib_Computing_Toolbox')
    cores = feature('numCores');
    if matlabpool('SIZE')==0
        if cores>12
            cores = 12;
        end
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
function validate_herbert_cleanup(cur_config,test_folders)
% Reset the configuration
set(herbert_config,cur_config);
% clear up the test folders, previously placed on the path
warn = warning('off','all'); % avoid varnings on deleting non-existent path
for i=1:numel(test_folders)
    rmpath(test_folders{i});
end
warning(warn);
