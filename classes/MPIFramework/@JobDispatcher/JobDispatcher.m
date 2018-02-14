classdef JobDispatcher
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
        % time to wait for job not changing its state until assuming the
        % job have failed
        time_to_fail;
        % how often (in second) job dispatcher should query the task status
        task_check_time;
        % fail limit -- number of times to try action until deciding the
        fail_limit     % action have failed
    end
    %
    properties(Access=protected)
        tasks_list_={};
        time_to_fail_    = 400 %sec
        task_check_time_ = 4;
        fail_limit_ = 100; % number of times to try for changes in job status file until
        % decided the job have failed
        %
        % The framework to exchange messages with the tasks
        mess_framework_;
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
            % Initialise messages framework
            jd.mess_framework_ = FilebasedMessages(varargin{:});
            if nargin == 0 % initialize framework with default job id.
                jd.mess_framework_  = jd.mess_framework_.init_famework(jd.job_id);
            end
        end
        %
        function [n_failed,outputs,task_ids,this]=send_tasks(this,...
                job_class_name,task_param_list,number_of_workers,varargin)
            % send range of jobs to execute by external program
            %
            % Usage:
            % n_failed=send_tasks(this,job_class_name,tasl_param_list,[number_of_workers,[job_query_time]])
            %Where:
            % job_class_name -- name of the class, which has method do_job
            %                   and will process task on a separate worker
            % task_param_list -- cellarray of structures containing the
            %                   parameters of the tasks to run
            % number_of_workers -- number of Matlab sessions to
            %                   start to deal with the tasks.
            %
            % Optional:
            % task_query_time -- if present -- time interval to check if
            %                    taks are completed. By default, check every
            %                    4 seconds
            %
            % Returns
            % n_failed  -- number of taks that have failed.
            % outputs   -- cellarray of outputs from each task.
            %              Empty if tasks do not return anything
            % task_ids   -- cellarray containing relation between task_id
            %              (task number) and task parameters from
            %               tasks_param_list, assigned to this tak
            %
            [n_failed,outputs,task_ids,this]=send_tasks_to_workers_(this,...
                job_class_name,task_param_list,number_of_workers,varargin{:});
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
        function time = get.task_check_time(this)
            time = this.task_check_time_;
        end
        %
        function this = set.task_check_time(this,val)
            if val<=0
                error('JOB_DISPATCHER:jobs_check_time','time to check jobs has to be positive');
            end
            this.task_check_time_ =val;
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
            this.fail_limit_ = ceil(val/this.tasks_check_time);
            if this.fail_limit_ < 2
                this.fail_limit_ = 2;
            end
        end
        function [n_workers,task_par_ind]=split_tasks(this,task_param_list,n_workers)
            % divide list of job parameters among given number of workers
            %
            %Inputs:
            %job_param_list -- cellarray of classes or structures, containing task parameters.
            %n_workers      -- number of workers to split job between workers
            %
            % returns: cell array of indexes from job_param_list dedicated to run on a
            % worker.
            [n_workers,task_par_ind]=this.split_tasks_(task_param_list,n_workers);
        end
    end
    methods(Access=protected)
        function [completed,n_failed,all_changed,this]= check_tasks_status(this)
            % an algorithm tries to identify tasks state on basis of their
            % outputs and behaviour
            [completed,n_failed,all_changed,this]= check_tasks_status_(this);
        end
        function info = init_worker(this,task_id,arguments)
            % initialise a worker's info on the jobDispatcher side
            % and send message to a worker
            %
            % Input:
            % task_id   -- the identifier of the task to start
            % arguments -- structure, containing task specific arguments
            %              for jobExecuter.do_job inputs
            % Output:
            % info      -- serialized string, used to initialize worker
            [info,ok,err_mess] = this.init_worker_(task_id,arguments);
            if ok ~= MES_CODES.ok
                error('JOB_DISPATCHER:init_workser',...
                    'Can not send message requesting start worker %d, Error %s',...
                    task_id,err_mess)
            end
        end
    end
    
end

