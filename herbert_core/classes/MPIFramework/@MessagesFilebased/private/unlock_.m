function wlock_obj=unlock_(filename,file_to_rename)
% Routine used to unlock file used as filebased message
%

wlock_obj = [];
n_attempts_allowed = 100;
tried = 0;
if isempty(filename) % file is already closed
    return;
end
attempt_time = 0.1;
increase_increment = 1.05; % ~5min waiting for the failure
if nargin > 1
    [fp,fn,fext] = fileparts(file_to_rename);
    f_new = fullfile(fp,[fn,'.',fext(6:end)]);
    nok = movefile(file_to_rename,f_new);
    while(nok)
        pause(attempt_time);
        [nok,mess,mess_id] = movefile(file_to_rename,f_new);
        tried = tried+1;
        if tried > n_attempts_allowed
            warning('UNLOCK:runtime_error',...
                ' Can not rename file %s to %s.',...
                file_to_rename,f_new);
            error(mess_id,mess);
        end
        attempt_time = attempt_time*increase_increment;
    end
end

tried = 0;
ws=warning('error','MATLAB:DELETE:Permission');
permission_denied = false;
attempt_time = 0.1;
while is_file(filename) || permission_denied
    try
        delete(filename);
        permission_denied=false;
    catch ME
        %     [~,warn_id] = lastwarn;
        warn_id = ME.identifier;
        if strcmpi(warn_id,'MATLAB:DELETE:Permission')
            permission_denied=true;
            %lastwarn('');
            pause(attempt_time);
            tried = tried+1;
            if tried > n_attempts_allowed
                warning('HERBERT:unlock:runtime_error',...
                    ' Can not remove lock %s. It looks like threads got dead-locked. Progressing after Leaving lock removal job in background',...
                    filename);
                wlock_obj  = @()lock_bg_deleter(filename,ws);
                return;
            end
            attempt_time = attempt_time*increase_increment;
        else
            warning(ws);
            rethrow(ME);
            %permission_denied=false;
        end
    end
end
warning(ws);

end

function lock_bg_deleter(filename,ws)

while is_file(filename)
    pause(1);
    try
        delete(filename);
    catch
    end
end
warning(ws);

end
