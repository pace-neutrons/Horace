function del_memmapfile_files(filelist)
% Delete files which are unlocked but were accessed using memmapfile
% 
% Is this Matlab bug?
% Input:
% filelist -- name of file or cellarray of filenames to delete
%
%
if istext(filelist)
    filelist = cellstr(filelist);
end
ws = warning('off','MATLAB:DELETE:Permission');
for i=1:numel(filelist)
    fn = filelist{i};
    delete(fn);
    if isfile(fn) % deleteon for files accessed trough matlab
        % memmapfile
        if ispc()
            system(sprintf('del /F %s',fn));
        else
            system(sprintf('rm %s',fn));
        end
    end
end
warning(ws);
