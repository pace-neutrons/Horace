function del_memmapfile_files(filelist)
% delete files which are unlocked but were accessed using memmapfile
% 
if istext(filelist)
    filelist = cellstr(filelist);
end
clWar = set_temporary_warning('off','MATLAB:DELETE:Permission');
for i=1:numel(filelist)
    fn = filelist{i};
    delete(fn);
    if isfile(fn) % deleteon for files accessed trough matlab
        % memmapfile
        if isunix()
            system(sprintf('rm %s',fn));
        else
            system(sprintf('del %s',fn));
        end
    end
end
end
