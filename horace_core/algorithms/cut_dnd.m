function varargout = cut_dnd(file,varargin)
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

if ~iscell(file)
end