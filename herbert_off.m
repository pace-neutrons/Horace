function herbert_off
% Remove paths to herbert root directory and all sub-directories.
%
% To remove herbert from the matlab path, type
%   >> herbert_off

% T.G.Perring

% Call cleanup routine(s) before clearing any paths (e.g. persistent variables)
%   - not any at the moment -

% root directory is assumed to be that in which this function resides
rootpath = fileparts(which('herbert_off'));

warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
try
    paths = genpath(rootpath);
    rmpath(paths);
    warning(warn_state);    % return warnings to initial state
catch
    warning(warn_state);    % return warnings to initial state if error encountered
    error('Problems removing "%s" and sub-directories from matlab path',rootpath)
end
