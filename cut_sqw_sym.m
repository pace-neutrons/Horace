function varargout = cut_sqw_sym(varargin)
% Take a cut from a file or files containing sqw data, with symmetrisation
%
%   >> w=cut_sqw_sym (file, arg1, arg2, ...)
%
% For full details of arguments for cut method, type:
%
%   >> help sqw/cut_sym         % cut for sqw objects


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


[varargout,mess] = horace_function_call_method (nargout, @cut_sym, '$sqw', varargin{:});
if ~isempty(mess), error(mess), end
