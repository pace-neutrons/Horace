function horace_off
% Remove paths to all Horace root directory and all sub-directories.
%
% To remove Horace from the Matlab path, type
%   >> horace_off

% T.G.Perring

% root directory is assumed to be that in which this function resides
rootpath = fileparts(fileparts(which('horace_init')));
on_path  = fileparts(which('horace_on')); % 
warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
clear mex;
try
    paths = genpath(rootpath);
    % make sure we are not removing the path to horace_on
    if ~isempty(on_path) % if horace_on is on the path, ensure you keep it
        paths = strrep(paths,[on_path,pathsep],'');
    end    
    rmpath(paths);
    warning(warn_state);    % return warnings to initial state
catch ME
    warning(warn_state);    % return warnings to initial state if error encountered
    error('Problems removing "%s" and sub-directories from Matlab path. Reason: %s', ...
        rootpath,ME.message)
end
% Make sure we're not removing any global paths
addpath(getenv('MATLABPATH'));

