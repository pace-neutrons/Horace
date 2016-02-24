classdef jobController
    % Helper class used by JobDispatcher
    % to analyse a running job state
    %
    % Stores running job features and relations between them
    %
    properties(Dependent)
        % job number assigned by JobDispatcher
        job_id
        %
        is_starting
        is_running
        is_finished
        is_failed
        % if job reports it progress
        reports_progress
        % time to wait until next progress message appears before failing
        time_to_fail
        % counts failed attempts to obrain something from a job
        waiting_count
        % job outputs
        outputs
        % message containing information why class decided that job have
        % failed
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
        reports_progress_ = false;
        waiting_interval_start_;
        estimatied_wait_time_=0;
        progress_info_ = [];
    end
    
    
    methods
        function obj=jobController(id)
            obj.job_id_=id;
            if id>0
                obj.is_starting_ = true;
            end
        end
        %------------------------------------------------------------------
        function info=get_job_info(obj)
            % return the string, containing information about job state
            info = sprintf('JobN:%02d| %8s |',obj.job_id,obj.state2str());
            pi = obj.progress_info_;
            if obj.is_running && obj.reports_progress && ~isempty(pi )
                time_left = (pi.n_steps-pi.step)*pi.time_per_step/60;
                info = [info, sprintf('Step#%d/%d, Estimatied time left: %4.2f(min)| ',...
                    pi.step,pi.n_steps,time_left),pi.add_info];
            elseif obj.is_failed
                info = [info,obj.fail_reason_];
            end
        end
        %
        function str = state2str(obj)
            % convert job state into string representations
            str  = obj.state2str_();
        end
        %------------------------------------------------------------------
        function id = get.job_id(obj)
            id = obj.job_id_;
        end
        %
        function obj = set_job_id(obj,ind)
            obj.job_id_=ind;
            obj.is_starting_ = true;
        end
        %
        function is = get.is_starting(obj)
            is = obj.is_starting_;
        end
        %------------------------------------------------------------------
        function is = get.is_running(obj)
            is = obj.is_running_;
        end
        %
        function obj = set.is_running(obj,val)
            obj.is_starting_ = false;
            obj.is_running_ = val;
            if val > 0
                obj.is_failed_  = false;
                obj.waiting_count_ = 0;
                obj.fail_reason_ = [];
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
            obj.is_starting_ = false;
            obj.is_failed_  = false;
            obj.is_running_ = false;
            obj.fail_reason_ = [];
            obj.waiting_count_ = 0;
        end
        %------------------------------------------------------------------
        function is = get.is_finished(obj)
            is = false;
            if (~(obj.is_starting_ || obj.is_running_)) ||obj.is_failed_
                is = true;
            end
        end
        %
        function is = get.reports_progress(obj)
            is = obj.reports_progress_;
        end
        %
        function time =get.time_to_fail(obj)
            % returns time to wait until no information occuring from the
            % job until decided that job have failed
            if obj.reports_progress
                if obj.estimatied_wait_time_ == 0
                    % job can not estimate its wait time. will wait indefinitely
                    time  = Inf;
                else
                    time = 5*obj.estimatied_wait_time_;
                end
            else
                % job can not estimate its wait time. will wait indefinitely
                time  = Inf;
            end
        end
        %------------------------------------------------------------------
        function [obj,is_running] = check_and_set_job_state(obj,mpi,new_message)
            % find the job state as function of its current state and
            % message it receives from mpi framework
            %
            % changes the object internal information (e.g.
            % finished also reads job output and running may modify
            % job log
            [obj,is_running] = check_and_set_job_state_(obj,mpi,new_message);
        end
        %------------------------------------------------------------------
        function is = is_wait_time_exceeded(obj)
            % verify if job exceeded the wait time to send a message to the
            % framework
            %
            wait_time = toc(obj.waiting_interval_start_);
            if wait_time > obj.time_to_fail
                is = true;
            else
                is = false;
            end
        end
    end
end

