function docify_multifit
% Create multiit documentation in the applications multifit and fit

% Initialise
rootpath = fileparts(which('multifit'));
mkgpath('multifit_doc',fullfile(rootpath,'_docify'));   % define a global path

% Run
docify(fullfile(rootpath,'multifit.m'))
docify(fullfile(rootpath,'fit.m'))
