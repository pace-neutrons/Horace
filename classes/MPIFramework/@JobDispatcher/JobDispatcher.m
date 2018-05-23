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
        % how often (in second) job dispatcher should query the task status
        task_check_time;
        % fail limit -- number of times to try action until deciding the
        fail_limit     % action have failed
        % time interval to wait until job which do not send any messages
        % considered failed
        time_to_fail
        %
        % the framework used to exchange messages with parallel pool
        mess_framework;
        %  Heler property used to retrieve running job id
        job_id
    end
    %
    properties(Access=protected)
        task_check_time_ = 4;
        fail_limit_ = 100; % number of times to try for changes in job status file until
        % decided the job have failed
        %
        % The framework to exchange messages with the tasks
        mess_framework_;
        time_to_fail_  = 300; %300sec, 5 min
    end
    
    methods
        function jd = JobDispatcher(varargin)
            % Initialize job dispatcher
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to distinguish
            % this job control files from any other job control files
            %Example
            % jd = JobDispatcher() -- use randomly generated job control
            % prefix
            % jd = JobDispatcher('target_file_name') -- add prefix
            %      which distinguish this job as the job which will produce
            %      the file with the name provided
            %
            % Initialise messages framework
            mf = MessagesFilebased(varargin{:});
            pc = parallel_config;
            if ~isempty(pc.shared_folder_on_local)
                mf.mess_exchange_folder = pc.shared_folder_on_local;
            end
            jd.mess_framework_  = mf;
        end
        %
        function [outputs,n_failed,task_ids,this]=start_tasks(this,...
                job_class_name,common_params,loop_params,return_results,...
                number_of_workers,keep_workers_running,task_query_time)
            % send range of jobs to execute by external program
            %
            % Usage:
            % [n_failed,outputs,task_ids] = ...
            %     start_tasks(this,job_class_name,common_params,loop_params,...
            %    [number_of_workers,[job_query_time]])
            %Where:
            % job_class_name -- name of the class - child of jobExecutor,
            %                   which will process task on a separate worker
            % common_params  -- a structure, containing the parameters, common
            %                   for any loop iteration
            % loop_params    -- either cellarray of structures, specific
            %                   with each cell specific to a loop iteration
            %                   or the number of iterations to do over
            %                   common_params (which may depend on the
            %                   iteration number)
            % number_of_workers -- number of Matlab sessions to
            %                    process the tasks
            %
            % Optional:
            % task_query_time -- if present -- time interval in seconds to
            %                    check if tasks are completed. By default,
            %                    check every 4 seconds
            %
            % Returns
            % n_failed  -- number of tasks that have failed.
            % outputs   -- cellarray of outputs from each task.
            %              Empty if tasks do not return anything
            % task_ids   -- cellarray containing relation between task_id
            %              (task number) and task parameters from
            %               tasks_param_list, assigned to this task
            %
            if ~exist('task_query_time','var')
                task_query_time = 4;
            end
            [outputs,n_failed,task_ids,this]=send_tasks_to_workers_(this,...
                job_class_name,common_params,loop_params,return_results,...
                number_of_workers,keep_workers_running,task_query_time);
        end
        %
        function [task_id_list,init_mess]=split_tasks(this,common_par,loop_par,n_workers,return_outputs)
            % divide list of job parameters among given number of workers
            % and generate list of init messages for the subtasks
            %
            %Inputs:
            %job_param_list -- cellarray of classes or structures, containing task parameters
            %                  or number of iterations in the parallel
            %                  loop.
            %
            %n_workers      -- number of workers to split job between workers
            %
            % returns: cell array of indexes from job_param_list dedicated to run on a
            % worker.
            [task_id_list,init_mess]=split_tasks_(this,common_par,loop_par,n_workers,return_outputs);
        end        
        %------------------------------------------------------------------
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
                error('JOB_DISPATCHER:invalid_argument',...
                    'time to check jobs has to be positive');
            end
            this.task_check_time_ =val;
            this = reset_fail_limit_(this,this.time_to_fail/val);
            
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
            this = reset_fail_limit_(this,val/this.task_check_time);
        end
        
        function mf = get.mess_framework(obj)
            mf = obj.mess_framework_;
        end
        function id = get.job_id(obj)
            id = obj.mess_framework_.job_id;
        end
    end
end

