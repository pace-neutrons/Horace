function varargout = herbert_version()
% Returns the version of this instance of Herbert
%
% If 1 or fewer output arguments are specified, the full version string is
% returned. If more than 1 output argument is specified, then an array of
% strings is returned containing the first n version numbers, where n is the
% number of output arguments required. If more output arguments are requested
% than there are version numbers, an error is raised.
%
% Usage:
%   >> version_string = herbert_version();
%   >> [major, minor] = herbert_version();
%   >> [major, minor, patch] = herbert_version();
%
VERSION = get_raw_version();

% If only one output requested return whole version string
if nargout <= 1
    varargout{1} = VERSION;
    return;
end

version_numbers = split(VERSION, '.');
if nargout > numel(version_numbers)
    error("Too many output arguments requested.") ;
end

% Return as many version numbers as requested
for i = 1:numel(version_numbers)
    varargout(i) = version_numbers(i);
end
