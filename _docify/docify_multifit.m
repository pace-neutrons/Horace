function docify_multifit (classname)
% Create multifit documentation for sqw fit and multifit methods
%
%   >> docify_multifit          % All multifit and fit functions
%   >> docify_multifit ('sqw')  % multifit method(s) for named class


if nargin==0
    do_all=true;
else
    do_all=false;
end

% Initialise
horace_path = fileparts(which('horace_init'));
mkgpath('sqw_doc',fullfile(horace_path,'_docify','multifit'));   % define a global path

herbert_path = fileparts(which('herbert_init'));
mkgpath('multifit_doc',fullfile(herbert_path,'_docify','multifit'));   % define a global path

% Run
if do_all || strcmpi(classname,'sqw')
    rootpath = fileparts(which('sqw/sqw'));
    docify(fullfile(rootpath,'multifit.m'))
    docify(fullfile(rootpath,'multifit_func.m'))
    docify(fullfile(rootpath,'multifit_sqw.m'))
    docify(fullfile(rootpath,'multifit_sqw_sqw.m'))
    docify(fullfile(rootpath,'fit.m'))
    docify(fullfile(rootpath,'fit_func.m'))
    docify(fullfile(rootpath,'fit_sqw.m'))
    docify(fullfile(rootpath,'fit_sqw_sqw.m'))
    % Tobyfit:
    rootpath = fileparts(which('sqw/tobyfit'));
    docify(fullfile(rootpath,'tobyfit.m'))
end

if do_all || strcmpi(classname,'d1d')
    rootpath = fileparts(which('d1d/d1d'));
    docify(fullfile(rootpath,'multifit.m'))
    docify(fullfile(rootpath,'multifit_func.m'))
    docify(fullfile(rootpath,'multifit_sqw.m'))
    docify(fullfile(rootpath,'multifit_sqw_sqw.m'))
    docify(fullfile(rootpath,'fit.m'))
    docify(fullfile(rootpath,'fit_func.m'))
    docify(fullfile(rootpath,'fit_sqw.m'))
    docify(fullfile(rootpath,'fit_sqw_sqw.m'))
end

if do_all || strcmpi(classname,'d2d')
    rootpath = fileparts(which('d2d/d2d'));
    docify(fullfile(rootpath,'multifit.m'))
    docify(fullfile(rootpath,'multifit_func.m'))
    docify(fullfile(rootpath,'multifit_sqw.m'))
    docify(fullfile(rootpath,'multifit_sqw_sqw.m'))
    docify(fullfile(rootpath,'fit.m'))
    docify(fullfile(rootpath,'fit_func.m'))
    docify(fullfile(rootpath,'fit_sqw.m'))
    docify(fullfile(rootpath,'fit_sqw_sqw.m'))
end

if do_all || strcmpi(classname,'d3d')
    rootpath = fileparts(which('d3d/d3d'));
    docify(fullfile(rootpath,'multifit.m'))
    docify(fullfile(rootpath,'multifit_func.m'))
    docify(fullfile(rootpath,'multifit_sqw.m'))
    docify(fullfile(rootpath,'multifit_sqw_sqw.m'))
    docify(fullfile(rootpath,'fit.m'))
    docify(fullfile(rootpath,'fit_func.m'))
    docify(fullfile(rootpath,'fit_sqw.m'))
    docify(fullfile(rootpath,'fit_sqw_sqw.m'))
end

if do_all || strcmpi(classname,'d4d')
    rootpath = fileparts(which('d4d/d4d'));
    docify(fullfile(rootpath,'multifit.m'))
    docify(fullfile(rootpath,'multifit_func.m'))
    docify(fullfile(rootpath,'multifit_sqw.m'))
    docify(fullfile(rootpath,'multifit_sqw_sqw.m'))
    docify(fullfile(rootpath,'fit.m'))
    docify(fullfile(rootpath,'fit_func.m'))
    docify(fullfile(rootpath,'fit_sqw.m'))
    docify(fullfile(rootpath,'fit_sqw_sqw.m'))
end
