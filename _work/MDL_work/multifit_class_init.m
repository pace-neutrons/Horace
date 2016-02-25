function multifit_class_init
% Removes paths for (functional) multifit, replacing them with OOP multifit

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

rmpath(multifit_path);
addpath(multifit_class_path);
disp('!=================== Using Multifit Class =========================!')
