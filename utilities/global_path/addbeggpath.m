function addbeggpath(name,varargin)
% Add one or more directories to the beginning of a global path.
%
%   >> addbeggpath(pathname,dir1,dir2,...)
%
% e.g. 
%   >> addbeggpath('my_data_area','c:\rawfiles','d:\scratch\rawfiles')
%
% See also: mkgpath, delgpath, addgpath, rmgpath, addendgpath, addbeggpath, showgpath, existgpath

% Check global path name
if ~isvarname(name)
    error('Check global path is a character string')
end

if ~existgpath(name)
    error(['Global path named ''',name,''' does not exist'])
end
    
% Check directory names are character strings, not empty etc
if ~isempty(varargin)
    if isempty(varargin)
        return  % If didn't ask for anything to be added, so just return
    end
    [ok,dirs_add]=str_make_cellstr(varargin{:});
    if ~ok
        error('Check that directory name(s) &/or global path name(s) are character strings or cellarrays of character strings')
    end
    n=numel(dirs_add);
    dirs_add=str_trim_cellstr(dirs_add);         % trim white space
    if isempty(dirs_add) || numel(dirs_add)~=n
        error('One or more additional directory name(s) &/or global path name(s) are empty.')
    end
    [dummy,ind]=unique(dirs_add,'first');
    if numel(ind)~=numel(dirs_add)
        display('Additional directory names or global path names are duplicated. Taking first occurence(s)')
    end
    dirs_add=dirs_add(sort(ind));       % unique directories in order of first appearance
else
    error('Must give one or more directory names')
end

% Add directories to path:
dirs=[dirs_add;getgpath(name)];
[dummy,ind]=unique(dirs,'first');
if numel(ind)~=numel(dirs)
    display('Duplicate directory names or global path names to be added to path. Taking first occurence(s)')
end
dirs=dirs(sort(ind));       % unique directories in order of first appearance

% Add global path to Matlab
ixf_global_path('set',name,dirs);
