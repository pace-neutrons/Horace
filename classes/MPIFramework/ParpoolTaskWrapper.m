classdef ParpoolTaskWrapper < iTaskWrapper
    % wrapper to control java - controlled worker
    % Herber framework
    
    properties(Access=private)
        mess_contents_
        task_handle_ = [];
        is_pc_;
        prog_start_
    end
    properties(Constant,Access=private)
        task_common_str_ = {'-nosplash','-nojvm','-r'};
    end
    methods(Static)
        
    end
    
    methods
        function obj = ParpoolTaskWrapper(varargin)
            prog_path  = find_matlab_path();            
            if isempty(prog_path)
                error('JOB_DISPATCHER:invlid_settings','Can not find matlab');
            end
            %prog_name = 'c:\\Programming\\Matlab2015b64\\bin\\matlab.exe';
            
            obj.is_pc_ = ispc;
            if obj.is_pc_
                obj.mess_contents_= 'process has not exited';
                obj.prog_start_ = fullfile(prog_path,'matlab.exe');                
            else
                obj.prog_start_= fullfile(prog_path,'matlab');                
                obj.mess_contents_= 'process hasn''t exited';
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
            
            worker_init_info = mpi.build_control(task_id);
            worker_str = sprintf('worker(''%s'',''%s'');exit;',task_class_name,worker_init_info);
            
            if DEBUG_REMOTE
                % if debugging client
                log_file = sprintf('output_jobN%d.log',task_id);
                task_info = [{obj.prog_start_},obj.task_common_str_(1:end),{'-logfile'},{log_file },{'-r'},{worker_str}];
            else
                task_info = [{obj.prog_start_},obj.task_common_str_(1:end),{worker_str}];
            end
            
            mess = aMessage('starting');
            mess.payload = task_inputs;
            mpi.send_message(task_id,mess);
            
            runtime = java.lang.ProcessBuilder(task_info);
            obj.task_handle_ = runtime.start();
            
        end
        %
        function obj = stop_task(obj)
            obj.task_handle_.destroy();
            obj.task_handle_ = [];
        end
        
        
        function [ok,failed,mess] = is_running(obj)
            % check if java process is still running or has been completed
            %
            % inputs:
            if isempty(obj.task_handle_)
                ok      = false;
                failed  = true;
                mess = 'process has not been started';
                return;
            end
            
            mess = '';
            try
                term = obj.task_handle_.exitValue();
                if obj.is_pc_ % windows does not hold correct process for Matlab
                    ok = true;
                else
                    ok = false; % unix does
                end
                if term == 0
                    failed = false;
                else
                    failed = true;
                    mess = fprintf('Startup error with ID: %d',term);
                end
            catch Err
                if strcmp(Err.identifier,'MATLAB:Java:GenericException')
                    part = strfind(Err.message, obj.mess_contents_);
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

