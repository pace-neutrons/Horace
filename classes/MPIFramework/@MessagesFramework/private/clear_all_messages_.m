function   clear_all_messages_(obj)
%
% delete all messages, in the exchange folder, which satisfy the message template
%
mess_folder = obj.exchange_folder;
if ~exist(mess_folder,'dir')
    return;
end
[ok, message] = rmdir(mess_folder,'s');
% may be jobs are writing to the folder and one can not remove them
% immidiately
itry = 0;
while ~ok &&itry<10;
    pause(1);
    [ok, message] = rmdir(mess_folder,'s');
    itry = itry+1;
end
if ~ok
    warning('MESSAGES_FRAMEWORK:invalid_state',...
        [' Can not clear up all messages belonging to the framework instance %s\n',...
        ' Messages folder %s; Error message: $s\n,'],obj.job_control_pref,...
        obj.exchange_folder,message);
end
