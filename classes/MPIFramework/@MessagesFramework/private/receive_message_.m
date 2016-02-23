function [ok,err_mess,message] = receive_message_(obj,job_id,mess_name)
%   Receive message for job with id
if ~isnumeric(job_id)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'Job id to recive message from should be a number');
end
if ~ischar(mess_name)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'mess_name in recive_message command should be a message name (e.g. "starting")');
end
%
if ~exist(obj.exchange_folder,'dir')
    ok = -1;
    err_mess = sprintf('Job with id %s have been canceled',obj.job_control_pref);
    return;
end
%
mess_fname = obj.job_stat_fname_(job_id,mess_name);
if exist(mess_fname,'file') ~= 2
    ok = false;
    err_mess = sprintf('Message "%s" for job with id: %d does not exist',mess_name,job_id);
    message = [];
    return;
end
mesl = load(mess_fname);
message = mesl.message;
ok = true;
err_mess=[];
delete(mess_fname);




