classdef ClusterHerbert < ClusterWrapper
    % The class to support cluster of Matlab workers, controlled by Java
    % runtime
    %
    %
    % $Revision$ ($Date$)
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
    properties(Constant,Access = private)
        task_common_str_ = {'-nosplash','-nodesktop','-r'};
        DEBUG_REMOTE = false;
        % the name of the function to run a remote job. The function must be 
        % on the Matlab data search path before Horace is initialized.
        worker_name_ = 'worker_v1';
    end
    
    methods
        function obj = ClusterHerbert(n_workers,mess_exchange_framework)
            % Constructor, which initiates wrapper
            %
            obj = obj@ClusterWrapper(n_workers,mess_exchange_framework);
            
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
            end
            
            for i=1:n_workers
                cs = obj.mess_exchange_.gen_worker_init(i,n_workers);
                worker_init = sprintf('%s(''%s'');exit;',obj.worker_name_,cs);
                if obj.DEBUG_REMOTE
                    % if debugging client
                    log_file = sprintf('output_jobN%d.log',task_id);
                    task_info = [{obj.matlab_starter_ },obj.task_common_str_(1:end),...
                        {'-logfile'},{log_file },{'-r'},{worker_init}];
                else
                    task_info = [{obj.matlab_starter_},obj.task_common_str_(1:end),...
                        {worker_init}];
                end
                
                runtime = java.lang.ProcessBuilder(task_info);
                obj.tasks_handles_{i} = runtime.start();
                [ok,failed,mess] = obj.is_running(obj.tasks_handles_{i});
                if ~ok && failed
                    error('CLUSTER_HERBERT:runtime_error',...
                        ' Can not start worker N%d#%d, Error: %s',...
                        i,n_workers,mess);
                end
                
            end
            
            
        end
        %
        function obj = start_job(obj,je_init_message,task_init_mess,log_message_prefix)
            %
            obj = obj.init_workers(je_init_message,task_init_mess,log_message_prefix);
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

