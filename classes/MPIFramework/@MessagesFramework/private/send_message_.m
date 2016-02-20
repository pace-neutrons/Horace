function [ok,err_mess] = send_message_(obj,job_id,message)
% Send message to a job with specified ID

%
ok = true;
err_mess=[];
%
if is_string(message) && ~isempty(message)
    message = aMessage(message);
end
if ~isa(message,'aMessage')
    ok = false;
    err_mess = 'Can only send instances of aMessage class';
    return
end
mess_name = message.mess_name;
mess_fname = obj.job_stat_fname_(job_id,mess_name);
save(mess_fname,'message');

