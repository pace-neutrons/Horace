function file_delete(filename)
% delete file, protected by Matlab due to memmapfile read/write operations
% or filesystem not processing proper permission release.
%
if ~is_file(filename)
    return;
end
ws = warning('off','');
wsClob = onCleanup(@()warning(ws));
delete(filename);

if ~is_file(filename)
    return;
else
    fhs = fopen("all");
    [fp,fn,fe] = fileparts(filename);
    for i=1:numel(fhs)
        fn_present = fopen(fhs(i));
        [fpp,fnp,fep] = fileparts(fn_present);
        if strcmp(fep,fe) && strcmp(fnp,fn) && strcmp(fpp,fp)
            fclose(fhs(i));
            delete(filename);
            if ~is_file(filename)
                return;
            else
                break;
            end
        end
    end
end
[~,wid] = lastwarn;
if ~strcmp(wid,'MATLAB:DELETE:Permission')
    return;
end

% disable warning about impossibility of file deletion, which may come
% in various forms

if ispc
    comm = sprintf('del %s',filename);
else
    comm = sprintf('rm %s',filename);
end
system(comm);
lastwarn('file have not been deleted','HORACE:test_file_deletion');

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
