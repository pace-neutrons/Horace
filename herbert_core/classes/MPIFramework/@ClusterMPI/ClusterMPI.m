classdef ClusterMPI < ClusterWrapper
    % The class to support cluster of Matlab workers, communicating over
    % MPI interface started by by mpiexec.
    %
    %----------------------------------------------------------------------
    properties(Access = protected)

        % the string containing Java handle to running mpiexec process
        mpiexec_handle_ = [];

    end
    properties(Access = private)
        % the folder, containing mpiexec cluster configurations (host files)
        config_folder_
    end

    methods
        function obj = ClusterMPI(n_workers,mess_exchange_framework)
            % Constructor, which initiates MPI wrapper
            %
            % The wrapper provides common interface to run various kinds of
            % Herbert parallel jobs, communication over mpi (mpich)
            %
            % Empty constructor generates wrapper, which has to be
            % initiated by init method.
            %
            % Non-empty constructor calls the init method itself
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            %
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            %
            % log_level    if present, defines the verbosity of the
            %              operations over the framework
            obj = obj@ClusterWrapper();
            obj.starting_info_message_ = ...
                '**** mpiexec MPI job configured,  Starting MPI job  with %d workers ****\n';
            obj.started_info_message_  = ...
                '**** mpiexec MPI job submitted                                     ****\n';

            % The default name of the messages framework, used for communications
            % between the nodes of the parallel job
            obj.pool_exchange_frmwk_name_ ='MessagesCppMPI';
            obj.cluster_config_ = 'local';
            % define config folder containing cluster configurations
            root = fileparts(which('herbert_init'));
            obj.config_folder_ = fullfile(root,'admin','mpi_cluster_configs');
            obj.starting_cluster_name_ = class(obj);

            if nargin < 2
                return;
            end

            if ~exist('log_level', 'var')
                log_level = -1;
            end

            obj = obj.init(n_workers,mess_exchange_framework,log_level);
        end

        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
            % The method to initiate the cluster wrapper and start running
            % the cluster job by executing mpiexec with appropriate
            % parameters. When cluster is initialized internally, it will
            % report cluster_ready (writes appropriate message file) to the
            % host process.
            %
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            %log_level     if present, the number, which describe the
            %              verbosity of the cluster operations output;
            if ~exist('log_level', 'var')
                log_level = -1;
            end
            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);

            mpiexec = obj.get_mpiexec();
            mpiexec_str = {mpiexec,'-n',num2str(n_workers)};

            % build generic worker init string without lab parameters
            wcs = obj.mess_exchange_.get_worker_init(obj.pool_exchange_frmwk_name);
            [obj, obj.mpiexec_handle_] = obj.start_workers(wcs, mpiexec_str);

            % check if job control API reported failure
            obj.check_failed();

        end

        function obj=finalize_all(obj)
            obj = finalize_all@ClusterWrapper(obj);
            if ~isempty(obj.mpiexec_handle_)
                obj.mpiexec_handle_.destroy();
                obj.mpiexec_handle_ = [];
            end
        end

        function config = get_cluster_configs_available(obj)
            % The function returns the list of the availible clusters
            % to run using correspondent parallel framework.
            %
            % The clusters defined by the list of the available host files.
            %
            % The first configuration in the available clusters list would
            % be the default configuration.
            %
            config = find_and_return_host_files_(obj);
        end

        function check_availability(obj)
            % verify the availability of the compiled Herbert MPI
            % communicaton library and the possibility to use the MPI cluster
            % to run parallel jobs.
            %
            % Should throw HERBERT:ClusterWrapper:not_available exception
            % if the particular framework is not avalable.
            %
            check_availability@ClusterWrapper(obj);
            check_mpi_mpiexec_can_be_enabled_(obj);
        end

        function is = is_job_initiated(obj)
            % returns true, if the cluster wrapper is mpiexec job
            is = ~isempty(obj.mpiexec_handle_);
        end
    end

    %------------------------------------------------------------------

    methods(Access = protected)
        function [running,failed,paused,mess] = get_state_from_job_control(obj)
            % check if java process is still running or has been completed
            %
            % inputs:
            paused = false;
            task_handle = obj.mpiexec_handle_;
            [running,failed,mess] = obj.is_java_process_running(task_handle);
            if failed
                mess = FailedMessage(mess);
            elseif ~running
                mess = CompletedMessage(mess);
            end
        end
    end

end
