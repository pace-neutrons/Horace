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
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)


[varargout,mess] = horace_function_call_method (nargout, @cut, '$sqw', varargin{:});
if ~isempty(mess), error(mess), end

