classdef ClusterHerbert < ClusterWrapper
    % The class to support Herbert Poor man MPI i.e. the cluster
    %
    % of Matlab workers, controlled by Java
    % runtime, and exchanging filebased messages.
    %
    %----------------------------------------------------------------------
    properties(Access = protected)
        tasks_handles_ = {};
    end

    properties(Access = private)
        task_common_str_ = {'-nosplash','-nodesktop','-r'};
    end

    methods
        function obj = ClusterHerbert(n_workers,mess_exchange_framework,log_level)
            % Constructor, which initiates wrapper around Herbert Poor man
            % MPI framework.
            %
            % The wrapper provides common interface to run various kind of
            % Herbert parallel jobs.
            %
            % Empty constructor generates wrapper, which has to be
            % initiated by init method.
            %
            % Non-empty constructor calls the init method itself
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            % log_level    if present, defines the verbosity of the
            %              operations over the framework
            obj = obj@ClusterWrapper();
            obj.starting_info_message_ = ...
                ':herbert configured: *** Starting Herbert (poor-man-MPI) cluster with %d workers ***\n';
            obj.started_info_message_  = ...
                '*** Herbert cluster initialized                              ***\n';
            % The default name of the messages framework, used for communications
            % between the nodes of the parallel job
            obj.pool_exchange_frmwk_name_ ='MessagesFilebased';
            obj.cluster_config_ = 'local';
            obj.starting_cluster_name_ = class(obj);
            if nargin < 2
                return;
            end
            if ~exist('log_level', 'var')
                log_level = -1;
            end
            obj = init(obj,n_workers,mess_exchange_framework,log_level);
        end

        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
            % The method to initate the cluster wrapper
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            %log_level     if present, the number, which describe the
            %              verbosity of the cluster operations outpt;
            if ~exist('log_level', 'var')
                log_level = -1;
            end

            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);
            %
            %
            if ~ispc()
                obj.task_common_str_ = [{'-softwareopengl'},obj.task_common_str_{:}];
            end
            obj.tasks_handles_  = cell(1,n_workers);

            intecomm_name = obj.pool_exchange_frmwk_name_;
            for task_id=1:n_workers
                cs = obj.mess_exchange_.get_worker_init(intecomm_name ,task_id,n_workers);

                if obj.DEBUG_REMOTE
                    % if debugging client
                    log_file = sprintf('output_job_logfileN%d.log',task_id);
                    log_str = [{'-logfile'},{log_file}];
                else
                    log_str = {};
                end

                [obj, obj.tasks_handles_{task_id}] = obj.start_workers(n_workers, cs, {}, log_str);

                [ok,failed,mess] = obj.is_java_process_running(obj.tasks_handles_{task_id});
                if ~ok && failed
                    error('HERBERT:ClusterHerbert:system_error',...
                        ' Can not start worker N%d#%d, Error: %s',...
                        task_id,n_workers,mess);
                end
            end
            % check if job control API reported failure
            obj.check_failed();
        end

        function obj=finalize_all(obj)
            obj = finalize_all@ClusterWrapper(obj);
            if ~isempty(obj.tasks_handles_)
                for i=1:obj.n_workers
                    obj.tasks_handles_{i}.destroy()
                    obj.tasks_handles_{i} = [];
                end
                obj.tasks_handles_ = {};
            end

        end

        function is = is_job_initiated(obj)
            % returns true, if the cluster wrapper is running bunch of
            % parallel java processes
            is = ~isempty(obj.tasks_handles_);
        end
    end

    %------------------------------------------------------------------

    methods(Access = protected)
        function [running,failed,paused,mess] = get_state_from_job_control(obj)
            % Method checks if java framework is running
            %
            paused = false;
            mess = 'running';
            res_mess = cell(1,numel(obj.tasks_handles_));
            is_failed = false(1,numel(obj.tasks_handles_));
            is_running = true(1,numel(obj.tasks_handles_));
            n_fail = 0;

            for i=1:numel(obj.tasks_handles_)
                [running,failed,mess] = is_java_process_running(obj,obj.tasks_handles_{i});
                if failed
                    n_fail = n_fail +1;
                    res_mess{i} = sprintf('Process %d failed with Error: %s',...
                        i,mess);
                    is_failed(i) = true;
                else
                    is_running(i) = running;
                end
            end

            running = any(is_running);
            failed = any(is_failed);

            if failed
                mess_text = strjoin(res_mess(is_failed),';\n');
                mess = FailedMessage(mess_text);
            else
                if ~running
                    mess = CompletedMessage(mess);
                end
            end
        end

    end
end
