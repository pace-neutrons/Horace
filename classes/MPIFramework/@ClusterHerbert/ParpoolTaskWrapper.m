classdef ParpoolTaskWrapper < iTaskWrapper
    % wrapper to control java - controlled worker
    % Herber framework
    
    properties(Access=private)
        mess_contents_
        task_handle_ = [];
        is_pc_;
        
        pool_ = [];
    end
    properties(Constant,Access=private)
    end
    methods(Static)
        
    end
    
    methods
        function obj = ParpoolTaskWrapper(varargin)
%             pool = parallel.Pool;
%             if 
            obj.pool_ = gcp();
            if isempty(obj.pool_)
                error('PARPOOL_TASK_WRAPPER:runtime_error',...
                    'Can not access current parallel pool');
            end
        end
        
        %
        function obj = start_task(obj,mpi,task_class_name,task_id,task_inputs,varargin)
            if nargin>5
                if varargin{1}
                    DEBUG_REMOTE = true;
                else
                    DEBUG_REMOTE = false;
                end
            else
                DEBUG_REMOTE = false;
            end
            
            worker_init_info = mpi.build_control(task_id,false);
            %worker_str = sprintf('worker(''%s'',''%s'');exit;',task_class_name,worker_init_info);
            task_info  = {task_class_name,worker_init_info};
            
            if DEBUG_REMOTE
                % if debugging client
                log_file = sprintf('output_jobN%d.log',task_id);
                task_info = [task_info(:),{'-logfile'},{log_file }];
            end
            mess = aMessage('starting');
            mess.payload = task_inputs;
            mpi.send_message(task_id,mess);
            
            obj.task_handle_ = parfeval(obj.pool_,@worker,1,task_info{:});
            
        end
        %
        function obj = stop_task(obj)
            obj.task_handle_.cancel();
            obj.task_handle_ = [];
        end
        
        
        function [ok,failed,mess] = is_running(obj)
            % check if a process is still running or has been completed
            %
            % inputs:
            if isempty(obj.task_handle_)
                ok      = false;
                failed  = true;
                mess = 'process has not been started';
                return;
            end
            mess = '';
            state = obj.task_handle_.State;
            fail_state = obj.task_handle_.Error;
            switch state
                case 'running'
                    ok = true;
                case 'finished'
                    ok = false;
                case 'queued'
                    ok = true;
                otherwise
                    ok = false;
            end
            if isempty(fail_state)
                failed = false;
            else
                mess = fail_state.message;
                failed = true;
            end
        end
    end
end

