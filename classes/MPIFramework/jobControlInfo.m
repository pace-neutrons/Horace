classdef jobControlInfo
    % Helper class used by JobDispatcher
    % to analyse a running job state
    %
    % Stores running job features and relations between them
    %
    properties(Dependent)
        % job number assigned by JobDispatcher
        job_id
        %
        is_running
        is_starting
        is_failed
        is_finished
        %
        waiting_count
        outputs
        fail_reason
    end
    properties(Access=private)
        % JobDispatcher
        job_id_
        %
        is_running_=false;
        is_starting_=false
        is_failed_=false;
        %
        waiting_count_ = 0
        outputs_       = []
        fail_reason_   = [];
        % time when waiting interval for the job, reporting results have
        % started.
        start_waiting_interval_;
        estimatied_wait_time_;
    end
    
    
    methods
        function obj=jobControlInfo(id)
            obj.job_id_=id;
            if id>0
                obj.is_starting_ = true;
            end
        end
        function id = get.job_id(obj)
            id = obj.job_id_;
        end
        function obj = set_job_id(obj,ind)
            obj.job_id_=ind;
            obj.is_starting_ = true;
        end
        %------------------------------------------------------------------
        function is = get.is_starting(obj)
            is = obj.is_starting_;
        end
        %------------------------------------------------------------------
        function is = get.is_running(obj)
            is = obj.is_running_;
        end
        function obj = set.is_running(obj,val)
            obj.is_starting_ = false;
            obj.is_running_ = val;
            if val > 0
                obj.is_failed_  = false;
                obj.waiting_count_ = 0;
            end
            
        end
        %------------------------------------------------------------------
        function is = get.is_failed(obj)
            is = obj.is_failed_;
        end
        function fr = get.fail_reason(obj)
            fr = obj.fail_reason_;
        end
        function obj = set_failed(obj,reason)
            obj.is_starting_ = false;
            obj.is_running_  =  false;
            obj.is_failed_   = true;
            obj.fail_reason_ = reason;
        end
        %------------------------------------------------------------------
        function is = get.waiting_count(obj)
            is = obj.waiting_count_;
        end
        function obj = set.waiting_count(obj,val)
            obj.waiting_count_ = val;
        end
        %------------------------------------------------------------------
        function out = get.outputs(obj)
            out = obj.outputs_;
        end
        function obj = set.outputs(obj,val)
            obj.outputs_    = val;
            obj.is_starting_=false;
            obj.is_running_ =false;
            obj.is_failed_  =false;
        end
        %------------------------------------------------------------------
        function is = get.is_finished(obj)
            is = false;
            if (~(obj.is_starting_ || obj.is_running_)) ||obj.is_failed_
                is = true;
            end
        end
        %------------------------------------------------------------------
        %
        function ok = job_state_is(job,mpi,state)
            % method checks if job state is as requested
            % the list of supported states now is:
            % 'starting', 'running', 'finished'
            ok = mpi.check_message(job.job_id,state);
        end
        
        function [isfail,job] = get_progress(job,mpi)
            % get job progres
            isfail = false;
            [ok,err,mess] = mpi.receive_message(job.job_id,'running');
            if ~ok
                job = job.set_failed(['Not able to retrieve "job_running" message. Err: ',...
                    err]);
                isfail  = true;
            else
                job.outputs = mess.payload;
            end
            
        end
        function [isfail,job] = get_output(job,mpi)
            % get job output
            isfail = false;
            [ok,err,mess] = mpi.receive_message(job.job_id,'completed');
            if ~ok
                job = job.set_failed(['Not able to retrieve "job_completed" message. Err: ',...
                    err]);
                isfail  = true;
            else
                job.outputs = mess.payload;
            end
        end
    end
end

