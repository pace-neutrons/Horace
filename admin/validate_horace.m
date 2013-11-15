function  validate_horace(opt)
% Run unit tests on Horace installation
%
%   >> validate_horace


% On exit always revert to initial Horace configuration
% ------------------------------------------------------
% (Validation must always return Horace to its initial state, regardless
%  of any changes made in the test routines)
parallell=false;
if nargin > 0 
    if strncmpi('-parallel',opt,4)
        parallell = true;
    end
end
%==============================================================================
% Place call to tests here
% -----------------------------------------------------------------------------
% Still need to add: 'test_admin'  'test_energy_binning'  'test_transformation'
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
if n_errors==0 % also check mex files against matlab version
    test_folders{end+1}='test_mex_nomex';
else
    warning('VALIDATE_HORACE:mex','mex files are disabled, and will not be tested');
end

% Get path to unit tests:
horace_path = fileparts(which('horace_init'));
test_path=fullfile(horace_path,'_test');
% generate fill test path
test_f = cellfun(@(x)fullfile(test_path,x),test_folders,'UniformOutput',false);
%=============================================================================
% get previous configuration and prepare to restore it on clean-up
cur_config=get(hor_config,'-public');   % only get the public i.e. not sealed, fields
%validate_herbert('-enable')     % note: does not change Herbert configuration
cur_her_conf=get(herbert_config,'-public');
cleanup_obj=onCleanup(@()validate_horace_cleanup(cur_config,{},cur_her_conf));

% Run unit tests
% --------------
% Set Horace configuration to the default (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)
set(hor_config,'defaults','-buffer');
% set up other configuration options necessary for tests to run
set(herbert_config,'init_tests',1,'log_level',-1,'-buffer');
set(hor_config,'horace_info_level',-1,'-buffer');    % turn off Horace informational output


time=bigtic();
if license('checkout','Distrib_Computing_Toolbox') && parallell

    cores = feature('numCores');
    if matlabpool('SIZE')==0
        matlabpool(cores);   
    end
    parfor i=1:numel(test_f)
        addpath(test_f{i})
        runtests(test_f{i})
        rmpath(test_f{i})        
    end
    bigtoc(time,'===COMPLETED UNIT TESTS IN PARALLEL');
else
    for i=1:numel(test_f)
        addpath(test_f{i});    
        runtests(test_f{i})
        rmpath(test_f{i})
    end
    bigtoc(time,'===COMPLETED UNIT TESTS RUN ');    
end


% warning on all;



%validate_herbert('-revert')


%=================================================================================================================
function validate_horace_cleanup(cur_config,test_folders,her_cur_config)
% Reset the configuration
set(hor_config,cur_config);
% revert herbert configuration
set(herbert_config,her_cur_config);
% clear up the test folders, previously placed on the path
warn = warning('off','all'); % avoid varnings on deleting non-existent path
for i=1:numel(test_folders)
    rmpath(test_folders{i});
end
warning(warn);
% Turn off unit test functions if required
% ----------------------------------------

