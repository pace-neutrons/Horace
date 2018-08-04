function [ok,err_mess] = send_message_(obj,task_id,message)
% Send message to a job with specified ID
%
ok = MESS_CODES.ok;
err_mess=[];
if ~exist(obj.mess_exchange_folder,'dir')
    ok = MESS_CODES.job_cancelled;
    err_mess = sprintf('Job with id %s have been cancelled. No message exchange folder exist',obj.job_id);
    return;
end
%
if is_string(message) && ~isempty(message)
    message = aMessage(message);
end
if ~isa(message,'aMessage')
    error('FILEBASE_MESSAGES:runtime_error',...
        'Can only send instances of aMessage class, but attempting to send %s',...
        class(message));
end
mess_name = message.mess_name;
needs_queue = MESS_NAMES.is_queuing(mess_name);

mess_fname = obj.job_stat_fname_(task_id,mess_name);
if needs_queue
    [fp,fn] = fileparts(mess_fname);
    [start_queue_num,free_queue_num] = ...
        list_these_messages_(obj.mess_exchange_folder,obj.job_id,mess_name,obj.labIndex,task_id);
    if start_queue_num(1) >= 0
        mess_fname = fullfile(fp,[fn,'.',num2str(free_queue_num)]);
    end
end

lock_file  = build_lock_fname_(mess_fname);
while exist(lock_file,'file') == 2
    pause(obj.time_to_react_)
end

fh = fopen(lock_file,'wb');
%prepare lock removal after the routine completeon
clob = onCleanup(@()unlock_(fh,lock_file));
%
save(mess_fname,'message','-v7.3');
%
clear clob;

