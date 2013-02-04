function varargout = cut_horace(varargin)
% Take a cut from a file(s) containing sqw or d0d/d1d/...d4d object, as appropriate to file contents
%
%   >> w=cut_horace (file, arg1, arg2, ...) % data in named file, or cell array of filenames
%                                           % Output is an array if given cell array of files
%
% For full details of arguments for cut method, type:
%
%   >> help sqw/cut             % cut for sqw objects
%   >> help d1d/cut             % cut for d1d object
%   >> help d2d/cut             % cut for d2d object
%          :

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

[varargout,mess] = horace_function_call_method (nargout, @cut, '$hor', varargin{:});
if ~isempty(mess), error(mess), end
