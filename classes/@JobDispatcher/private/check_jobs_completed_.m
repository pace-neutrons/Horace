function [completed,n_failed,this]= check_jobs_completed_(this,count)
% Verifies a state of running jobs checking the presence of special files,
% identifying the job's state
%
% input jobs all come starting, change to running state and should
% successfully end not starting and not running
%
n_jobs = numel(this.running_jobs_);
n_failed = n_jobs;
completed=true;
for id=1:n_jobs
    if isempty(this.running_jobs_{id})
        continue;
    end
    job = this.running_jobs_{id};
    if job.faliled
        continue;
    end
    % this job have not failed
    n_failed = n_failed-1;
    
    if ~job.is_starting && ~job.is_running % job completed
        continue;
    end
    %
    if job.is_running
        % here job_status file should indicate running state        
        if ~(exist(job.job_status_file,'file')==2) 
            completed_stat_file = get_job_stat_file_(this,job.job_id,this.end_tag_);
            
            if ~exist(completed_stat_file,'file') % wait for some time for completed status file to appear
                job.waiting_count = job.waiting_count+1;
                if job.waiting_count > this.fail_limit_
                    job.faliled = true;
                end
            else
                job.is_running=false;
                delete(completed_stat_file);
            end
        else 
            completed = false;
        end
    end
    %
    if job.is_starting
        if exist(job.job_status_file,'file')==2 % here job status file should indicate starting
            job.waiting_count = job.waiting_count+1;
            if job.waiting_count > this.fail_limit_
                job.faliled = true;
            end
            completed=false;
            
        else
            running_stat_file = get_job_stat_file_(this,job.job_id,this.run_tag_);
            if exist(running_stat_file ,'file')==2
                job.waiting_count = 0;
                job.job_status_file = running_stat_file;
                job.is_starting = false;
                job.is_running = true;
                completed=false;
            else % check job have finished successfully and very quickly
                completed_stat_file = get_job_stat_file_(this,job.job_id,this.end_tag_);
                if exist(completed_stat_file,'file')==2
                    job.is_starting = false;
                    job.is_running = false;
                    delete(completed_stat_file);
                else % job have quickly failed
                    job.faliled = true;
                    completed=false;
                end
            end
        end
    end
    %
    this.running_jobs_{id}=job;
end
