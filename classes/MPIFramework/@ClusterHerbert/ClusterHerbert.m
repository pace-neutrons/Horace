classdef ClusterHerbert < ClusterWrapper
    % The class to support Herbert Poor man MPI i.e. the cluster
    %
    % of Matlab workers, controlled by Java
    % runtime, and exchanging filebased messages.
    %
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    %----------------------------------------------------------------------
    properties(Access = protected)
        
        cluster_prev_state_ =[];
        cluster_cur_state_ = [];
        
        
        matlab_starter_  = [];
        tasks_handles_ = {};
        %
        % running process Java exception message contents
        running_mess_contents_= 'process has not exited';
    end
    properties(Access = private)
        task_common_str_ = {'-nosplash','-nodesktop','-r'};
        %
        DEBUG_REMOTE = false;
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
                '*** Herbert cluster started                                ***\n';
            %
            obj.pool_exchange_frmwk_name_ ='MessagesFilebased';
            if nargin < 2
                return;
            end
            if ~exist('log_level','var')
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
            if ~exist('log_level','var')
                log_level = -1;
            end
            
            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);
            %
            pc = parallel_config();
            obj.worker_name_ = pc.worker;
            obj.is_compiled_script_ = pc.is_compiled;
            %
            obj.tasks_handles_  = cell(1,n_workers);
            %
            prog_path  = find_matlab_path();
            if isempty(prog_path)
                error('CLUSTER_HERBERT:runtime_error','Can not find Matlab');
            end
            
            if ispc()
                obj.running_mess_contents_= 'process has not exited';
                obj.matlab_starter_ = fullfile(prog_path,'matlab.exe');
            else
                obj.running_mess_contents_= 'process hasn''t exited';
                obj.matlab_starter_= fullfile(prog_path,'matlab');
                obj.task_common_str_ = {'-softwareopengl',obj.task_common_str_{:}};
            end
            
            intecomm_name = obj.pool_exchange_frmwk_name_;
            for task_id=1:n_workers
                cs = obj.mess_exchange_.get_worker_init(intecomm_name ,task_id,n_workers);
                worker_init = sprintf('%s(''%s'');exit;',obj.worker_name_,cs);
                if obj.DEBUG_REMOTE
                    % if debugging client
                    log_file = sprintf('output_jobN%d.log',task_id);
                    task_info = [{obj.matlab_starter_ },obj.task_common_str_(1:end-1),...
                        {'-logfile'},{log_file },{'-r'},{worker_init}];
                else
                    task_info = [{obj.matlab_starter_},obj.task_common_str_(1:end),...
                        {worker_init}];
                end
                
                runtime = java.lang.ProcessBuilder(task_info);
                obj.tasks_handles_{task_id} = runtime.start();
                [ok,failed,mess] = obj.is_running(obj.tasks_handles_{task_id});
                if ~ok && failed
                    error('CLUSTER_HERBERT:runtime_error',...
                        ' Can not start worker N%d#%d, Error: %s',...
                        task_id,n_workers,mess);
                end
            end
            if log_level > -1
                fprintf(obj.started_info_message_);
            end
            
        end
        %        
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
        %------------------------------------------------------------------
    end
    methods(Access = protected)
        function [ok,failed,mess] = is_running(obj,task_handle)
            % check if java process is still running or has been completed
            %
            % inputs:
            if isempty(task_handle)
                ok      = false;
                failed  = true;
                mess = 'process has not been started';
                return;
            end
            
            mess = '';
            try
                term = task_handle.exitValue();
                if ispc() % windows does not hold correct process for Matlab
                    ok = true;
                else
                    ok = false; % unix does
                end
                if term == 0
                    failed = false;
                    ok = true;
                else
                    failed = true;
                    mess = fprintf('Startup error with ID: %d',term);
                end
            catch Err
                if strcmp(Err.identifier,'MATLAB:Java:GenericException')
                    part = strfind(Err.message, obj.running_mess_contents_);
                    if isempty(part)
                        mess = Err.message;
                        failed = true;
                        ok   = false;
                    else
                        ok = true;
                        failed = false;
                    end
                else
                    rethrow(Err);
                end
            end
        end
        
    end
end

