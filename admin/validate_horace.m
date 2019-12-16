function validate_horace(varargin)
% Run unit tests on Horace installation
%
%   >> validate_horace                 % Run full Horace validation
%   >> validate_horace (foldname)       %  Run Horace validation on the single named folder
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

% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)

%==============================================================================
% Place list of test folders here (relative to the master _test folder)
% -----------------------------------------------------------------------------
test_folders={...
    'test_ascii_column_data',...
    'test_change_crystal',...
    'test_combine',...
    'test_dnd',...
    'test_gen_sqw_for_powders',...
    'test_herbert_utilites',...
    'test_mslice_utilities',...
    'test_multifit',...
    'test_rebin',...
    'test_sqw',...
    'test_sqw_file',...
    'test_symmetrisation',...
    'test_tobyfit',...
    'test_transformation'...
    'test_utilities',...
    'test_sym_op'...
    %     %'test_spinw_integration',...
    };
%==============================================================================

% Parse arguments
% ---------------
% Determine if first argument is not one of the options
if nargin>0 && ((ischar(varargin{1}) && ~strcmp(varargin{1}(1),'-')) || iscellstr(varargin{1}))
    test_folders=varargin{1};
    if ischar(test_folders), test_folders={test_folders}; end
    nopt_beg=2;
else
    nopt_beg=1;
end

% Find optional arguments
options = {'-parallel','-talkative','-nomex','-forcemex'};

[ok,mess,parallel,talkative,nomex,forcemex]=parse_char_options(varargin,options);
if ~ok
    error('VALIDATE_HORACE:invalid_argument',mess)
end

%profile on

% Check mex files if mex functions are available
% ----------------------------------------------

[mess,n_errors]=check_horace_mex();
if n_errors==0
    test_folders{end+1}='test_mex_nomex';
else
    nomex = true;
    warning('VALIDATE_HORACE:mex','mex files are not all working, and will not be tested');
    if forcemex
        error('VALIDATE_HORACE:mex','cannot force mex if mex files are not working');
    end
end


% Generate full test paths to unit tests
% --------------------------------------
horace_path = horace_root();
test_path=fullfile(horace_path,'_test');
test_folders_full = cellfun(@(x)fullfile(test_path,x),test_folders,'UniformOutput',false);


hec = herbert_config();
hoc = hor_config();
hpc = hpc_config();
% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;
% (Validation must always return Horace and Herbert to their initial states, regardless
%  of any changes made in the test routines)


% On exit always revert to initial Horace and Herbert configurations
% ------------------------------------------------------------------
cur_herbert_conf=hec.get_data_to_store();
cur_horace_config=hoc.get_data_to_store();   % only get the public i.e. not sealed, fields
cur_hpc_config = hpc.get_data_to_store();
hec.saveable = false;
hoc.saveable = false;
hpc.saveable = false;

% Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj=onCleanup(@()...
    validate_horace_cleanup(cur_herbert_conf,cur_horace_config,cur_hpc_config,{}));


% Run unit tests
% --------------
% Set Horace and Herbert configurations to the defaults (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)

set(hec,'defaults');
set(hoc,'defaults');

% Special unit tests settings.
hec.init_tests=true;       % initialise unit tests
hoc.use_mex = ~nomex;
hoc.force_mex_if_use_mex=forcemex;
if ~talkative
    set(hec,'log_level',-1);    % turn off informational output
end


if parallel && license('checkout','Distrib_Computing_Toolbox')
    cores = feature('numCores');
    if verLessThan('matlab','8.4')
        if matlabpool('SIZE')==0
            if cores>12
                cores = 12;
            end
            matlabpool(cores);
        end
    else
        if isempty(gcp('nocreate'))
            if cores>12
                cores = 12;
            end
            parpool(cores);
            
        end
    end
    time=bigtic();
    parfor i=1:numel(test_folders_full)
        runtests(test_folders_full{i})
    end
    bigtoc(time,'===COMPLETED UNIT TESTS IN PARALLEL');
else
    time=bigtic();
    runtests(test_folders_full{:});
    bigtoc(time,'===COMPLETED UNIT TESTS RUN ');
    
end
close all
clear config_store;
%profile off
%profile viewer


%=================================================================================================================
function validate_horace_cleanup(cur_herbert_config,cur_horace_config,cur_hpc_config,test_folders)
% Reset the configurations, and remove unit test folders from the path
set(herbert_config,cur_herbert_config);
set(hor_config,cur_horace_config);
set(hpc_config,cur_hpc_config);

% Clear up the test folders, previously placed on the path
warn = warning('off','all'); % avoid warning on deleting non-existent path
for i=1:numel(test_folders)
    rmpath(test_folders{i});
end
warning(warn);

