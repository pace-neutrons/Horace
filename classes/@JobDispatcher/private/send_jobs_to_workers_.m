function n_failed=send_jobs_to_workers_(this,job_param_list,varargin)
% send range of jobs to execute by external program
%
% Usage:
% n_failed=send_jobs(this,job_param_list,[number_of_workers,[job_query_time]])
%Where:
% job_param_list -- cellarray of structures containing the
%                   parameters of the jobs to run
% number_of_workers -- if present, number of matlab sessions to
%                   start to deal with the jobs. By default,
%                   the number of sessions is equal to number
%                   of jobs
% job_query_time    -- if present -- time interval to check if
%                   jobs are completed. By default, check every
%                   8 seconds
%
% Returns
% n_failed  -- number of jobs that have failed.
%
%
% identify number of jobs on the basis of number of parameters
% provided by input structure
n_jobs = numel(job_param_list);
prog_name = this.worker_prog_name;
class_name = class(this);
% if varargin is provided, we should start specified number of
% workers
if nargin <3
    n_workers =n_jobs;
else
    n_workers =varargin{1};
end
if nargin ==4
    waiting_time = varargin{2};
else
    waiting_time =4;
end
step = ceil(n_jobs/n_workers);
if step<1; step =1; end

this.running_jobs_=cell(n_workers,1);


id = 0;
for ic=1:step:n_jobs
    id=id+1;
    
    job_status_f = this.get_job_stat_file_(id,this.start_tag_);
    f = fopen(job_status_f,'w');
    fwrite(f,'starting','char');
    fclose(f);
    this.running_jobs_{id} = JobDispatcher.job_structure(id,job_status_f);
    this.running_jobs_{id}.is_starting = true;
    
    [ars,param_class_name,mess] = this.make_job_par_string(job_param_list{id});
    if ~isempty(mess)
        error('JOB_DISPATCHER:send_jobs','Job N %d; %s',id,mess);
    end
    job_string = sprintf('!%s -nojvm -nosplash -r worker(''%s'',%d,''%s'',''%s''',...
        prog_name,class_name,id,param_class_name,ars);
    for jid = 1:step-1
        idd = ic+jid;
        if idd>n_jobs
            continue;
        end
        % here we assume that all jobs have the same type of job parameters
        [ars,~,mess] = this.make_job_par_string(job_param_list{id});
        if ~isempty(mess)
            error('JOB_DISPATCHER:send_jobs','Job N %d; %s',id,mess);
        end
        
        job_string=[job_string,sprintf(',''%s''',ars)];
    end
    job_string=[job_string,');exit; & exit'];
    eval(job_string);
end

count = 0;
[completed,n_failed,this]=check_jobs_completed_(this,count);
while(~completed)
    pause(waiting_time);
    [completed,n_failed,this]=check_jobs_completed_(this,count);
    count = count+1;
end

