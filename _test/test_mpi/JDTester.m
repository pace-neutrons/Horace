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
%         function [this,n_workers,task_par_ind]=split_tasks(this,task_param_list,n_workers)
%             [nw,taks_ind] = split_tasks@JobDispatcher(task_param_list,n_workers);
%             
%             mpi = 
%             worker_info = mpi.build_control(1);
%             mess = aMessage('starting');
%             mess.payload = job_param_list;
%             mpi.send_message(1,mess);
% 
%         end
    end
    
end

