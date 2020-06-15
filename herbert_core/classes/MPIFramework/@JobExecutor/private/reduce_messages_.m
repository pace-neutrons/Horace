function [ok,err,fin_mess,obj] = reduce_messages_(obj,mess,mess_process_function,lock_until_received)
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

if ischar(mess)
    mess_name = mess;
    the_mess = MESS_NAMES.instance().get_mess_class(mess_name);
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

%
mf = obj.mess_framework;
if isempty(mf) % something wrong, framework deleted
    ok = MESS_CODES.job_canceled;
    err = 'Something wrong, framework does not exist';
    fin_mess = FailedMessage('inter-worker communications: Initialization error');
    return
end

if mf.labIndex == 1
    if lock_until_received
        all_messages = mf.receive_all('all',mess_name,'-synch');    
        %disp([' all messages ',mess_name,' received synchronously']);        
    else
        all_messages = mf.receive_all('all',mess_name,'-asynch');          
        %disp([' all messages ',mess_name,' received asynchronously']);                
    end
    all_messages = [{the_mess},all_messages];
    %disp(all_messages);
    
    [ok,err,fin_mess] = mes_proc_f(all_messages,mess_name);
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


ok = cellfun(@(x)(is_the_same(x,mess_name)),all_messages,'UniformOutput',true);
all_ok = all(ok);
err = [];
all_payload = cellfun(@(x)extract_payload(x,mess_name),all_messages,'UniformOutput',false);
if ~all_ok
    n_failed = sum(~ok);
    err = sprintf('JobExecutor: %d workers have failed',...
        n_failed);
    fin_message = FailedMessage(err);
    %all_payload(~ok) = all_messages(~ok);
    fin_message.payload = all_payload;
else
    fin_message = all_messages{1};
    fin_message.payload = all_payload;
end
function is = is_the_same(mess,mess_name)
if isa(mess,'aMessage')
    is = strcmpi(mess.mess_name,mess_name);
else
    is = false;
end
function pl = extract_payload(mess,mess_name)
if isempty(mess)
    pl = ['Empty result for message: ',mess_name];
else
    pl = mess.payload;
end
