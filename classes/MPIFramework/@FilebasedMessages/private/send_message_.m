function [ok,err_mess] = send_message_(obj,task_id,message)
% Send message to a job with specified ID
%
ok = MPI_err.ok;
err_mess=[];
if ~exist(obj.exchange_folder,'dir')
    ok = MPI_err.job_canceled;
    err_mess = sprintf('Job with id %s have been canceled',obj.job_control_pref);
    return;
end
%
if is_string(message) && ~isempty(message)
    message = aMessage(message);
end
if ~isa(message,'aMessage')
    ok = MPI_err.runtime_error;
    err_mess = 'Can only send instances of aMessage class';
    return
end
mess_name = message.mess_name;
mess_fname = obj.job_stat_fname_(task_id,mess_name);
save(mess_fname,'message');

