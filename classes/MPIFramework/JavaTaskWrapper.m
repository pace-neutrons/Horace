classdef JavaTaskWrapper < iTaskWrapper
    % wrapper to control java - controlled worker
    % Herber framework
    
    
    properties(Access=private)
        mess_contents_
        task_handle_ = [];
        is_pc_;
    end
    
    methods
        function obj = JavaTaskWrapper(varargin)
            obj.is_pc_ = ispc;
            if obj.is_pc_
                obj.mess_contents_= 'process has not exited';
            else
                obj.mess_contents_= 'process hasn''t exited';
            end
            
        end
        %
        function obj = start_task(obj,job_param)
            runtime = java.lang.ProcessBuilder(job_param);
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

