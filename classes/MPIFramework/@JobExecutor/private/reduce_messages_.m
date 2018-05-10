function [ok,err,fin_mess] = reduce_messages_(obj,mess,mess_process_function,existing_only)
% reduce all messages 
%
if ischar(mess)
    mess_name = mess;
    the_mess = aMessage(mess_name);
elseif isa(mess,'aMessage')
    the_mess = mess;
    mess_name = the_mess.mess_name;
else
    error('JOB_EXECUTOR:invalid_argument',...
        'reduce_messages accepts only acceptable message or messages name')
end

if exist('mess_process_function','var') && ~isempty(mess_process_function)
    mes_proc_f = mess_process_function;
else
    mes_proc_f = @default_mess_process_function;
end
if ~exist('existing_only','var')
   existing_only = false;
end

%
mf = obj.mess_framework;
if mf.labIndex == 1
    if existing_only
        [~,task_ids] = mf.probe_all('all',mess_name);
        all_messages = mf.receive_all(task_ids,mess_name);        
    else
        all_messages = mf.receive_all('all',mess_name);
    end
    all_messages = [{the_mess},all_messages];
    [ok,err,fin_mess] = mes_proc_f(all_messages,mess_name);
else
    fin_mess = the_mess;
    [ok,err]=mf.send_message(1,the_mess);
    if ok == MESS_CODES.ok
        ok = true;
    else
        ok = false;        
    end
end

function [ok,err,fin_message] = default_mess_process_function(all_messages,mess_name)

ok = cellfun(@(x)(strcmpi(x.mess_name,mess_name)),all_messages,'UniformOutput',true);
ok = all(ok);
err = [];
if ~ok
    fin_message = aMessage('failed');
    fin_message.payload = all_messages;
    n_failed = sum(~ok);
    err = sprintf('JobExecutorInit: %d workers falied to start',...
        n_failed);
else
    all_payload = cellfun(@(x)(x.payload),all_messages,'UniformOutput',false);    
    fin_message = all_messages{1};
    fin_message.payload = all_payload;
end
