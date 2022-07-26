function horace_off
% Remove paths to all Horace root directory and all sub-directories.
%
% To remove Horace from the Matlab path, type
%   >> horace_off

% T.G.Perring

% root directory is assumed to be that in which this function resides

pths = horace_paths;
on_path = pths.get_folder('horace_on');

warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
try
    old_paths = genpath(pths.horace);
    % make sure we are not removing the path to horace_on
    if ~isempty(on_path)
        old_paths = strrep(old_paths,[on_path,pathsep],'');
    end
    rmpath(old_paths);
    warning(warn_state);    % return warnings to initial state
    pths.clear();
catch
    warning(warn_state);    % return warnings to initial state if error encountered
    error('Problems removing "%s" and sub-directories from Matlab path',horace_path)
end
% Make sure we're not removing any global paths
addpath(getenv('MATLABPATH'));

end
