function wlock_obj=unlock_(fh,filename)
% Routine used to remove lock file in background
%
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
%
wlock_obj = [];
n_attempts_allowed = 100;
tried = 0;
% close opened file defined through filehandle
if ~exist('filename','var')
    filename = fopen(fh);
end
if isempty(filename) % file is already closed
    return
end
try
    err=fclose(fh);
catch
    err = -1000;
end
ws=warning('off','MATLAB:DELETE:Permission');
permission_denied = false;
while exist(filename,'file')==2 || permission_denied
    if err ~=0
        try
            err= fclose(fh);
        catch
            err = -1000;
            permission_denied=true;            
            pause(0.1)
            continue;
        end
    end
    delete(filename);
    [~,warn_id] = lastwarn;
    if strcmpi(warn_id,'MATLAB:DELETE:Permission')
        permission_denied=true;
        lastwarn('');
        pause(0.1);
        tried = tried+1;
        if tried > n_attempts_allowed
            warning('UNLOCK:runtime_error',...
                ' Can not remove lock %s. It looks like threads got dead-locked. Progressing after Leaving lock removal job in background',...
                filename);
            wlock_obj  = @()lock_bg_deleter(filename,ws);
            return;
        end
    else
        permission_denied=false;
    end
    
end
warning(ws);

function lock_bg_deleter(filename,ws)

while exist(filename,'file')==2
    pause(0.1);
    delete(filename);
end
warning(ws);
