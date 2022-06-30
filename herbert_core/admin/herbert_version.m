function varargout = herbert_version()
% Returns the version of this instance of Herbert
%
% If one or fewer output arguments are specified, the full version string is
% returned. If more than one output argument is specified, then an array of
% strings is returned containing the first n version numbers, where n is the
% number of output arguments required. If more output arguments are requested
% than there are version numbers, an error is raised.
%
% Usage:
%   >> version_string = herbert_version();
%   >> [major, minor] = herbert_version();
%   >> [major, minor, patch] = herbert_version();
%
try
    VERSION = herbert_get_build_version();
catch ME
    if ~strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
        rethrow(ME);
    end
    VERSION = read_from_version_file();
end

% If only one output requested return whole version string
if nargout <= 1
    varargout{1} = VERSION;
    return;
end

version_numbers = split(VERSION, '.');
if nargout > numel(version_numbers)
    error('Too many output arguments requested.') ;
end

% Return as many version numbers as requested
for i = 1:numel(version_numbers)
    varargout(i) = version_numbers(i);
end


function version_str = read_from_version_file()
    try
        herbert_root = fileparts(fileparts(which('herbert_init')));
        version_file = fullfile(herbert_root , 'VERSION');
        version_str = [strtrim(fileread(version_file)), '.dev'];
    catch
        version_str = '0.0.0.dev';
    end
