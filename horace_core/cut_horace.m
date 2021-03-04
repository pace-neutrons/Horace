function wout = cut_horace(varargin)
% Take a cut from a file or files containing sqw, or d0d,d1d...or d4d data
%
%   >> wout=cut_horace (file, arg1, arg2, ...)
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
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)

wout = cut(varargin{:});
