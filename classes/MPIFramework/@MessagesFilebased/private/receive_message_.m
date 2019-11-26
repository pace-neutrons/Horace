function [err_code,err_mess,message] = receive_message_(obj,from_task_id,mess_name)
%   Receive message from job with the task_id (MPI rank) specified
% if task_id is empty, receive message from any task.
if ~exist('from_task_id','var') %receive message from any task
    from_task_id = [];
end
if ~isnumeric(from_task_id)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'Task_id to receive message should be a number');
end
if ~exist('mess_name','var') %receive any message for this task
    mess_name = '';
end
if ~ischar(mess_name)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'mess_name in recive_message command should be a message name (e.g. "starting")');
end
% code to build debugging log file
% task_id = obj.task_id_;
% n_labs  = obj.numLabs_;
% f_name = sprintf('message_%s_receive_log%d#%d',mess_name,task_id,n_labs);
% f_hl = fopen(f_name,'w');
% if f_hl<1
%     error('LOGGING:error','Can not open file %s',f_name);
% end
% cl_log = onCleanup(@()fclose(f_hl));
%
message=[];
[is,err_code,err_mess] = check_job_canceled(obj);
if is ; return; end
%
mess_folder = obj.mess_exchange_folder;
mess_present= false;
mess_receive_option = 'nolocked';
t0 = tic;
while ~mess_present
    folder_contents = get_folder_contents_(obj,mess_folder);
    
    [mess_names,mid_from,mid_to] = parse_folder_contents_(folder_contents,mess_receive_option);
    if isempty(mess_names)
        for_this_lab  = false;
    else
        for_this_lab = obj.labIndex == mid_to;
    end
    if any(for_this_lab) % a message intended for this lab received.
        mess_names = mess_names(for_this_lab);
        mid_from   = mid_from(for_this_lab);
        % check if message is from the lab requested
        if ~isempty(from_task_id)
            from_lab_requested = mid_from == from_task_id;
        else
            from_lab_requested = true(size(mid_from));
        end
        mess_names  = mess_names(from_lab_requested );
        mid_from   = mid_from(from_lab_requested );
        % check if message is as requested
        if ~isempty(mess_name)
            % failed accepted even if not requested
            tid_requested = ismember(mess_names,{mess_name,'failed'});
            mid_from    = mid_from (tid_requested);
            mess_names  = mess_names(tid_requested);
        end
        if ~isempty(mid_from)
            mess_present = true;
        end
    end
    if ~mess_present % no message intended for this lab is present in system.
        %         of = fopen('all');
        %         fprintf(f_hl,'****MESS: %s NOT present: %d open files in worker\n',mess_name,numel(of));
        %         for i=1:numel(of)
        %             fname = fopen(of(i));
        %             fprintf(f_hl,'  opened file: %s\n',fname);
        %         end
        
        % do waiting for it
        t_passed = toc(t0);
        if t_passed > obj.time_to_fail_
            err_code =  MESS_CODES.timeout_exceeded;
            err_mess = sprintf('Timeout waiting for message "%s" for task with id: %d',...
                mess_name,obj.labIndex);
            return;
        else
            pause(obj.time_to_react_);
            [is,err_code,err_mess] = check_job_canceled(obj);
            if is ; return; end
            continue;
        end
    end
end


% take only the first message directed to this lab
mess_fname = obj.job_stat_fname_(obj.labIndex,mess_names{1},mid_from(1));
if strcmp(mess_names{1},'failed')
    is_failed = true;
else
    is_failed = false;
end
%
% safeguard against message start being written up
% but have not finished yet when dispatcher asks for it
n_attempts = 0;
try_limit = 100;
received = false;
[rlock_file,wlock_file] = build_lock_fname_(mess_fname);

%deadlock_tries = 100;
lock_(rlock_file);
while ~received
    
    % the message can not be in process of writing as it should be locked
    % in this case
    %     if exist(wlock_file,'file') == 2
    %         pause(obj.time_to_react_)
    %         %fprintf(f_hl,'****MESS Receiving: Write lock file %s present\n',wlock_file);
    %         continue;
    %     end
    try
        mesl = load(mess_fname);
        received = true;
    catch err
        n_attempts = n_attempts+1;
        if n_attempts>try_limit
            rethrow(err);
        end
        pause(obj.time_to_react_)
    end
end
% process received message
message = mesl.message;
err_code  =MESS_CODES.ok;
err_mess=[];

if is_failed  % make failed message persistent
    plo = unlock_(rlock_file);
    return;
end

%clear source_unlocker;
% check if a message is from the data queue and we need to progress the data
% queue
from_data_queue = MESS_NAMES.is_queuing(mess_names{1});
progress_queue = false;
if from_data_queue
    first_queue_num = list_queue_messages_(obj.mess_exchange_folder,obj.job_id,...
        mess_names{1},from_task_id,obj.labIndex);
    if first_queue_num(1) >0
        progress_queue = true;
    end
end

if progress_queue % prepare the next message to read -- the oldest message
    % written earlier
    
    [fp,fn] = fileparts(mess_fname);
    next_mess_fname = fullfile(fp,[fn,'.',num2str(first_queue_num(1))]);
    
    [rlock_fileQ,wlock_fileQ] = build_lock_fname_(next_mess_fname);
    success = false;
    n_attempts = 0;
    while ~success
        % next queue file may be in process of writing to.
        if exist(wlock_fileQ,'file') == 2
            pause(obj.time_to_react_)
            continue;
        end
        lock_(rlock_fileQ);
        %
        [success,mess,mess_id]=movefile(next_mess_fname,mess_fname,'f');
        if ~success
            pause(obj.time_to_react_);
            n_attempts = n_attempts+1;
            if n_attempts > try_limit
                error(mess_id,mess);
            end
            %clear target_unlocker;
        end
        unlock_(rlock_fileQ);
    end
    unlock_(rlock_file);
else
    unlock_(mess_fname);
    unlock_(rlock_file);
    %pause(0.1);
end

%clear source_unlocker
%clear target_unlocker;





function [is,err_code,err_message] = check_job_canceled(obj)

mess_folder = obj.mess_exchange_folder;
if ~exist(mess_folder,'dir')
    err_code    = MESS_CODES.job_canceled;
    err_message = sprintf('Job with id %s have been canceled',obj.job_id);
    is          = true;
else
    err_code     = [];
    err_message  = '';
    is           = false;
end
