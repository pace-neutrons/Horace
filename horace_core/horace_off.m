function horace_off
% Remove paths to all Horace root directory and all sub-directories.
%
% To remove Horace from the Matlab path, type
%   >> horace_off

% T.G.Perring

% root directory is assumed to be that in which this function resides

pths = horace_paths;
horace_on_path = pths.get_folder('horace_on');
herbert_on_path = pths.get_folder('herbert_on');
pths.clear();

warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
try
    old_paths = genpath(pths.horace);
    % make sure we are not removing the path to horace_on
    if ~isempty(horace_on_path)
        old_paths = strrep(old_paths,[horace_on_path,pathsep],'');
    end
    rmpath(old_paths);
catch
    error('Problems removing "%s" and sub-directories from Matlab path',horace_on_path)
end

try
    old_paths = genpath(pths.herbert);
    if ~isempty(herbert_on_path)
        old_paths = strrep(old_paths,[herbert_on_path,pathsep],'');
    end
    rmpath(old_paths);
catch
    error('Problems removing "%s" and sub-directories from Matlab path',herbert_on_path)
end

warning(warn_state);    % return warnings to initial state if error encountered

% Make sure we're not removing any global paths
addpath(getenv('MATLABPATH'));

end
