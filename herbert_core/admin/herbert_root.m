function [rootpath,dps] = herbert_root()
% function returns the location of the git repository, containing
% herbert code. 
% 
% It assumes that the horace root is one level up over the location of the 
% herbert_init function. 
%    
% In addition to that, it returns common for all tests place where Herbert 
% test data can be found
%
rootpath=fileparts(fileparts(which('herbert_init.m')));
dps  = fullfile(rootpath,'_test','common_data');



