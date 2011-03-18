function mkgpath(name,varargin)
% Create a global path.
%
%   >> mkgpath(pathname, dir1, dir2, ...)
%
%   pathname        Name to be given to global path
%   dir1, dir2,...  Full directory names that will form the search path
%                   Can be cellstr or character arrays of full paths
%                   Can also be names of global path objects (whether yet defined or not)
%
% e.g. 
%   >> mkgpath('my_data_area','c:\rawfiles','d:\scratch\rawfiles')
%
%   >> mkgpath('more_data','d:\data','my_data_area')    % uses prior definition of my_data_area
%
%
% See also: mkgpath, delgpath, addgpath, rmgpath, addendgpath, addbeggpath, showgpath, existgpath

% Check global path name
if ~isvarname(name)
    error('Check global path is a character string')
end
    
% Check directory names are character strings, not empty etc.
if ~isempty(varargin)
    [ok,dirs]=str_make_cellstr(varargin{:});
    if ~ok
        error('Check that directory name(s) &/or global path name(s) are character strings or cellarrays of character strings')
    end
    n=numel(dirs);
    dirs=str_trim_cellstr(dirs);         % trim white space
    if isempty(dirs) || numel(dirs)~=n
        error('One or more directory name(s) &/or global path name(s) are empty.')
    end
    [dummy,ind]=unique(dirs,'first');
    if numel(ind)~=numel(dirs)
        display('Duplicate directory names or global path names to be added to path. Taking first occurence(s)')
    end
    dirs=dirs(sort(ind));       % unique directories in order of first appearance
else
    error('Must give one or more directory names')
end

% Add global path to Matlab
ixf_global_path('set',name,dirs);
