function varargout = cut_horace(varargin)
% Take a cut from a file or files containing sqw, or d0d,d1d...or d4d data
%
%   >> w=cut_horace (file, arg1, arg2, ...)
%
% If the data in the file(s) is sqw-type i.e. has pixel information, the
% data will be passed to the corresponding sqw cut method. If the data is
% dnd type i.e. there is no pixel information, then the method for the 
% appropriate d0d, d1d,...d4d object is called
%
% For full details of arguments for the cut method, see the help for the
% corresponding data type:
%
%   >> help sqw/cut             % cut for sqw object
%   >> help d1d/cut             % cut for d1d object
%   >> help d2d/cut             % cut for d2d object
%          :
%
%
% See also: cut_sqw, cut_dnd


% Original author: T.G.Perring
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)


[varargout,mess] = horace_function_call_method (nargout, @cut, '$hor', varargin{:});
if ~isempty(mess), error(mess), end

