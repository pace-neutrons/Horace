function horace_off
% Remove paths to all Horace root directory and all sub-directories.
%
% To remove Horace from the Matlab path, type
%   >> horace_off

% T.G.Perring

% root directory is assumed to be that in which this function resides
rootpath = fileparts(fileparts(which('horace_init')));

warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
try
    paths = genpath(rootpath);
    rmpath(paths);
    warning(warn_state);    % return warnings to initial state
catch
    warning(warn_state);    % return warnings to initial state if error encountered
    error('Problems removing "%s" and sub-directories from Matlab path',rootpath)
end
