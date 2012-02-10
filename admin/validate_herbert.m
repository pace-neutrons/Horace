function  validate_herbert()
% function intended to run unit tests after successfull herbert
% installation to be sure that everything has been installed fine. 

rootpath = fileparts(which('herbert_init'));
if ~get(herbert_config,'init_tests')
    test_pack_path= fullfile(rootpath,'_test/matlab_xunit/xunit');
    addpath(test_pack_path);
else
    test_pack_path='';
end
% path to unit tests:
test_path=fullfile(rootpath,'_test');

runtests(fullfile(test_path,'test_data_loaders'));
%runtests(fullfile(test_path,'test_IX_classes'));

if ~isempty(test_pack_path)
    rmpath(test_pack_path);
end

