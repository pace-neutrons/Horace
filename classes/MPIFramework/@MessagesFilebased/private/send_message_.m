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
    if exist(mess_fname,'file') == 2
        [~,free_queue_num] = list_these_messages_(obj,mess_name,obj.labIndex,task_id);
        [fp,fn] = fileparts(mess_fname);
        mess_fname = fullfile(fp,[fn,'.',num2str(free_queue_num)]);
    end
    save(mess_fname,'message');
else
    save(mess_fname,'message');
end
% Allow save operation to complete. On Windows some messages remain blocked
pause(0.1);

