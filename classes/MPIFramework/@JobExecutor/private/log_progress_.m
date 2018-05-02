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
[~,~,all_mess] = reduce_messages_(obj,mess);
if obj.labIndex == 1
    all_mess = [{mess},all_mess];
    n_step_min = inf;
    n_steps_max = -inf;
    if ~isempty(add_info)
        add_info = {add_info};
    end
    tts = -inf;
    for i=1:numel(all_mess)
        n_step_min = min(n_step_min,all_mess{i}.n_steps);
        n_steps_max = max(n_steps_max,all_mess{i}.n_steps);
        tts = max(tts,all_mess{i}.time_per_step);
        if ~isempty(all_mess{i}.add_info)
            add_info = [add_info,{all_mess{i}.add_info}];
        end
    end
    if numel(add_info) == 1
        add_info = add_info{1};
    end
    mess = LogMessage(n_step_min ,n_steps_max,tts,add_info);
    obj.control_node_exch.send_message(0,mess);
end



