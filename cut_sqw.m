function varargout = cut_sqw(varargin)
% Take a cut from a file(s) containing sqw object
%
%   >> w=cut_sqw (file, arg1, arg2, ...)    % sqw data in named file, or cell array of filenames
%                                           % Output is an array if given cell array of files
%
% For full details of arguments for cut method, type:
%
%   >> help sqw/cut             % cut for sqw objects

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

[varargout,mess] = horace_function_call_method (nargout, @cut, '$sqw', varargin{:});
if ~isempty(mess), error(mess), end
