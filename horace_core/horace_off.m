function horace_off
% Remove paths to all Horace root directory and all sub-directories.
%
% To remove Horace from the Matlab path, type
%   >> horace_off

% T.G.Perring

% root directory is assumed to be that in which this function resides
global horace_path
on_path = fileparts(which('horace_on'));

warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
try
    paths = genpath(horace_path);
    % make sure we are not removing the path to horace_on
    if ~isempty(on_path)
        paths = strrep(paths,[on_path,pathsep],'');
    end
    rmpath(paths);
    warning(warn_state);    % return warnings to initial state
    clear global horace_path
    clear global herbert_path
    clear global root_path
catch
    warning(warn_state);    % return warnings to initial state if error encountered
    error('Problems removing "%s" and sub-directories from Matlab path',horace_path)
end
% Make sure we're not removing any global paths
addpath(getenv('MATLABPATH'));

end
