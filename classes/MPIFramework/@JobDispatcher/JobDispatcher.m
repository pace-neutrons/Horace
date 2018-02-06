classdef JobDispatcher < MessagesFramework
    % Simple multiple Matlab sessions spawner, spawning worker jobs.
    %
    % Similar to parfor bud does not need parallel toolbox and starts
    % separate Matlab sessions to do the job
    %
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    % $Revision$ ($Date$)
    %
    %
    properties(Dependent)
        % method returns a qualified name of a program to run (e.g. Matlab
        % with all attributes necessary to start it (e.g. path if the program
        % is not on the path)
        worker_prog_string;
        % the name of a service file, which indicates that job is running
        running_job_file_name;
        starting_job_file_name;
        % time to wait for job not changing its state until assuming the
        % job have failed
        time_to_fail;
        % how often (in second) job dispatcher should query the job status
        jobs_check_time;
        % fail limit -- number of times to try action until deciding the
        fail_limit     % action have failed
    end
    %
    properties(Access=protected)
        running_jobs_=[];
        time_to_fail_    = 400 %sec
        jobs_check_time_ = 4;
        fail_limit_ = 100; % number of times to try for changes in job status file until
        % decided the job have failed
        %
    end
    
    methods
        function jd = JobDispatcher(varargin)
            % Initialize job dispatcher
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to distinguish
            % this job control files from any other job control files
            %Example
            % jd = JobDispatcher() -- use randomly generated job control
            % preffix
            % jd = JobDispatcher('target_file_name') -- add prefix
            %      which distinguish this job as the job which will produce
            %      the file with the name provided
            %
            % Initialise folder path
            jd = jd@MessagesFramework(varargin{:});
        end
        %
        function [n_failed,outputs,job_ids,this]=send_jobs(this,...
                job_class_name,job_param_list,number_of_workers,varargin)
            % send range of jobs to execute by external program
            %
            % Usage:
            % n_failed=send_jobs(this,job_class_name,job_param_list,[number_of_workers,[job_query_time]])
            %Where:
            % job_class_name -- name of the class, which has method do_job
            %                   and will process jobs on a separate worker
            % job_param_list -- cellarray of structures containing the
            %                   parameters of the jobs to run
            % number_of_workers -- number of Matlab sessions to
            %                   start to deal with the jobs.
            %
            % Optional:
            % job_query_time -- if present -- time interval to check if
            %                   jobs are completed. By default, check every
            %                   4 seconds
            %
            % Returns
            % n_failed  -- number of jobs that have failed.
            % outputs   -- cellarray of outputs from each job.
            %              Empty if jobs do not return anything
            % job_ids   -- cellarray containing relation between job_id (job
            %              number) and job parameters from
            %              job_param_list, assigned to this job
            %
            [n_failed,outputs,job_ids,this]=send_jobs_to_workers_(this,...
                job_class_name,job_param_list,number_of_workers,varargin{:});
        end
        %
        function ok = job_state_is(this,job_id,state)
            % method checks if job state is as requested
            % the list of supported states now is:
            % 'starting', 'running', 'finished' etc...
            ok = this.check_message(job_id,state);
        end
        %
        function prog_name = get.worker_prog_string(this)
            % get fully qualified program name to start job with
            %
            % Here we expect to start Matlab
            % Fully qualified means name with full path, which allows to
            % start program which is not on system path.
            %
            prog_path  = find_matlab_path();
            if isempty(prog_path)
                error('JOB_DISPATCHER:invlid_settings','Can not find matlab');
            end
            if ispc
                prog_name = fullfile(prog_path,'matlab.exe');
            else
                prog_name = fullfile(prog_path,'matlab');
            end
            %prog_name = 'c:\\Programming\\Matlab2015b64\\bin\\matlab.exe';
        end
        %
        function limit = get.fail_limit(this)
            limit  = this.fail_limit_;
        end
        %
        function time = get.jobs_check_time(this)
            time = this.jobs_check_time_;
        end
        %
        function this = set.jobs_check_time(this,val)
            if val<=0
                error('JOB_DISPATCHER:jobs_check_time','time to check jobs has to be positive');
            end
            this.jobs_check_time_ =val;
            this.fail_limit_ = ceil(this.time_to_fail/val);
            if this.fail_limit_ < 2
                this.fail_limit_ = 2;
            end
            
        end
        %
        function time = get.time_to_fail(this)
            time = this.time_to_fail_;
        end
        %
        function this = set.time_to_fail(this,val)
            if val<0
                error('JOB_DISPATCHER:set_time_to_fail','time to fail can not be negative');
            end
            this.time_to_fail_ =val;
            this.fail_limit_ = ceil(val/this.jobs_check_time);
            if this.fail_limit_ < 2
                this.fail_limit_ = 2;
            end
        end
        % this method should be used for test purposes only.
        function [this,job_ids,worker_controls]=split_and_register_jobs(this,job_param_list,n_workers)
            % given list of job parameters, divide jobs between workers, initialize
            % workers and register job info in the class for further job control
            [this,job_ids,worker_controls]=this.split_and_register_jobs_(job_param_list,n_workers);
        end
    end
    methods(Access=protected)
        
        function [completed,n_failed,all_changed,this]= check_jobs_status(this)
            % an algorithm tries to identify jobs state on basis of their
            % outputs and behaviour
            [completed,n_failed,all_changed,this]= check_jobs_status_(this);
        end
        function info = init_worker(this,job_id,arguments)
            % initialise a worker's info on the job dispatcher side
            %
            % Input:
            % job_id    -- the identifier of the job to start
            % arguments -- structure, containing job specific arguments
            % Output:
            % info      -- serialized string, used to initialize worker
            [info,ok,err_mess] = this.init_worker_(job_id,arguments);
            if ~ok
                error('JOB_DISPATCHER:init_workser',...
                    'Can not send message requesting start worker %d, Error %s',...
                    job_id,err_mess)
            end
        end
    end
    
end

