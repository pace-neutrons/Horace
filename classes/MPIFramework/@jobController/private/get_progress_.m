function     obj = get_progress_(obj,mpi,is_already_running)
% get current job progress message and register job as receiving progress
% messages

[ok,err,mess] = mpi.receive_message(obj.job_id,'running');
if ~ok
    if ~is_already_running
        obj = obj.set_failed(['Not able to retrieve "job_running" message. Err: ',...
            err]);
    else % its possible that running message is being replaced while we are trying to read it
         % at least, list_all_messages have seen it and here we do not. 
         % ignore for the time being
    end
else
    obj.is_running = true;
    obj.reports_progress_ = true;
    
    obj.waiting_interval_start_ = tic;
    obj.estimatied_wait_time_  = mess.time_per_step;
    obj.progress_info_ = mess;
end



