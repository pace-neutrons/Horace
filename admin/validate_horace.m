function  validate_horace()
% Run unit tests on Horace installation
%
%   >> validate_horace
%
% This function will run the Horace unit tests with either Herbert or Libisis as the
% underlying core utilities library.
%
% If an error is encountered during the test procedure, then the unit
% test application folder will remain on the path, the Horace informational
% output level, and the Matlab warning state will still be off. The state
% of Herbert or Libisis, and Horace, will not be the same in
% consequence. However, if tests are com,pleted succesfully, then the
% unit test application will be removed and the warnings set to 'on'.


% Look for Herbert which is needed as source of unit tests utilities
try
    using_herbert=is_herbert_used;
    if using_herbert
        rootpath = fileparts(which('herbert_init'));
        if ~get(herbert_config,'init_tests')
            xunit_path= fullfile(rootpath,'_test/matlab_xunit/xunit');
            addpath(xunit_path);
        else
            xunit_path='';
        end
    else
        rootpath = fileparts(which('libisis_init'));
        if ~get(libisis_config,'init_tests')
            xunit_path= fullfile(rootpath,'matlab_xunit/xunit');
            addpath(xunit_path);
        else
            xunit_path='';
        end
    end
catch
    error('VALIDATE_HORACE:wrong_call','Cannot identify the unit test utilites folder')
end

% Get path to unit tests:
horace_path = fileparts(which('horace_init'));
test_path=fullfile(horace_path,'test');

% Run unit tests
warning off all;
info_level = get(hor_config,'horace_info_level');   % store current Horace informational output level
set(hor_config,'horace_info_level',0);              % turn off Horace informational output
 
%==============================================================================
% Place call to tests here
% -----------------------------------------------------------------------------
if ~using_herbert   % test data loaders only if libisis
	runtests(fullfile(test_path,'test_data_loaders'));
end
%runtests(fullfile(test_path,'test_admin'));
runtests(fullfile(test_path,'test_herbert_utilites'));
runtests(fullfile(test_path,'test_transformation'));
%runtests(fullfile(test_path,'test_ascii_column_data'));
% test generic horace part
%runtests(fullfile(test_path,'test_horace'));

%==============================================================================

warning on all;
set(hor_config,'horace_info_level',info_level);

% Remove unit test application if was not present already
if ~isempty(xunit_path),
    rmpath(xunit_path);
end
