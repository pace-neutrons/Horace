function   [all_messages,tid_received_from] = receive_all_messages_(obj,tid_requested,mess_name,varargin)
% retrieve all messages intended for jobs with task id-s  provided as input
% if message name is also present, return only messages with the name
% specified and wait until the messages with this name arrive from all labs
% requested
%
%
if ~exist('tid_requested','var') || isempty(tid_requested) || (ischar(tid_requested) && strcmpi(tid_requested,'all'))
    tid_requested = 1:obj.numLabs;
    all_tid_requested = true;
else
    all_tid_requested = false;
end
this_tid = tid_requested == obj.labIndex;
if any(this_tid)
    tid_requested = tid_requested(~this_tid);
end

fh = obj.MPI_.log_fh;
if isempty(fh)
    do_logging = false;
else
    do_logging = true;
end


if ~exist('mess_name','var') || isempty(mess_name)
    mess_name = 'any';
end
if strcmp(mess_name,'any')
    any_mess_requested = true;
else
    any_mess_requested = false;
end
lock_until_received = obj.check_is_blocking(mess_name,varargin);

% return state messages, satisfying the receive request.
[state_mess,tid_state]=obj.state_mess_cache_.pop_messages(tid_requested,mess_name);
state_present= ismember(tid_requested,tid_state);

% return data messages, satisfying the receive request, but received from
% the labs where the state messages have not arrived from. These two unions
% will intercect only if 'any' tag is provided, so normally never
task_ids_to_receive = tid_requested(~state_present);
if isempty(task_ids_to_receive)
    data_mess = {};
    tid_data = [];
else
    [data_mess,tid_data]=obj.blocking_mess_cache_.pop_messages(task_ids_to_receive,mess_name);
end
if do_logging
    fprintf(fh,'+++ Retrieved from cach %d state messages and %d Data messages\n',...
        numel(state_mess),numel(data_mess));
end
% % b for switch -- boolean variable
% b_data_present= ismember(tid_requested,tid_data);

% glue together data and state messages which can be returned according to
% the request. Data do not overwrite the state messages as state present
% are ignored. (Should not ask both for data and state messages except
% mess_name = 'any' is requested)
[all_messages,tid_received_from] = obj.mix_messages(state_mess,tid_state,data_mess,tid_data);
if do_logging
    fprintf(fh,'+++ setting result to:\n');
    for i=1:numel(all_messages)
        if ~isempty(all_messages{i})
            fprintf(fh,'   Message %s received from %d\n',...
                all_messages{i}.mess_name,tid_received_from(i));
        end
    end
end

if lock_until_received && (numel(all_messages) == numel(tid_requested)) % Everything has been found in cache.
    % return result.
    return;
end
% check if something new has arrived. State messages can be overwritten, so
% do not touch data messages only. Use requested mess_name as the filter.
if all_tid_requested
    [messages_names,tid_present] = labProbe_messages_(obj,'all',mess_name); % just more efficiently to use this form,
    % as asks for all messages directly from the framework
else
    [messages_names,tid_present] = labProbe_messages_(obj,tid_requested,mess_name);
end
if do_logging
    fprintf(fh,'+++ Found %d messages send to the node %d:\n',...
        numel(messages_names),obj.labIndex);
    for i=1:numel(messages_names)
        fprintf(fh,'   Message %s send from %d\n',...
            messages_names{i},tid_present(i));
    end
end

% b for switch -- boolean variable
b_mess_ready     = ismember(tid_requested,tid_present); %
b_mess_received  = ismember(tid_requested,tid_received_from);

n_requested = numel(tid_requested);
this_mess_requested = cell(1,n_requested);
this_mess_requested(b_mess_received) = all_messages(:); % prepare to return messages, stored in cache.
all_messages = this_mess_requested;  % fill output with cache messages, leaving spaces for
% other messages present in system to receive, contained in the cellarray
% of size n_requested
% what names are actually here
names_present = cell(1,n_requested);
names_present(b_mess_ready) = messages_names(:);

% can not receive present persistent messages, which do not fit the cache.
b_mess_ready = check_cache_space(obj,tid_requested,names_present,b_mess_ready);

t0 = tic;
all_received = false;
while ~all_received
    for i=1:n_requested % receive all existing messages in the messages queue
        if ~b_mess_ready(i); continue;
        end
        %
        
        %
        message = obj.get_interrupt(tid_requested(i));
        if isempty(message)
            message = obj.MPI_.mlabReceive(tid_requested(i),names_present{i});
            obj.set_interrupt(message,tid_requested(i));
            interrupt_received = false;
        else
            interrupt_received = true;
        end
        if do_logging
            fprintf(fh,'+++ Received message %s from node %d: while requesting %s\n',...
                message.mess_name,tid_requested(i),mess_name);
        end
        this_mess_requested = strcmp(message.mess_name,mess_name) ||any_mess_requested;
        
        if this_mess_requested % got what we asked for
            if message.is_blocking && b_mess_received(i) % put into cache
                % space in cache is avail. We have checked it before
                if obj.blocking_mess_cache_.is_empty(tid_requested(i))
                    obj.blocking_mess_cache_.push_messages(tid_requested(i),message);
                else
                    error('MESSAGES_FRAMEWORK:runtime_error',...
                        'No space to store received data message')
                    
                end
                if do_logging
                    fprintf(fh,'+++ Stored second reqiested message %s in cache\n',...
                        message.mess_name);
                end
                
            else
                all_messages{i} = message;
                b_mess_received(i)= true;
                if do_logging
                    fprintf(fh,'+++ Setting requested output %d from tid %d to message %s\n',...
                        i,tid_requested(i),message.mess_name);
                end
                
            end
            
        else % we received message which is not asked for now but will be
            % requested in a future or is blocking futher messages.
            if interrupt_received ||  strcmp(message.mess_name,'canceled')
                all_messages{i} = message;
                b_mess_received(i)= true;
                if do_logging
                    fprintf(fh,'+++ setting output %d for %d to interrupt %s\n',...
                        i,tid_requested(i),message.mess_name);
                end
            else
                if message.is_blocking
                    if obj.blocking_mess_cache_.is_empty(tid_requested(i))
                        obj.blocking_mess_cache_.push_messages(tid_requested(i),message);
                    else
                        error('MESSAGES_FRAMEWORK:runtime_error',...
                            'No space to store received data message')
                    end
                    
                    if do_logging
                        fprintf(fh,'+++ Storing data message in cache\n');
                    end
                else % old status messages are overwritten.
                    obj.state_mess_cache_.push_messages(tid_requested(i),message);
                    if do_logging
                        fprintf(fh,'+++ Storing state message in cache\n');
                    end
                    
                end
            end
        end
    end
    if lock_until_received
        all_received = all(b_mess_received);
        if ~all_received
            if do_logging
                fprintf(fh,'+++ more messages needed\n');
            end
            
            t1 = toc(t0);
            if t1>obj.time_to_fail_;   error('FILEBASED_MESSAGES:runtime_error',...
                    'Timeout waiting for receiving all messages')
            end
            if all_tid_requested
                [messages_avail,tid_avail] = labProbe_messages_(obj,'all','any'); % just more efficiently to use this form,
                % as asks for all messages directly from the framework
            else
                [messages_avail,tid_avail] = labProbe_messages_(obj,tid_requested,'any');
            end
            
            b_mess_ready = ismember(tid_requested,tid_avail);
            names_present(b_mess_ready) = messages_avail(:);
            %
            % we probably do not want to receive anything from the
            % already received labs or labs where data are already
            % present.
            b_mess_ready = b_mess_ready & ~b_mess_received;
            b_mess_ready = check_cache_space(obj,tid_requested,names_present,b_mess_ready);
            if do_logging
                fprintf(fh,'+++ Present messages are:\n');
                for i=1:numel(messages_avail)
                    fprintf(fh,'   Message %s send from %d\n',...
                        messages_avail{i},tid_avail(i));
                end
                fprintf(fh,'+++ will process messages:\n labs:  ');
                for i=1:numel(b_mess_ready); fprintf(fh,'!   %d   !',tid_requested(i));
                end
                fprintf(fh,'\n ready: ');
                for i=1:numel(b_mess_ready); fprintf(fh,'!   %d   !',b_mess_ready(i));
                end
                fprintf(fh,'\n there:  ');
                for i=1:numel(b_mess_received); fprintf(fh,'!   %d   !',b_mess_received(i));
                end
                fprintf(fh,'\n');
            end
            if (obj.is_tested && ~any(b_mess_ready))
                error('MESSAGES_FRAMEWORK:runtime_error',...
                    'Issued request for missing blocking message in test mode');
            end
            pause(0.1);
        end
    else
        break;
    end    
end

% compress empty messages places if any
all_messages = all_messages(b_mess_received);
tid_received_from = tid_requested(b_mess_received);
if do_logging
    fprintf(fh,'+++ Received messages:\n');
    for i=1:numel(all_messages)
        fprintf(fh,' tid: %d, mess "%s"\n   payload: \n %s\n',...
            tid_received_from(i),all_messages{i}.mess_name,evalc('disp(all_messages{i}.payload)'));
    end
end


function b_can_be_received = check_cache_space(obj,tid_requested,names_present,b_can_be_received)
% we can not receive blocking messages which are not requested and which
% cache space is full (should FIFO cache just solve this problem?)
b_are_blkng_mess = MESS_NAMES.is_blocking(names_present);
tids_with_blocking = tid_requested(b_are_blkng_mess);
if isempty(tids_with_blocking)
    return;
end
b_non_blocking_mess = ~b_are_blkng_mess;

empty_cache = obj.blocking_mess_cache_.is_empty(tids_with_blocking);
tids_with_cache = tids_with_blocking(empty_cache);
b_cache_available = ismember(tid_requested,tids_with_cache)|b_non_blocking_mess ;
b_can_be_received  = b_can_be_received & b_cache_available ;
