function unlock_(fh,filename)
% Routine used to remove lock file in background
%
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
%

n_attempts_allowed = 100;
tried = 0;
if ~exist('filename','var')
    filename = fopen(fh);
end
if isempty(filename)
    return
end
fclose(fh);
ws=warning('off','MATLAB:DELETE:Permission');
permission_denied = false;
while exist(filename,'file')==2 || permission_denied
    delete(filename);
    [~,warn_id] = lastwarn;
    if strcmpi(warn_id,'MATLAB:DELETE:Permission')
        permission_denied=true;
        lastwarn('');
        pause(0.1);
        tried = tried+1;
        if tried > n_attempts_allowed
            warning('UNLOCK:runtime_error',...
                ' Can not remove lock %s. It looks like threads got dead-locked. Breaking lock forcibly',...
                filename);
            clob = onCleanup(@()lock_bg_deleter(filename,ws));
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
