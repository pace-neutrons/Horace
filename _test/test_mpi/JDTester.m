classdef JDTester < JobDispatcher
    % Class used to test job dispatcher functionality
    
    properties(Dependent)
        job_control_structure
    end
    
    methods
        function jd = JDTester(varargin)
            jd = jd@JobDispatcher(varargin{:});
        end
        function [this,job_ids,wc]=split_and_register_tasks(this,job_param_list,n_workers)
            [this,job_ids,wc]=split_and_register_tasks@JobDispatcher(this,job_param_list,n_workers);            
        end
        function [completed,n_failed,all_changed,this]= check_jobs_status_pub(this)        
                [completed,n_failed,all_changed,this]= check_jobs_status(this);
        end
        function info = init_worker_pub(this,job_id,arguments)
            info  = this.init_worker(job_id,arguments);
        end
        function struc = get.job_control_structure(obj)
            struc  = obj.running_jobs_;
        end
    end
    
end

