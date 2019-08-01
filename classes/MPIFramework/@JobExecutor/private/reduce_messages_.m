function [ok,err,fin_mess,obj] = reduce_messages_(obj,mess,mess_process_function,lock_until_received,reduction_name)
% reduce all messages and build final message as the result of all similar
% messages on the workers
% Inputs:
% mess                  -- the message(s) to reduce
% mess_process_function -- the function used to process list of similar messages to
%                          build final message. If empty, default function
%                          is used
% lock_until_received   -- if false, collects only existing messages from all
%                          workers and do not wait for receiving similar
%                          messages from other workers. Useful in case of
%                          reducing logging, in which case head-node should
%                          not wait for other nodes to produce log messages
%                          if absent, assumed to be true
% other_name            -- alternative name of the message. Should be used
%                          to collect messages from other workers if current
%                          message mess is Fail. If absent, the name is the
%                          same as the mess.mess_name
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
if ~exist('lock_until_received','var')
    lock_until_received = true;
end
if ~exist('reduction_name','var')
    reduction_name = mess_name;
end

%
mf = obj.mess_framework;
if isempty(mf) % something wrong, framework deleted
    ok = false;
    err = 'MPI initialization error';
    fin_mess = aMessage('failed');
    fin_mess.payload = err;
    return
end

if mf.labIndex == 1
    if lock_until_received
        all_messages = mf.receive_all('all',reduction_name);
    else
        [~,task_ids] = mf.probe_all('all',reduction_name);
        if numel(task_ids) > 0
            all_messages = mf.receive_all(task_ids,reduction_name);
        else
            all_messages = {};
        end
    end
    all_messages = [{the_mess};all_messages];
    
    [ok,err,fin_mess] = mes_proc_f(all_messages,reduction_name);
else
    %
    fin_mess = the_mess;
    [ok,err]=mf.send_message(1,the_mess);
    if ok == MESS_CODES.ok
        ok = true;
    else
        ok = false;
    end
end

function [all_ok,err,fin_message] = default_mess_process_function(all_messages,mess_name)


ok = cellfun(@(x)(strcmpi(x.mess_name,mess_name)),all_messages,'UniformOutput',true);
all_ok = all(ok);
err = [];
all_payload = cellfun(@(x)(x.payload),all_messages,'UniformOutput',false);
if ~all_ok
    n_failed = sum(~ok);
    err = sprintf('JobExecutorInit: %d workers have failed',...
        n_failed);
    fin_message = FailMessage(err);
    %all_payload(~ok) = all_messages(~ok);
    fin_message.payload = all_payload;
else
    fin_message = all_messages{1};
    fin_message.payload = all_payload;
end
