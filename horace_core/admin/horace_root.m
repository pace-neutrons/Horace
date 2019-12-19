function horace_root = horace_root()
% function returns the location of the git repository, containing
% horace code. 
% 
% It assumes that the horace root is one level up over the location of the 
% horace_init function. 
%
horace_root = fileparts(fileparts(which('horace_init')));


