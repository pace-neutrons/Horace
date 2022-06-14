function [ok,err_mess,wlock_obj] = send_message_(obj,task_id,message)
% Send message to a job with specified ID
%
ok = MESS_CODES.ok;
err_mess=[];
wlock_obj =[];

if ~is_folder(obj.mess_exchange_folder)
    ok = MESS_CODES.job_cancelled;
    err_mess = sprintf('Job with id %s have been cancelled. No message exchange folder exists',obj.job_id);
    return;
end
if task_id<0 || task_id>obj.numLabs
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'The message is directed to %d but can be only sent to workers in range [0:%d]',...
        task_id,obj.numLabs);
end

%
if is_string(message) && ~isempty(message)
    message = MESS_NAMES.instance().get_mess_class(message);
end
if ~isa(message,'aMessage')
    error('FILEBASE_MESSAGES:runtime_error',...
        'Can only send instances of aMessage class, but attempting to send %s',...
        class(message));
end

mess_name = message.mess_name;
is_blocking = message.is_blocking;
is_interrupt = message.is_persistent;
if is_interrupt
    is_blocking = false;
    mess_name = obj.interrupt_chan_name_;
end

mess_fname = obj.job_stat_fname_(task_id,mess_name);
max_tries = 100;

if is_blocking
    % can not be read-locked, read can look for but can not start reading non-existing
    % data messages. synchronous data messages are never overwritten.
    [~,wlock_file]  = build_lock_fname_(mess_fname);
    obj.send_data_messages_count_(task_id+1)=obj.send_data_messages_count_(task_id+1)+1;

else
    [rlock_file,wlock_file]  = build_lock_fname_(mess_fname);
    n_attempts = 0;
    t_r = obj.time_to_react_;
    while is_file(rlock_file) % previous message is reading, wait until read process completes
        pause(t_r)
        n_attempts = n_attempts +1;
        t_r = t_r*1.05;
        if n_attempts > max_tries
            warning(' Can not wait until read lock is removed. Incoherent filesystem view?')
            error('MESSAGES_FRAMEWORK:runtime_error','Can not save message file %s',mess_fname);
        end
    end
end

lock_(wlock_file);

[fp,fn,fext] = fileparts(mess_fname);
mess_fname = fullfile(fp,[fn,'.tmp_',fext(2:end)]);
save(mess_fname,'message','-v7.3');
% check the file has been idenfitied on the filesystem (may be considered
% just as reasonable delay timer, fir file beeing actually written)
written = is_file(mess_fname);
t_r = obj.time_to_react_;
n_attempts = 0;
while ~written
    pause(t_r);
    n_attempts = n_attempts +1;
    written = is_file(mess_fname);
    if n_attempts > max_tries
        warning(' Can not wait until file appears on the drive. Incoherent filesystem view?')
        error('MESSAGES_FRAMEWORK:runtime_error','Can not save message file %s',mess_fname);
    end

end
%
wlock_obj = unlock_(wlock_file,mess_fname);
if ~isempty(wlock_obj)
    ok = MESS_CODES.write_lock_persists;
end