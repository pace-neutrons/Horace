function file_delete(filename)
% delete file, protected by Matlab due to memmapfile read/write operations
% or filesystem not processing proper permission release.
%
if ~is_file(filename)
    return;
end
% disable warning about impossibility of file deletion, which may come 
% in various forms 
ws = warning('off','');
wsClob = onCleanup(@()warning(ws));
if ispc
    comm = sprintf('del %s',filename);
else
    comm = sprintf('rm %s',filename);
end
for i=1:100
    % try multiple times in case if FS is not released permission fast
    % enough. 
    % 10 sec is sufficient time to propagate the permissions in any OS. 
    % Written from experience with filebased messages locking/unlocking. 
    %
    delete(filename);
    [~,wid] = lastwarn;
    if ~strcmp(wid,'MATLAB:DELETE:Permission')
        break;
    end
    system(comm);
    lastwarn('file have not been deleted','HORACE:test_file_deletion');
    pause(0.1);
    if ~is_file(filename)
        break;
    end
end
