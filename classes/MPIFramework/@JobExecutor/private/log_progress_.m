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
% Throws MESSAGE_FRAMEWORK:cancelled error in case the job has
%
mess = LogMessage(step,n_steps,time_per_step,add_info);
[~,~,fin_mess] = reduce_messages_(obj,mess,[],true);
if obj.labIndex == 1
    all_logs = fin_mess.payload;
    n_steps_done = inf;
    n_steps_to_do = -inf;
    tps = -inf;
    add_info = {};
    for i=1:numel(all_logs)
        n_steps_done = min(n_steps_done,all_logs{i}.step);
        n_steps_to_do = max(n_steps_to_do,all_logs{i}.n_steps);
        tps = max(tps,all_logs{i}.time);
        if ~isempty(all_logs{i}.add_info)
            add_info = [add_info,{all_logs{i}.add_info}];
        end
    end
    if numel(add_info) == 1
        add_info = add_info{1};
    end
    mess = LogMessage(n_steps_done ,n_steps_to_do,tps,add_info);
    obj.control_node_exch.send_message(0,mess);
end



