function [ok,err,fin_mess,obj] = reduce_messages_(obj,mess,reduction_type_name,mess_process_function,lock_until_received)
% Reduce all messages and build final message as the result of all similar
% messages on the workers.
%
% Inputs:
% mess                  -- the message to reduce or its name if the message has default constructor.
%                          This is the message,
%                          containing information about current worker state.
%
% reduction_type_name   -- the name of the message/state to process. Under normal
%                          situation, it is equal to the mess.mess_name,
%                          but if exception have occured, mess contains the
%                          informatiob about the failure, but reduction_mess_name
%                          still informs what the state of the worker
%                          should be processing.
%
% mess_process_function -- the function used to process list of similar messages to
%                          build final message. If empty, default function
%                          is used, which just combines payloads of all
%                          messages, received from all workers together.
%
% lock_until_received   -- if false, collects only existing messages from all
%                          workers and do not wait for receiving similar
%                          messages from other workers. Useful in case of
%                          reducing logging, in which case head-node should
%                          not wait for other nodes to produce log messages
%                          if absent, assumed to be true.
% Returns:
% fin_mess    containing information about the results of the reduce
% process. For working nodes send state message (reduction_type_name) to the 
% node 1, for node 1, reduces messages and return result to 

if ischar(mess)
    the_mess = MESS_NAMES.instance().get_mess_class(mess);
elseif isa(mess,'aMessage')
    the_mess = mess;
else
    error('JOB_EXECUTOR:invalid_argument',...
        'reduce_messages accepts only acceptable message or messages name')
end
if nargin<3 || isempty(reduction_type_name)
    reduction_type_name = the_mess.mess_name;
end

if nargin< 4 || isempty(mess_process_function)
    mes_proc_f = @default_mess_process_function;
else
    mes_proc_f = mess_process_function;    
end
if nargin < 5 % lock_until_received defined
    lock_until_received = true;
end

%
mf = obj.mess_framework;
if isempty(mf) % something wrong, framework deleted
    ok = MESS_CODES.job_cancelled;
    err = 'Something wrong, framework does not exist';
    fin_mess = FailedMessage('inter-worker communications: Initialization error');
    return
end

if mf.labIndex == 1
    if lock_until_received
        all_messages = mf.receive_all('all',reduction_type_name,'-synch');
        %disp([' all messages ',mess_name,' received synchronously']);
    else
        all_messages = mf.receive_all('all',reduction_type_name,'-asynch');
        %disp([' all messages ',mess_name,' received asynchronously']);
    end
    all_messages = [{the_mess},all_messages];
    %disp(all_messages);
    
    [ok,err,fin_mess] = mes_proc_f(all_messages,reduction_type_name);
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

function [all_ok,err_mess,fin_message] = default_mess_process_function(all_messages,mess_name)
% default message_process function collects all messages together and
% combines all messages payloads into common cellarray.
%
% Input:
% all_messages -- the cellarray, containing all messages.
% mess_name    -- the name, all messages should be processed under.
%
% Returns:
% all_ok   -- the boolean, true on success and false on failure.
% err_mess -- error message containing information about the failure if
%             all_ok==false
%fin_message -- the message, build during reduction. If all_ok, its the
%          one of input all_messages instance, with payload, containing
%          combined payloadl. If all_ok is false,
%          its the instance of FailedMessage, again with combined payload.
%
% If all messages in input sequence have the name, equal to input mess_name,
% the processing is considered successful, and if at least one name differs
% from mess_name, the processing considered a failure and all_ok = false.
%
ok = cellfun(@(x)(is_the_same(x,mess_name)),all_messages,'UniformOutput',true);
all_ok = all(ok);
err_mess = [];
all_payload = cellfun(@(x)extract_payload(x,mess_name),all_messages,'UniformOutput',false);
if ~all_ok
    n_failed = sum(~ok);
    err_mess = sprintf('JobExecutor: %d workers have failed',...
        n_failed);
    fin_message = FailedMessage(err_mess);
    fin_message.payload = all_payload;
else
    fin_message = all_messages{1};
    fin_message.payload = all_payload;
end
%
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
