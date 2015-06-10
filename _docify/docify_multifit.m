function docify_multifit
% Create multifit documentation for sqw fit and multifit methods

% Initialise
horace_path = fileparts(which('horace_init'));
mkgpath('sqw_doc',fullfile(horace_path,'_docify'));   % define a global path

multifit_path = fileparts(which('multifit'));
mkgpath('multifit_doc',fullfile(multifit_path,'_docify'));   % define a global path

% Run
rootpath = fileparts(which('sqw/sqw'));
docify(fullfile(rootpath,'multifit.m'))
docify(fullfile(rootpath,'multifit_func.m'))
docify(fullfile(rootpath,'multifit_sqw.m'))
docify(fullfile(rootpath,'multifit_sqw_sqw.m'))
docify(fullfile(rootpath,'fit.m'))
docify(fullfile(rootpath,'fit_func.m'))
docify(fullfile(rootpath,'fit_sqw.m'))
docify(fullfile(rootpath,'fit_sqw_sqw.m'))
