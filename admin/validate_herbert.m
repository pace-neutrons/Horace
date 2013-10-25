function validate_herbert(opt)
% Run unit tests on Herbert installation
%
%   >> validate_herbert             % Run full Herbert validation
%   >> validate_herbert ('-full')   % Same as above
%
%   >> validate_herbert ('-enable') % initialise Herbert validation functions
%                                   % for use by e.g. Horace
%
%   >> validate_herbert ('-revert') % reset Herbert to non-validation mode
%                                   % (the unit tests functions may still be
%                                   % on the path depending on the herbert_config
%                                   % field 'init_tests'


% On exit always revert to initial Herbert configuration
% ------------------------------------------------------
% (Validation must always return Herbert to its initial state, regardless
%  of any changes made in the test routines. For example, as of 23/10/13
%  the call to @loader_ascii\load_data will set use_mex_C=false if a 
%  problem is encountered, and will save the configuration. This is 
%  appropriate action when deployed, but we do not want this to be done
%  during validation)

cur_config=get(herbert_config);
cleanup_obj=onCleanup(@()validate_herbert_cleanup(cur_config));


% Parse requested operation
% -------------------------
full=false; enable=false; revert=false;
if nargin==0
    full=true;
else
    if ischar(opt) && size(opt,1)==1 && size(opt,2)>=2
        if strcmpi(opt,'-full')
            full=true;
        elseif strcmpi(opt,'-enable')
            enable=true;
        elseif strcmpi(opt,'-revert')
            revert=true;
        else
            error('Option must be ''-full'', ''-enable'' or ''-revert''')
        end
    else
        error('Option must be ''-full'', ''-enable'' or ''-revert''')
    end
end

% Set paths
rootpath = fileparts(which('herbert_init'));
xunit_path= fullfile(rootpath,'_test/matlab_xunit/xunit');  % path for unit tests
test_path=fullfile(rootpath,'_test');   % path to folder with all unit tests folders:

xunit_initialised=get(herbert_config,'init_tests');


% Initialise if required
% ----------------------
if full || enable
    % Put unit test application folder on the path, if not there already
    if ~xunit_initialised
        addpath(xunit_path);
    end
    % Set Herbert configuration to the default (but don't save)
    % (The validation should be done starting with the defaults, otherwise an error
    %  may be due to a poor choice by the user of configuration parameters)
    set(herbert_config,'defaults','-buffer');
end


% Run unit tests if required
% --------------------------
if full
    %==============================================================================
    % Place call to tests here
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
    for i=1:numel(test_folders)
        test_folders{i}=fullfile(test_path,test_folders{i});
    end
    runtests(test_folders{:});
end


% Remove unit test application if was not present already
% -------------------------------------------------------
if full || revert
    % Remove unit tests from the path if not required
    if ~xunit_initialised
        warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent path)
        rmpath(xunit_path);
        warning(warn_state);    % return warnings to initial state
    end
end

%=================================================================================================================
function validate_herbert_cleanup(cur_config)
% Reset the configuration
set(herbert_config,cur_config);
