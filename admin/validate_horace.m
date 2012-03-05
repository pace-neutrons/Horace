function  validate_horace()
% function intended to run unit tests after successfull horace
% installation to be sure that everything has been installed fine. 

herbert_enabled=true;
her_path = fileparts(which('herbert_init'));
if isempty(her_path)
    herbert_enabled= false;
end

% if we can found herbert which is needed as source of unit tests utilites
try
	her_path = herbert_on('where');
	herbert_found  =true;
catch
    herbert_found =false;
end

test_pack_path='';
if herbert_found
    if herbert_enabled
        if ~get(herbert_config,'init_tests')
            test_pack_path= fullfile(her_path,'_test/matlab_xunit/xunit');
            addpath(test_pack_path);
        end
    else
    	test_pack_path= fullfile(her_path,'_test/matlab_xunit/xunit');
        addpath(test_pack_path);
        
    end
else
    error('VALIDATE_HORACE:wrong_call','can not identify the unit test utilites folder');
end
% path to unit tests:
hor_path = fileparts(which('horace_init'));
test_path=fullfile(hor_path,'test');

warning off all;
% test package specific folders
if herbert_enabled
	runtests(fullfile(test_path,'test_herbert_utilites'));
else
	runtests(fullfile(test_path,'test_data_loaders'));
end
% test generic horace part
%runtests(fullfile(test_path,'test_horace'));

warning on all;

if ~isempty(test_pack_path)
    rmpath(test_pack_path);
end

