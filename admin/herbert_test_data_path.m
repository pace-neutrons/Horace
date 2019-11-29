function dps = herbert_test_data_path()
% function returns common place where Herbert test data should be found
%
rootpath=fileparts(fileparts(which('herbert_init.m')));
dps  = fullfile(rootpath,'_test/common_data');



