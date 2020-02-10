function  log_progress_(obj,step,n_steps,time_per_step,add_info)
% log progress of the job execution and report it to the
% calling framework.
% Inputs:
% step     --  current step within the loop which doing the job
% n_steps  --  number of steps this job will make
% time_per_step -- approximate time spend to make one step of
%                  the job
% add_info  -- some additional information intended to be plotted in the
%              job log
% Outputs:
% Sends message of type LogMessage to the job dispatcher.
% Throws JOB_EXECUTOR:canceled error in case the job has
%
is_canceled = obj.is_job_canceled();
if is_canceled
    error('JOB_EXECUTOR:canceled',...
        'Task %d has been canceled at step %d#%d',obj.labIndex,step,n_steps)
end

mess = LogMessage(step,n_steps,time_per_step,add_info);

[~,~,fin_mess] = reduce_messages_(obj,mess,[],false,'log');
if obj.labIndex == 1
    if isa(fin_mess,'LogMessage') % calculate average logs
        all_logs = fin_mess.payload;
        n_steps_done = 0;
        n_steps_to_do = -inf;
        tps = 0;
        add_info = {};
        n_tasks_replied = numel(all_logs);
        for i=1:n_tasks_replied
            if isempty(all_logs{i}) || ~isstruct(all_logs{i}) % should not happen for log message but....
                continue;
            end
            n_steps_done = n_steps_done+all_logs{i}.step;
            n_steps_to_do = max(n_steps_to_do,all_logs{i}.n_steps);
            tps = tps + all_logs{i}.time;
            if ~isempty(all_logs{i}.add_info)
                add_info = [add_info,{all_logs{i}.add_info}];
            end
        end
        if numel(add_info) == 1
            add_info = add_info{1};
        end
        
        n_steps_done = n_steps_done/n_tasks_replied;
        tps = tps/n_tasks_replied;
        fin_mess = LogMessage(n_steps_done ,n_steps_to_do,tps,add_info);
        fin_mess  = fin_mess.set_worker_logs(all_logs);
    else % may be fail message if some of the workers were failed.
        % Will not be fail message if this node have failed, as it will go
        % in other path
    end
    obj.control_node_exch.send_message(0,fin_mess);
end
if strcmp(fin_mess.mess_name,'failed')
    error('JOB_EXECUTOR:runtime_error',...
        'Task N%d has been interrupted at log point at step %d#%d as other worker(s) reported failure',...
        obj.labIndex,step,n_steps);
end
