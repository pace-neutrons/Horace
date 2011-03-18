function rmgpath(name,varargin)
% Remove one or more directories from a global path.
%
%   >> rmgpath(pathname,dir1,dir2,...)
%
% e.g. 
%   >> rmgpath('my_data_area','c:\rawfiles','d:\scratch\rawfiles')
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
    [ok,dirs_rm]=str_make_cellstr(varargin{:});
    if ~ok
        error('Check that directory name(s) &/or global path name(s) are character strings or cellarrays of character strings')
    end
    n=numel(dirs_rm);
    dirs_rm=str_trim_cellstr(dirs_rm);         % trim white space
    if isempty(dirs_rm) || numel(dirs_rm)~=n
        error('One or more directory name(s) &/or global path name(s) to be removed are empty.')
    end
    [dummy,ind]=unique(dirs_rm,'first');
    if numel(ind)~=numel(dirs_rm)
        display('One or more directory names or global path names to be removed are duplicated')
    end
    dirs_rm=dirs_rm(sort(ind));       % unique directories in order of first appearance
else
    error('Must give one or more directory names')
end

% Remove directories from path
dirs=getgpath(name);
dirs_cmn=array_common(dirs_rm,dirs,'first');
if ~isempty(dirs_cmn)
    if numel(dirs_cmn)~=numel(dirs_rm)
        display(['Not all directories and global paths to be removed exist in global path ''',name,''' - these ones will be ignored.'])
    end
    ind=array_keep(dirs,dirs_cmn);
    dirs=dirs(ind);
    if ~isempty(dirs)
        ixf_global_path('set',name,dirs);
    else
        warning(['All directories and global paths to be removed from global path ''',name,''' - it will be deleted.'])
        ixf_global_path('del',name);
    end
else
    display(['No directories and global paths to be removed exist in global path ''',name,''' - operation had no effect.'])
end
