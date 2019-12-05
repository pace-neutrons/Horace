function horace_root = horace_git_root()
% function returns the location of the git repository, containing
% horace code. 
% 
% It assumes that the git repository is one level up over horace_init
% function. 
%
horace_root = fileparts(fileparts(which('horace_init')));
end

