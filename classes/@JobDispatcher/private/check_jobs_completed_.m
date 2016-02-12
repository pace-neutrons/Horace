function [completed,n_failed,output_exists,this]= check_jobs_completed_(this)
% Verifies a state of running jobs checking the presence of special files,
% identifying the job's state
%
% input jobs all come starting, change to running state and should
% successfully end not starting and not running
%
n_jobs = numel(this.running_jobs_);
n_failed = n_jobs;
n_completed=n_jobs;
output_exists =false;
for id=1:n_jobs
    if isempty(this.running_jobs_{id})
        continue;
    end
    job = this.running_jobs_{id};
    
    if ~job.is_starting && ~job.is_running % job completed
        if ~job.failed
            n_failed = n_failed-1;
        end
        continue;
    end
    %
    if job.is_running
        % here job_status file should indicate running state
        if ~this.job_state_is(job,this.run_tag_)
            % wait for some time for completed status file to appear
            if ~this.job_state_is(job,this.end_tag_)
                job.waiting_count = job.waiting_count+1;
                if job.waiting_count > this.fail_limit_
                    job.failed  = true;
                    n_failed = n_failed+1;
                end
            else
                [isfail,job,oe] = this.analyze_output_(job);                
                if isfail
                    n_failed = n_failed+1;
                end
                output_exists = output_exists||oe;
            end
        else
            n_completed = n_completed-1;
        end
    end
    %
    if job.is_starting
        % here job status file should indicate starting
        if this.job_state_is(job,this.start_tag_)
            job.waiting_count = job.waiting_count+1;
            if job.waiting_count > this.fail_limit_
                n_failed = n_failed+1;
            end
            n_completed = n_completed-1;
        else
            if this.job_state_is(job,this.run_tag_)
                job.waiting_count = 0;
                job.is_starting = false;
                job.is_running = true;
                n_completed = n_completed-1;
            else % check job have finished successfully and very quickly
                if this.job_state_is(job,this.end_tag_)
                    [isfail,job,oe] = this.analyze_output_(job);
                    if isfail
                        n_failed = n_failed+1;
                    end
                    output_exists = output_exists||oe;                    
                else % job have quickly failed
                    job.failed = true;
                    n_failed = n_failed+1;
                end
            end
        end
        
    end
    %
    n_failed = n_failed-1;
    this.running_jobs_{id}=job;
end
if n_failed == n_jobs
    for i=1:n_failed
        this.running_jobs_{i}.failed = true;
    end
end
if n_failed == n_jobs || n_completed == n_jobs
    completed = true;
else
    completed = false;    
end
end
