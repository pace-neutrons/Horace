classdef ClusterMPI < ClusterWrapper
    % The class to support cluster of Matlab workers, communicating over
    % MPI interface started by by mpiexec.
    %
    %
    % $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
    %
    %----------------------------------------------------------------------
    properties(Access = protected)
        
        % the string user to launch Matlab
        matlab_starter_  = [];
        % the string containgin Java handle to running mpiexec process
        mpiexec_handle_ = [];
        %
    end
    properties(Access = private)
        %
        DEBUG_REMOTE = false;
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
                ':mpiexec MPI job configured: *** Starting MPI job  with %d workers ***\n';
            obj.started_info_message_  = ...
                '*** mpiexec MPI job started                                ***\n';
            %
            obj.pool_exchange_frmwk_name_ ='MessagesCppMPI';
            % define config folder containing cluster configurations
            root = fileparts(which('herbert_init'));
            obj.config_folder_ = fullfile(root,'admin','mpi_cluster_configs');
            if nargin < 2
                return;
            end
            if ~exist('log_level','var')
                log_level = -1;
            end
            obj = obj.init(n_workers,mess_exchange_framework,log_level);
        end
        %
        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
            % The method to initiate the cluster wrapper and start running
            % the cluster job.
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
            if ~exist('log_level','var')
                log_level = -1;
            end
            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);
            
            pc = parallel_config();
            obj.worker_name_        = pc.worker;
            obj.is_compiled_script_ = pc.is_compiled;
            
            %
            
            %
            prog_path  = find_matlab_path();
            if isempty(prog_path)
                error('CLUSTER_HERBERT:runtime_error','Can not find Matlab');
            end
            
            mpiexec = obj.get_mpiexec();
            if ispc()
                obj.running_mess_contents_= 'process has not exited';
                obj.matlab_starter_ = fullfile(prog_path,'matlab.exe');
            else
                obj.running_mess_contents_= 'process hasn''t exited';
                obj.matlab_starter_= fullfile(prog_path,'matlab');
            end
            mpiexec_str = {mpiexec,'-n',num2str(n_workers)};
            
            % build generic worker init string without lab parameters
            cs = obj.mess_exchange_.get_worker_init(obj.pool_exchange_frmwk_name);
            worker_init = sprintf('%s(''%s'');exit;',obj.worker_name_,cs);
            task_info = [mpiexec_str(:)',{obj.matlab_starter_},...
                {'-batch'},{worker_init}];
            pause(0.1);
            runtime = java.lang.ProcessBuilder(task_info);
            pause(0.1);
            obj.mpiexec_handle_ = runtime.start();
            [ok,failed,mess] = obj.is_running();
            if ~ok && failed
                error('CLUSTER_MPI:runtime_error',...
                    ' Can not start mpiexec with %d workers, Error: %s',...
                    mess);
            end
            
            %
            if log_level > -1
                fprintf(obj.started_info_message_);
            end
        end
        %
        function obj=finalize_all(obj)
            obj = finalize_all@ClusterWrapper(obj);
            if ~isempty(obj.mpiexec_handle_)
                obj.mpiexec_handle_.destroy();
                obj.mpiexec_handle_ = [];
            end
        end
        %
        function [completed, obj] = check_progress(obj,varargin)
            % Check the job progress verifying and receiving all messages,
            % sent from worker N1
            %
            % usage:
            %>> [completed, obj] = check_progress(obj)
            %>> [completed, obj] = check_progress(obj,status_message)
            %
            % The first form checks and receives all messages addressed to
            % job dispatched node where the second form accepts and
            % verifies status message, received by other means
            [ok,failed,mess] = obj.is_running();
            [completed,obj] = check_progress@ClusterWrapper(obj,varargin{:});
            if ~ok
                if ~completed % the java framework reports job finished but
                    % the head node have not received the final messages.
                    completed = true;
                    mess_body = sprintf(...
                        'Framework launcher reports job finished without returning final messages. Reason: %s',...
                        mess);
                    if failed
                        obj.status = FailMessage(mess_body);
                    else
                        c_mess = aMessage('completed');
                        c_mess.payload = mess_body;
                        obj.status = c_mess ;
                    end
                    me = obj.mess_exchange_;
                    me.clear_messages()
                end
            end
        end
        %
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
        
        %
        function check_availability(obj)
            % verify the availability of the compiled Herbert MPI
            % communicaton library and the possibility to use the MPI cluster
            % to run parallel jobs.
            %
            % Should throw PARALLEL_CONFIG:not_avalable exception
            % if the particular framework is not avalable.
            %
            check_availability@ClusterWrapper(obj);
            check_mpi_mpiexec_can_be_enabled_(obj);
        end
        
        %------------------------------------------------------------------
    end
    methods(Static)
        function mpi_exec=get_mpiexec()
            if ispc()
                rootpath = fileparts(which('herbert_init'));
                % only one version of mpiexec is used now. May change in a
                % future.
                mpi_exec = fullfile(rootpath,'DLL','_PCWIN64','MS_MPI_R2019b','mpiexec.exe');
            else
                % try our custom isiscompute arrangement
                mpi_exec = '/usr/local/mpich/bin/mpiexec';
                if ~(exist(mpi_exec,'file')==2)
                    % use system-defined mpiexec
                    [~,mpi_exec] = system('which mpiexec');
                    % strip non-printing characters, spaces and eol/cr-s from the
                    % end of mpiexec string.
                    mpi_exec= regexprep(mpi_exec,'[\x00-\x20\x7F-\xFF]$','');
                end
            end
        end
    end
    methods(Access = protected)
        function [ok,failed,mess] = is_running(obj)
            % check if java process is still running or has been completed
            %
            % inputs:
            task_handle = obj.mpiexec_handle_;
            [ok,failed,mess] = obj.is_java_process_running(task_handle);
        end
        
    end
end


