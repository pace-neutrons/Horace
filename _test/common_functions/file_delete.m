function file_delete(filename)
% delete file, protected by Matlab due to memmapfile read/write operations
%
if ~is_file(filename)
    return;
end
ws = warning('off','');
wsClob = onCleanup(@()warning(ws));
if ispc
    comm = sprintf('del %s',filename);
else
    comm = sprintf('rm %s',filename);
end
for i=1:100
    delete(filename);
    [~,wid] = lastwarn;
    if ~strcmp(wid,'MATLAB:DELETE:Permission')
        break;
    end
    system(comm);
    lastwarn('file have not been deleted','HORACE:test_file_deletion');
    pause(0.1);
end
