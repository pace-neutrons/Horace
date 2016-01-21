function [n_failed,outputs,this]=send_jobs_to_workers_(this,job_param_list,varargin)
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
%                   4 seconds
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
this.fail_limit_ = ceil(this.time_to_fail/waiting_time);
if this.fail_limit_ <2
    this.fail_limit_ = 2;
end

step = ceil(n_jobs/n_workers);
if step<1; step =1; end

this.running_jobs_=cell(n_workers,1);
par_in_cell = iscell(job_param_list);

% job id
id = 0;
for ic=1:step:n_jobs
    id=id+1;
    
    % create file, indicating job start
    job_status_f = this.get_job_stat_file_(id,this.start_tag_);
    f = fopen(job_status_f,'wb');
    % Store job info for further usage and progress checking
    this.running_jobs_{id} = JobDispatcher.job_structure(id,job_status_f);
    this.running_jobs_{id}.is_starting = true;
    %
    % generate job parameters string:
    if par_in_cell
        [args,mess] = this.make_job_par_string(job_param_list{ic});
    else
        [args,mess] = this.make_job_par_string(job_param_list(ic));
    end
    if ~isempty(mess)
        error('JOB_DISPATCHER:send_jobs','Job N %d; %s',id,mess);
    end
    % combine job parameters string with auxiliary information, necessary
    % for running external matlab session
    if ispc
        job_start = sprintf('!%s -nojvm -nosplash -r worker(''%s'',%d',...
            prog_name,class_name,id);
        job_end=');exit; & exit';
    else
        job_start = sprintf('!%s -nosplash -r "worker(''%s'',%d',...
            prog_name,class_name,id);
        job_end=');exit;" &';
    end
    
    job_par = cell(step,1);
    job_par{1} = args;
    n_symbols = numel(args)+1;
    for jid = 1:step-1
        idd = ic+jid;
        if idd>n_jobs
            continue;
        end
        % here we assume that all jobs have the same type of job parameters
        % so add more parameters to job description, if it is necessary
        if par_in_cell
            [agrs,mess] = this.make_job_par_string(job_param_list{idd});
        else
            [agrs,mess] = this.make_job_par_string(job_param_list(idd));
        end
        if ~isempty(mess)
            error('JOB_DISPATCHER:send_jobs','Job N %d; %s',id,mess);
        end
        
        job_par{idd } = [',',agrs];
        n_symbols = n_symbols +numel(args)+1;
    end
    % finalize job parameters string
    
    if n_symbols  >  8192-numel(job_start)-numel(job_end)
        job_contents = [job_par{:}];
        fwrite(f,job_contents,'char');
        job_contents = sprintf(',''-file'',''%s''',job_status_f);
        job_string = [job_start,job_contents,job_end];
    else
        job_string = sprintf('%s,',job_start);
        for jp=1:numel(job_par)
            if isempty(job_par{jp})
                continue
            end
            job_string = [job_string, sprintf('''%s',strrep(job_par{jp},',',','''))];
        end
        job_string = [job_string, sprintf('''%s',job_end)];
        fwrite(f,'starting','char');
    end
    fclose(f);
    
    %---------------------------------------------------------------------
    % run external job
    eval(job_string);
    %---------------------------------------------------------------------
end
if id<n_workers
    this.running_jobs_=this.running_jobs_(1:id);
    n_workers = id;
end

count = 0;
[completed,n_failed,output_exists,this]=check_jobs_completed_(this,count);
while(~completed)
    if count == 0
        fprintf('**** Waiting for workers to finish their jobs ****\n')
    end
    pause(waiting_time);
    [completed,n_failed,output_exists,this]=check_jobs_completed_(this,count);
    count = count+1;
    fprintf('.')
    if mod(count,50)==0
        fprintf('\n')
    end
end
fprintf('\n')
%--------------------------------------------------------------------------
% retrieve outputs (if any)
if output_exists
    outputs = cell(n_workers,1);
    job_info=this.running_jobs_;
    for ind = 1:n_workers
        if isempty(job_info)
            continue;
        end
        if job_info{ind}.failed
            outputs{ind} = 'failed';
        else
            outputs{ind} = job_info{ind}.job_results;
        end
    end
    empty_outputs = cellfun(@(x)isempty(x),outputs);
    outputs = outputs(~empty_outputs);
else
    outputs = [];
end

