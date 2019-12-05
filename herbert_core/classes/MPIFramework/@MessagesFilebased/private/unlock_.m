function wlock_obj=unlock_(filename)
% Routine used to remove lock file in background
%
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)
%
wlock_obj = [];
n_attempts_allowed = 100;
tried = 0;
if isempty(filename) % file is already closed
    return;
end
%s = warning('error', 'MATLAB:DELETE:Permission');


ws=warning('error','MATLAB:DELETE:Permission');
permission_denied = false;
while exist(filename,'file')==2 || permission_denied
    try
        delete(filename);
        permission_denied=false;
    catch ME
        %     [~,warn_id] = lastwarn;
        warn_id = ME.identifier;
        if strcmpi(warn_id,'MATLAB:DELETE:Permission')
            permission_denied=true;
            %lastwarn('');
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
            warning(ws);
            rethrow(ME);
            %permission_denied=false;
        end
    end
end
warning(ws);

function lock_bg_deleter(filename,ws)

while exist(filename,'file')==2
    pause(1);
    try
        delete(filename);
    catch ME
    end
end
warning(ws);

