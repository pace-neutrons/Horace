function del_memmapfile_files(varargin)
% Delete files which are unlocked but were accessed using memmapfile
%
% Deals with Maltab bug which exists on Windows, at least with  Matlab 2022b
% and prohibits files previously accessed using memmapfile from beeing deleted
% by Matlab delete() operation despite beeing already unlocked. In the
% same situation files under Linux get deleted without problem and Matlab's
% delete command works.
%
% Input:
% filelist -- name of file or cellarray of filenames to delete
%
%
if nargin > 1
    filelist = varargin;
else
    filelist  = varargin{1};
    if istext(filelist)
        filelist = cellstr(filelist);
    end
end
ws = warning('off','MATLAB:DELETE:Permission');
for i=1:numel(filelist)
    fn = filelist{i};
    if ~isfile(fn)
        continue;
    end
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
