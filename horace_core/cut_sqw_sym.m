function varargout = cut_sqw_sym(varargin)
% Take a cut from a file or files containing sqw data, with symmetrisation
%
%   >> w=cut_sqw_sym (file, arg1, arg2, ...)
%   >> [w,wsym]=cut_sqw_sym (file, arg1, arg2, ...)
%
% For full details of arguments for cut method, type:
%
%   >> help sqw/cut_sym         % cut for sqw objects


% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)


[varargout,mess] = horace_function_call_method (nargout, @cut_sym, '$sqw', varargin{:});
if ~isempty(mess), error(mess), end

