function varargout = cut_sqw_old(varargin)
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


[varargout,mess] = horace_function_call_method (nargout, @cut_old, '$sqw', varargin{:});
if ~isempty(mess), error(mess), end

