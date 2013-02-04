function varargout = cut_dnd(varargin)
% Take a cut from a file(s) containing sqw or d0d/d1d/...d4d object, as appropriate to file contents.
%
%   >> w=cut_dnd (file, arg1, arg2, ...)    % dnd data in named file, or cell array of filenames
%                                           % Output is an array if given cell array of files
%
% For full details of arguments for cut method, type:
%
%   >> help d1d/cut             % cut for d1d object
%   >> help d2d/cut             % cut for d2d object
%          :
%
% If data is sqw-type i.e. has pixel information, this is ignored and is treated as equivalent
% d0d, d1d,...d4d object.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

[varargout,mess] = horace_function_call_method (nargout, @cut, '$dnd', varargin{:});
if ~isempty(mess), error(mess), end
