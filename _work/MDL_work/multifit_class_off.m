function multifit_class_off
% Removes paths for OOP multifit, replacing them with original (functional) multifit

if ispc
    delim = ';';
    sep = '\';
else
    delim = ':';
    sep = '/';
end
herbert_root = fileparts(which('herbert_init'));
multifit_path = [herbert_root sep 'applications' sep 'multifit'];
multifit_class_path = [fileparts(which(mfilename)) sep 'multifit'];

rmpath(multifit_class_path);
addpath(multifit_path);
disp('!=================== Using Multifit Function ======================!')
