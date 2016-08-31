function tobyfit2_off
% Remove paths to an application and all sub-directories.

% T.G.Perring

% root directory is assumed to be that in which this function resides
rootpath = fileparts(which(mfilename));

warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
try
    paths = genpath(rootpath);
    rmpath(paths);
    warning(warn_state);    % return warnings to initial state
catch
    warning(warn_state);    % return warnings to initial state if error encountered
    error('Problems removing "%s" and sub-directories from matlab path',rootpath)
end
