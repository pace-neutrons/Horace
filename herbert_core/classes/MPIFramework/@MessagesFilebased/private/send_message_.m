function [ok,err_mess,wlock_obj] = send_message_(obj,task_id,message)
% Send message to a job with specified ID
%
ok = MESS_CODES.ok;
err_mess=[];
wlock_obj =[];
if ~exist(obj.mess_exchange_folder,'dir')
    ok = MESS_CODES.job_canceled;
    err_mess = sprintf('Job with id %s have been canceled. No message exchange folder exist',obj.job_id);
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
needs_queue = message.is_blocking;
%fprintf('\n Sending message to lab %d ',task_id);
mess_fname = obj.job_stat_fname_(task_id,mess_name);

[rlock_file,wlock_file]  = build_lock_fname_(mess_fname);
while exist(rlock_file,'file') == 2 % previous message is reading, wait until read process completes
    pause(obj.time_to_react_)
end
lock_(wlock_file);

% extensions of the queue numbers will be
if needs_queue
    [fp,fn] = fileparts(mess_fname);
    [start_queue_num,free_queue_num] = ...
        obj.list_queue_messages(mess_name,obj.labIndex,task_id,'-show_locked');
    if start_queue_num(1) >= 0
        mess_fname1 = fullfile(fp,[fn,'.',num2str(free_queue_num)]);
    else
        mess_fname1 = mess_fname;
    end
    
else
    mess_fname1 = mess_fname;
end
if ~strcmp(mess_fname,mess_fname1)
    unlock_(wlock_file);
    
    mess_fname = mess_fname1;
    [rlock_file,wlock_file]  = build_lock_fname_(mess_fname);
    while exist(rlock_file,'file') == 2 % previous message is reading, wait until read process completes
        pause(obj.time_to_react_)
    end
    lock_(wlock_file);
end

%
[fp,fn,fext] = fileparts(mess_fname);
mess_fname = fullfile(fp,[fn,'.tmp_',fext(2:end)]);
save(mess_fname,'message','-v7.3');
% check the file has been idenfitied on the filesystem (may be considered
% just as reasonable delay timer, fir file beeing actually written)
written = exist(mess_fname,'file') == 2;
while ~written
    pause(obj.time_to_react_);
    written = exist(mess_fname,'file') == 2;
end
%
wlock_obj = unlock_(wlock_file,mess_fname);
if ~isempty(wlock_obj)
    ok = MESS_CODES.write_lock_persists;
end
