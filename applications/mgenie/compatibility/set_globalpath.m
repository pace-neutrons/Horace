function set_globalpath(varargin)
% Create a global path. For compatibility with older mgenie routines
%
%   >> set_globalpath (pathname, dir1, dir2, ...)
%
%   pathname        Name to be given to global path
%   dir1, dir2,...  Full directory names that will form the search path
%                   Can be cellstr or character arrays of full paths
%                   Can also be names of global path objects (whether yet defined or not)
%
% e.g. 
%   >> set_globalpath('my_data_area','c:\rawfiles','d:\scratch\rawfiles')
%
%   >> set_globalpath('more_data','d:\data','my_data_area')    % uses prior definition of my_data_area
%
%
% For compatibility with older mgenie routines only. Identical in function to mkgpath

mkgpath(varargin{:})
