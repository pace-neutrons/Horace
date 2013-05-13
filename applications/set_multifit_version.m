function set_multifit_version(ver)
% Set multifti version
%
%   >> set_multifit_version('legacy')  % reference version
%
%   >> set_multifit_version('current')  % new version
%   >> set_multifit_version(2)  % new version

mfpath=fileparts(which('multifit'));
if ~isempty(mfpath)
        warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
        rmpath(genpath(mfpath));
        warning(warn_state);    % return warnings to initial state
end

rootpath = fileparts(which('herbert_init'));
if ~exist('ver','var') || strcmpi(ver,'current')
    addpath(fullfile(rootpath,'applications','multifit'))
elseif strcmpi(ver,'legacy')
    addpath(fullfile(rootpath,'applications','multifit_legacy'))
else
    error('Error setting up multifit')
end
