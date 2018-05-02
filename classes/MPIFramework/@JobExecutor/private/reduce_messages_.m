function [ok,err,fin_mess,all_messages] = reduce_messages_(obj,mess,mess_process_function)
%
if ischar(mess)
    mess_name = mess;
    the_mess = aMessage(mess_name);
elseif isa(mess,'aMessage')
    the_mess = mess;
    mess_name = the_mess.mess_name;
else
    error('JOB_EXECUTOR:invalid_argument',...
        
end

if exist('mess_process_function','var')
    mes_proc = mess_process_function;
else
    mes_proc = @(x)(x.mess_name == mess_name);
end
%
mf = obj.mess_framework;
if mf.labIndex == 1
    all_messages = mf.receive_all('all',mess_name);
    ok = cellfun(mes_proc,all_messages,'UniformOutput',true);
    ok = all(ok);
    err = [];
    fin_mess = the_mess;
    if ~ok
        fin_mess = aMessage('failed');
        fin_mess.payload = all_messages;
        n_failed = sum(~ok);
        err = sprintf('JobExecutorInit: %d workers falied to start',...
            n_failed);
    end
else
    [ok,err]=mf.send_message(1,the_mess);
end
