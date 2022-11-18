function varargout = herbert_version(varargin)
% Returns the version of this instance of Horace
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
%   >> [major, minor, patch] = herbert_version('-numeric');
%
% if option '-numeric' is provided, the routine returns the results in the
% numeric form, i.e. string major.minor.patch will have the form
% 100*major+minor.patch. This option is selected for convenience of the
% version comparison and assumes that minor version will never be higher
% than 99

options = {'-numeric'};
[ok,mess,return_numeric] = parse_char_options(varargin,options );
if ~ok
    error('HORACE:herbert_version:invalid_argument',mess);
end

try
    VERSION = herbert_get_build_version();
catch ME
    if ~strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
        rethrow(ME);
    end
    VERSION = read_from_version_file();
end

% If only one output requested, return whole version string
if nargout <= 1 && ~return_numeric
    varargout{1} = VERSION;
    return;
end

version_numbers = split(VERSION, '.');
if nargout > numel(version_numbers)
    error("Too many output arguments requested.") ;
end

% Return as many version numbers as requested
for i = 1:nargout
    varargout(i) = version_numbers(i);
end
%
if return_numeric
    num_patch_digits = numel(version_numbers{3});
    varargout{1} = 100*str2double(version_numbers{1})+...
        str2double(version_numbers{2})+...
        0.1^num_patch_digits*str2double(version_numbers{3});   
end


function version_str = read_from_version_file()
try
    horace_root = fileparts(fileparts(which('herbert_init')));
    version_file = fullfile(horace_root , 'VERSION');
    version_str = [strtrim(fileread(version_file)), '.dev'];
catch
    version_str = '0.0.0.dev';
end
