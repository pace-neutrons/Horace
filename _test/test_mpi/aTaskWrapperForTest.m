classdef aTaskWrapperForTest < iTaskWrapper
    % Test helper to verify taskController

    
    properties
        running = false;
        failed = false;
    end
    
    methods
        function obj = aTaskWrapperForTest(varargin)
        end
        % abstract method to start generic MPI task
        function obj = start_task(obj,job_param)
            obj.running  = true;
        end
        % abstract method to stop generic MPI task
        function obj = stop_task(obj)
            obj.running  = false;
        end
        % abstract method to check if a task is running generic MPI task
        function  [ok,failed,mess] = is_running(obj)
            ok = obj.running;
            failed = obj.failed;
            if failed
                mess = 'job failed as property set to failed';
            else
                mess  = '';
            end
        end
    end
end

