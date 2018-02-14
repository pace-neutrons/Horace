classdef JavaTaskWrapper
    % wrapper to control java -controlled worker
    % Herber framework
    
    
    properties(Access=private)
        test_contents_
        task_handle_ = [];
    end
    
    methods
        function obj = JavaTaskWrapper(varargin)
            if ispc
                obj.test_contents_= 'process has not exited';
            else
                obj.test_contents_= 'process hasn''t exited';
            end
            
        end
        function obj = start_job(obj,job_param)
            runtime = java.lang.ProcessBuilder(job_param);
            obj.task_handle_ = runtime.start();
        end
        %
        function obj = stop_job(obj)
            obj.task_handle_.destroy();
            obj.task_handle_ = [];
        end
        
        
        function [ok,failed,mess] = is_running(obj)
            % check if java process is still running or has been completed
            %
            % inputs:
            if isemtpy(obj.task_handle_)
                ok      = false;
                failed  = true;
                mess = 'process has not been started';
                return;
            end
            
            mess = '';
            try
                term = obj.task_handle_.exitValue();
                ok = false;
                if term == 0
                    failed = false;
                else
                    failed = true;
                    mess = fprintf('Startup error with ID: %d',term);
                end
            catch Err
                if strcmp(Err.identifier,'MATLAB:Java:GenericException')
                    part = strfind(Err.message, obj.test_contents_);
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

