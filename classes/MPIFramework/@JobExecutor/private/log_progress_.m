function  log_progress_(this,step,n_steps,time_per_step,add_info)
% log progress of the job exectution and report it to the
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
me = this.message_framework_;
if me.is_job_cancelled
    error('MESSAGE_FRAMEWORK:cancelled',...
        'job with id %s have been canceled or not initialized',...
        this.job_id);
end 
% cannibalize 'started' message as this job will send 'running' messages
if this.check_message('started')
    this.receive_message('started');
end
%
mess = LogMessage(step,n_steps,time_per_step,add_info);
[ok,err]=this.send_message(mess);
if ~ok
    error('JOB_EXECUTOR:log_progress','Can not send log message, Err: %s',...
        err);
end



