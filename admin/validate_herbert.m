function validate_herbert()
% Run unit tests on Herbert installation
%
%   >> validate_herbert
%
% If an error is encountered during the test procedure, then the unit
% test application folder will remain on the path, and the warning state
% will still be off. The state of Herbert will not be the same in
% consequence. However, if tests are com,pleted succesfully, then the
% unit test application will be removed and the warnings set to 'on'.

rootpath = fileparts(which('herbert_init'));

% Put unit test application folder on the path, if not already
if ~get(herbert_config,'init_tests')
    xunit_path= fullfile(rootpath,'_test/matlab_xunit/xunit');
    addpath(xunit_path);
else
    xunit_path='';
end

% Get path to unit tests:
test_path=fullfile(rootpath,'_test');

% Run unit tests
warning off all;

%==============================================================================
% Place call to tests here
% -----------------------------------------------------------------------------
% *** Does not do any tests as of 16 July 2013, or fails if do not have herbert_on:
%runtests(fullfile(test_path,'test_admin'));

banner_to_screen('test_data_loaders')
runtests(fullfile(test_path,'test_data_loaders'));

banner_to_screen('test_IX_classes')
runtests(fullfile(test_path,'test_IX_classes'));

banner_to_screen('test_mslice_objects')
runtests(fullfile(test_path,'test_mslice_objects'));

banner_to_screen('test_multifit')
runtests(fullfile(test_path,'test_multifit'));

banner_to_screen('test_utilities')
runtests(fullfile(test_path,'test_utilities'));

%==============================================================================

warning on all;

% Remove unit test application if was not present already
if ~isempty(xunit_path),
    rmpath(xunit_path);
end
