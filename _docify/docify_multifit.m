function docify_multifit (classname)
% Create multifit documentation in the applications multifit and fit and
% Herbert classes with multifit methods
%
%   >> docify_multifit                      % All multifit and fit functions
%   >> docify_multifit ('application')      % Main multifit and fit applications
%   >> docify_multifit ('IX_dataset_1d')    % multifit method(s) for named class


if nargin==0
    do_all=true;
else
    do_all=false;
end

% Initialise
herbert_path = fileparts(which('herbert_init'));
mkgpath('multifit_doc',fullfile(herbert_path,'_docify','multifit'));   % define a global path

multifit_path = fileparts(which('multifit'));
multifit_path_private=fullfile(multifit_path,'private');

% Run
if do_all || strcmpi(classname,'application')
    docify(fullfile(multifit_path_private,'multifit_main.m'))
    docify(fullfile(multifit_path,'multifit_gateway_main.m'))
    docify(fullfile(multifit_path,'multifit.m'))
    docify(fullfile(multifit_path,'fit.m'))
end

if do_all || strcmpi(classname,'IX_dataset_1d')
    multifit_path = fileparts(which('IX_dataset_1d/multifit'));
    docify(fullfile(multifit_path,'multifit.m'))
    docify(fullfile(multifit_path,'fit.m'))
end

if do_all || strcmpi(classname,'IX_dataset_2d')
    multifit_path = fileparts(which('IX_dataset_2d/multifit'));
    docify(fullfile(multifit_path,'multifit.m'))
    docify(fullfile(multifit_path,'fit.m'))
end

if do_all || strcmpi(classname,'IX_dataset_3d')
    multifit_path = fileparts(which('IX_dataset_3d/multifit'));
    docify(fullfile(multifit_path,'multifit.m'))
    docify(fullfile(multifit_path,'fit.m'))
end
