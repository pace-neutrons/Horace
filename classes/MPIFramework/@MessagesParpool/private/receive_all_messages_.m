function   [all_messages,tid_received_from] = receive_all_messages_(obj,task_ids,mess_name)
% retrieve all messages intended for jobs with id provided
%
n_labs = obj.numLabs;
if n_labs == 1
    all_messages = {};
    tid_received_from = [];
    return;
end
%
if ~exist('task_ids','var')
    task_ids = [];
end
if isempty(task_ids) || (ischar(task_ids) && strcmpi(task_ids,'all'))
    task_ids = 1:n_labs;
end


if ~exist('mess_name','var')
    mess_name = '';
end
if isempty(mess_name)
    mess_name  = '';
end

not_this_id = task_ids ~= obj.labIndex;
tid_requested = task_ids(not_this_id);
n_requested = numel(tid_requested);

all_messages = cell(n_requested ,1);
tid_received_from = zeros(n_requested,1);
all_received = false;
%
[mess_names,tid_from] = labProbe_messages_(obj,tid_requested,mess_name);
%
tid_exist = ismember(tid_requested,tid_from);
n_received = 0;
t0 = tic;
fname = sprintf('receive_log_lab%d.txt',labindex);
fh = fopen(fname,'w');
clob = onCleanup(@()fclose(fh));
fprintf(fh,'requested messages from %d %d %d\n',tid_requested);
natt = 0;
while ~all_received
    fprintf(fh,' Attempt N%d receiving N%d messages\n',natt,numel(mess_names));
    natt = natt+1;
    for i=1:numel(tid_exist)
        if ~tid_exist(i); continue; end
        
        [ok,err_mess,message]=receive_message_(obj,tid_requested(i),mess_name);
        if ~ok
            error('PARPOOL_MESSAGES:runtime_error',...
                'Can not receive existing message: %s, Err: %s',...
                mess_names{i},err_mess);
        end
        all_messages{i} = message;
        tid_received_from(i) = tid_requested(i);
    end
    n_received  = n_received +numel(tid_from);
    fprintf(fh,'received: %d\n',n_received);
    if n_received >= n_requested
        all_received = true;
    else
        t1 = toc(t0);
        if t1>obj.time_to_fail_
            error('PARPOOL_MESSAGES:runtime_error',...
                'Timeout waiting for receiving all messages')
        end
%        for i=
        %
        fprintf(fh,'requested messages from %d %d %d\n',tid_requested);        
        [mess_names,tid_from] = labProbe_messages_(obj,tid_requested,mess_name);
        %
        tid_exist = ismember(tid_requested,tid_from);
    end
    
end
