function varargout = cut_sqw(varargin)
% Take a cut from a file or files containing sqw data
%
%   >> w=cut_sqw (file, arg1, arg2, ...)
%
% For full details of arguments for cut method, type:
%
%   >> help sqw/cut             % cut for sqw objects
%
%
% See also: cut_horace, cut_dnd


% Original author: T.G.Perring
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)


[varargout,mess] = horace_function_call_method (nargout, @cut, '$sqw', varargin{:});
if ~isempty(mess), error(mess), end
