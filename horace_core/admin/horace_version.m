function varargout = horace_version()
% Returns the version of this instance of Herbert
%
% If one or fewer output arguments are specified, the full version string is
% returned. If more than one output argument is specified, then an array of
% strings is returned containing the first n version numbers, where n is the
% number of output arguments required. If more output arguments are requested
% than there are version numbers, an error is raised.
%
% Usage:
%   >> version_string = horace_version();
%   >> [major, minor] = horace_version();
%   >> [major, minor, patch] = horace_version();
%

if nargout <=1
    varargout{1} = herbert_version();
end
if nargout ==2
    [varargout{1},varargout{2}] = herbert_version();
end
if nargout ==3
    [varargout{1},varargout{2},varargout{3}] = herbert_version();
end