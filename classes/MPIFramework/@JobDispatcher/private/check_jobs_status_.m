function [completed,n_failed,this]= check_jobs_status_(this)
% scan through the registered jobs list to identify status of the jobs
%
% Verifies a state of running jobs checking the presence of special files,
% identifying the job's state
%
% input jobs all come starting, change to running state and should
% successfully end not starting and not running
%
n_jobs = numel(this.running_jobs_);
n_failed = n_jobs;
n_completed=n_jobs;
for id=1:n_jobs
    if isempty(this.running_jobs_(id))
        continue;
    end
    job = this.running_jobs_(id);
    
    if job.is_finished % job completed
        if ~job.is_failed
            n_failed = n_failed-1;
        end
        continue;
    end
    % job report its failure
    if job.job_state_is(this,'failed')
        [ok,err,mess] = this.receive_message(job.job_id,'failed');
        if ~ok
            error('JOB_DISPATCHER:messages_error',err);
        end
        job=job.set_failed(mess.payload);
        this.running_jobs_(id) = job;
        continue;
    end
    % it does not say it failed but still can fail silently
    % but we hope it will run
    if job.is_running
        % here job_status file should indicate running state
        if job.job_state_is(this,'started')
            % job does not report progress
            n_completed = n_completed-1;
        elseif job.job_state_is(this,'running')
            % job should report progress
            [isfail,job] = job.get_progress(this);
            if isfail
                n_failed = n_failed+1;
            end
            n_completed = n_completed-1;
        else
            % wait for some time for completed status file to appear
            if ~job.job_state_is(this,'completed')
                job.waiting_count = job.waiting_count+1;
                if job.waiting_count > this.fail_limit_
                    job=job.set_failed('Timeout waiting for job_completed message');
                    n_failed = n_failed+1;
                end
                n_completed = n_completed-1;
            else
                [isfail,job] = job.get_output(this);
                if isfail
                    n_failed = n_failed+1;
                end
            end
            
        end
    end
    %
    if job.is_starting
        % here job status file should indicate starting
        if job.job_state_is(this,'starting')
            job.waiting_count = job.waiting_count+1;
            if job.waiting_count > this.fail_limit_
                n_failed = n_failed+1;
                %  but let's not set up this job as failed, let's give it
                %  time  to continue until other are running
                %fail_reason = 'Timeout waiting for job_running message';
            end
            n_completed = n_completed-1;
        else
            % here job may or may not return running state
            if job.job_state_is(this,'running') || job.job_state_is(this,'started')
                job.is_running = true;
                n_completed = n_completed-1;
            else % check job have finished successfully and very quickly
                if job.job_state_is(this,'completed')
                    [isfail,job] = job.get_output(this);
                    if isfail
                        n_failed = n_failed+1;
                    end
                else % job have quickly failed
                    job=job.set_failed('Worker have not started. No "started" message from JobExecutor.init_worker');
                    n_failed = n_failed+1;
                end
            end
        end
        
    end
    %
    n_failed = n_failed-1;
    this.running_jobs_(id)=job;
end
if n_failed == n_jobs
    for i=1:n_failed
        job = this.running_jobs_(i);
        if ~job.is_failed % all job have failed not able to change from "starting"
            % to "running" status
            this.running_jobs_(i) = job.set_failed('Timeout waiting for job_started message');
        end
    end
end
if n_failed == n_jobs || n_completed == n_jobs
    completed = true;
else
    completed = false;
end


