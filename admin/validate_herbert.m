function err=validate_herbert(varargin)
% Run unit tests on Herbert installation
%
%   >> validate_herbert                 % Run full Herbert validation
%
%   >> validate_herbert ('-parallel')   % Enables parallel execution of unit tests
%                                       % if the parallel computer toolbox is available
%   >> validate_herbert ('-talkative')  % prints output of the tests and
%                                       %  horace commands   (log_level is set to default, not quiet)
% Returns:
% err -- 0 if tests are successful and  -1 if some test s fail


% Parse optional arguments
% ------------------------
options = {'-parallel','-talkative'};
% For running from shell script:
err = -1;
if isempty(which('herbert_init'))
    herbert_on();
end

if nargin==0
    talkative=false;
    parallel=false;
else
    [ok,mess,parallel,talkative]=parse_char_options(varargin,options);
    if ~ok
        error('VALIDATE_HERBERT:invalid_argument',mess)
    end
end


%==============================================================================
% Place list of test folders here (relative to the master _test folder)
% -----------------------------------------------------------------------------
test_folders={...
    'test_data_loaders',...
    'test_config',...
    'test_IX_classes',...
    'test_map_mask',...
    'test_mslice_objects',...
    'test_multifit',...
    'test_multifit_legacy',...
    'test_utilities',...
    'test_docify'...
    'test_admin',...
    'test_mpi',...
    };

%=============================================================================
initial_warn_state = warning('off','MATLAB:class:DestructorError');
% Generate full test paths to unit tests:
rootpath = fileparts(which('herbert_init'));
test_path=fullfile(rootpath,'_test');   % path to folder with all unit tests folders:
test_folders_full = cellfun(@(x)fullfile(test_path,x),test_folders,'UniformOutput',false);

clear config_store;

% On exit always revert to initial Herbert configuration
% ------------------------------------------------------
% (Validation must always return Herbert to its initial state, regardless
%  of any changes made in the test routines. For example, as of 23/10/13
%  the call to @loader_ascii\load_data will set use_mex_C=false if a
%  problem is encountered, and will save the configuration. This is
%  appropriate action when deployed, but we do not want this to be done
%  during validation)

% Set Herbert configuration to the default (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)

hc =herbert_config();
current_conf=hc.get_data_to_store();
cleanup_obj=onCleanup(@()herbert_test_cleanup(current_conf,test_folders_full,initial_warn_state));
hc.saveable = false; % equivalent to older '-buffer' option for all setters below
hc.init_tests = 1;    % initialise unit tests


% Run unit tests
% --------------


if ~talkative
    hc.log_level = -1;% turn off herbert informational output
end

if parallel && license('checkout','Distrib_Computing_Toolbox')
    cores = feature('numCores');
    if matlabpool('SIZE')==0
        if cores>12
            cores = 12;
        end
        matlabpool(cores);
    end
    
    test_ok = false(1,numel(test_folders_full));
    time=bigtic();
    parfor i=1:numel(test_folders_full)
        addpath(test_folders_full{i})
        test_ok(i) = runtests(test_folders_full{i})
        rmpath(test_folders_full{i})
    end
    bigtoc(time,'===COMPLETED UNIT TESTS IN PARALLEL');
    tests_ok = all(test_ok);
else
    time=bigtic();
    tests_ok=runtests(test_folders_full{:});
    bigtoc(time,'===COMPLETED UNIT TESTS RUN ');
    
end

if tests_ok
    err = 0;
end

%=================================================================================================================
function herbert_test_cleanup(cur_config,test_folders,initial_warn_state)
% Reset the configuration
set(herbert_config,cur_config);
% clear up the test folders, previously placed on the path
warning('off','all'); % avoid varnings on deleting non-existent path
for i=1:numel(test_folders)
    rmpath(test_folders{i});
end
warning(initial_warn_state);
