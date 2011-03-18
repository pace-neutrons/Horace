function addgpath(name,varargin)
% Add one or more directories to the beginning of a global path.
%
%   >> addgpath(pathname,dir1,dir2,...)
%
% e.g. 
%   >> addgpath('my_data_area','c:\rawfiles','d:\scratch\rawfiles')
%
% Synonymous with addbeggpath
%
% See also: mkgpath, delgpath, addgpath, rmgpath, addendgpath, addbeggpath, showgpath, existgpath

addbeggpath(name,varargin{:});
