function varargout = cut_dnd(varargin)
% Take a cut from a file or files containing d0d,d1d...or d4d data
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
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


[varargout,mess] = horace_function_call_method (nargout, @cut, '$dnd', varargin{:});
if ~isempty(mess), error(mess), end
