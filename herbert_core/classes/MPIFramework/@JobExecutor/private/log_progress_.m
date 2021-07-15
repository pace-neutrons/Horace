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
% Throws JOB_EXECUTOR:cancelled error in case the job has been cancelled.
% Throws JOB_EXECUTOR:cancelled error in case the reduce_messages returned
% Failed message.
%
%

    [is_cancelled,reason] = obj.is_job_cancelled();
    if is_cancelled % will go to process_fail_state, which will collect failure information from other nodes.
        error('JOB_EXECUTOR:cancelled',...
              'Task %d has been cancelled at step %d#%d. Reason: %s',...
              obj.labIndex,step,n_steps,reason)
    end


    mess = LogMessage(step,n_steps,time_per_step,add_info);

    obj.mess_framework.throw_on_interrupts = false; % do not throw on receiving interrupt
                                                    % message, as the reduction will identify the failure and gather failure information if such
                                                    % info is available.
    [~,~,fin_mess] = reduce_messages_(obj,mess,'log',[],false);
    obj.mess_framework.throw_on_interrupts = true;

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

            obj.control_node_exch.send_message(0,fin_mess);
        else % May be fail message if some of the workers failed.
             % Will not be fail message if this node has failed, as it will go
             % to process_fail_state function, which would prepare and send
             % appropriate Fail message

        end

    end
    if strcmp(fin_mess.mess_name,'failed') % Happens when reduce_messages received unexpected
                                           % (normally 'cancelled') message from other nodes instead of receiving 'log' or no message.
                                           % In this case, should finish execution.
        error('JOB_EXECUTOR:cancelled',...
              'Task N%d has been interrupted at log point at step %d#%d as other worker(s) reported failure.\n Info: %s',...
              obj.labIndex,step,n_steps,evalc('disp(fin_mess.payload)'));

    end
end
