classdef JDTester < JobDispatcher
    % Class used to test job dispatcher functionality
    
    properties(Dependent)
        job_control_structure
    end
    
    methods
        function jd = JDTester(varargin)
            jd = jd@JobDispatcher(varargin{:});
        end
        function [completed,n_failed,all_changed,this]= check_tasks_status_pub(this)
            [completed,n_failed,all_changed,this]= this.check_tasks_status;
        end
        %function info = init_worker_pub(this,job_id,arguments)
        %    info  = this.init_worker(job_id,arguments);
        %end
        function struc = get.job_control_structure(obj)
            struc  = obj.running_jobs_;
        end
        function ok = job_state_is(obj,task_id,state)
            mess_names = obj.mess_framework.probe_all(task_id);
            if ismember(state,mess_names)
                ok = true;
            else
                ok = false;
            end
        end
    end
    
end

