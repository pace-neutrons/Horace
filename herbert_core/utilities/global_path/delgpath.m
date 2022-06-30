function delgpath(pathname)
% Delete a global path, if it exists.
%
%   >> delgpath(pathname)
%
% See also: mkgpath, delgpath, addgpath, rmgpath, addendgpath, addbeggpath, showgpath, existgpath

% Check global path name
if ~isvarname(pathname)
    error('Check global path is a character string that is permitted as a variable name')
end

if ~existgpath(pathname)
    disp(['Global path ''',pathname,''' does not exist. No delete performed'])
    return  % doesn't exist anyway
end

% Delete the file
ixf_global_path('del',pathname);

end

