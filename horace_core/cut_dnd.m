function varargout = cut_dnd(varargin)
% Take a cut from a dnd object or file containing d0d,d1d...or d4d data
%
%   >> w=cut_dnd (file, arg1, arg2, ...)
%
% If the data in the file(s) is sqw-type i.e. has pixel information, the
% pixel information is ignored and the data is treated as the equivalent
% d0d, d1d,...d4d object.
%
% For full details of arguments for the cut method, see the help for the
% corresponding data type:
%
%   >> help d1d/cut             % cut for d1d object
%   >> help d2d/cut             % cut for d2d object
%          :
%
%
% See also: cut_sqw, cut_horace


% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)


[varargout,mess] = horace_function_call_method (nargout, @cut, '$dnd', varargin{:});
if ~isempty(mess), error(mess), end

