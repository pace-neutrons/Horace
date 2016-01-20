function [completed,n_failed,output_exists,this]= check_jobs_completed_(this,count)
% Verifies a state of running jobs checking the presence of special files,
% identifying the job's state
%
% input jobs all come starting, change to running state and should
% successfully end not starting and not running
%
n_jobs = numel(this.running_jobs_);
n_failed = n_jobs;
completed=true;
output_exists =false;
for id=1:n_jobs
    if isempty(this.running_jobs_{id})
        continue;
    end
    job = this.running_jobs_{id};
    if job.failed
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
                    job.failed  = true;
                end
            else
                job.is_running=false;
                [result,is_failed] = analyze_output(completed_stat_file);
                if is_failed
                    job.failed=true;
                else
                    job.job_results = result;
                end
                if ~isempty(result)
                    output_exists= true;
                end
                
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
                job.failed  = true;
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
                    [result,is_failed] = analyze_output(completed_stat_file);
                    if is_failed
                        job.failed=true;
                    else
                        job.job_results = result;
                    end
                    if ~isempty(result)
                        output_exists= true;
                    end
                else % job have quickly failed
                    job.failed = true;
                    completed=false;
                end
            end
        end
    end
    %
    this.running_jobs_{id}=job;
end
end
%------------------------------------------------
function [result,is_failed] = analyze_output(output_file)
% read file, indicating the job completeon and analyze its contents
% Judge if the file contains any useful information and return this
% information if availible
%
is_failed = false;
f = fopen(output_file);
if f<0
    result = ['Can not open existing result file: ',output_file];
    is_failed = true;
    return
end
    function finalize(fname,fh)
        fclose(fh);
        delete(fname);
    end

clo = onCleanup(@()finalize(output_file,f));
result = [];

% Analyse content
[cont,nsymbols] = fread(f,'uint8');
if nsymbols>=numel('completed')
    status = char(cont(1:numel('completed')));
    if strcmp(status','completed') % no output from the job
        is_failed = false;
        return;
    end
end

if nsymbols>=numel('failed')
    status = char(cont(1:numel('failed')));
    if strcmp(status','failed') % output may indicate the reason for failure
        is_failed = true;
        result = char(cont);
        return;
    end
end
try
    result  = hlp_deserialize(cont);
catch ME
    is_failed = true;
    result = ['failed: Can not convert result from binary format. Reason: ',ME.message];
end
end