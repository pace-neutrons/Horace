classdef taskController
    % Helper class used by JobDispatcher
    % to analyse a running task state
    %
    % Stores running task features and relations between them
    %
    properties(Dependent)
        % task number assigned by JobDispatcher (lab number)
        task_id
        % the handle to a class, used to controling the task directly
        % (not through messages)
        task_handle
        % task states:
        is_starting
        is_running
        is_finished
        is_failed
        % property indicate that state of the task have changed
        state_changed
        % if task reports it progress. Enabling it allows to expect failure
        % if reports do not come for a specifc period of time
        reports_progress
        % counts failed attempts to obtain something from a task
        waiting_count
        % task outputs
        outputs
        % time to wait until next task progress message appears before failing
        time_to_fail;
        % message containing information why class decided that task have
        % failed
        fail_reason
    end
    properties(Access=private)
        task_id_
        task_handle_ = []
        %
        is_running_=false;
        is_starting_=false
        is_failed_=false;
        %
        state_changed_ = false;
        %
        waiting_count_ = 0
        outputs_       = []
        fail_reason_   = [];
        %
        reports_progress_ = false;
        % time when waiting interval for the task, reporting results have
        % started.
        waiting_interval_start_;
        estimatied_wait_time_=0;
        progress_info_ = [];
        
        fail_limit_ = 100;
    end
    
    methods
        function obj=taskController(id,aTaskWrapper)
            obj.task_id_     = id;
            obj.task_handle  = aTaskWrapper;
            obj.is_starting_ = aTaskWrapper.is_running;
            if isa(aTaskWrapper,'aTaskWrapperForTest') % testing. Decrease ttf value
                obj.fail_limit_  = 3;
            end
        end
        %------------------------------------------------------------------
        function info=get_task_info(obj)
            % return the string, containing information about the task state
            % given
            info = sprintf('TaskN:%02d| %8s |',obj.task_id,obj.state2str());
            pi = obj.progress_info_;
            if obj.is_running && obj.reports_progress && ~isempty(pi )
                if pi.time_per_step == 0
                    info = [info, sprintf('Step#%d/%d, Estimated time left:  Unknown | ',...
                        pi.step,pi.n_steps),pi.add_info];
                    
                else
                    time_left = (pi.n_steps-pi.step)*pi.time_per_step/60;
                    info = [info, sprintf('Step#%d/%d, Estimated time left: %4.2f(min)| ',...
                        pi.step,pi.n_steps,time_left),pi.add_info];
                    
                end
            elseif obj.is_failed
                info = [info,obj.fail_reason_];
            end
        end
        %
        function str = state2str(obj)
            % convert task state into string representations
            str  = obj.state2str_();
        end
        %------------------------------------------------------------------
        function id = get.task_id(obj)
            id = obj.task_id_;
        end
        %
        function obj = set.task_id(obj,ind)
            obj.task_id_=ind;
            obj.is_starting_ = true;
        end
        %
        function is = get.is_starting(obj)
            is = obj.is_starting_;
        end
        function th = get.task_handle(obj)
            th = obj.task_handle_;
        end
        function obj = set.task_handle(obj,val)
            if isa(val,'iTaskWrapper')
                obj.task_handle_ = val;
            else
                error('TASK_CONTROLLER:invalid_argument',...
                    'job task has to be an instance of an iTaskWrapper class')
            end
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
            obj.is_starting_  = false;
            obj.is_running_   =  false;
            obj.is_failed_    = true;
            obj.fail_reason_  = reason;
            %obj.state_changed_= true;
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
        function is = get.state_changed(obj)
            is = obj.state_changed_;
        end
        function obj = set.state_changed(obj,val)
            obj.state_changed_=val;
        end
        %
        %------------------------------------------------------------------
        function [obj,is_running] = check_and_set_task_state(obj,mpi,new_message)
            % find the task state as function of its current state and
            % message it receives from MPI framework
            %
            % changes the object internal information (e.g.
            % finished also reads task output and running may modify
            % task log
            [obj,is_running] = check_and_set_task_state_(obj,mpi,new_message);
        end
        %------------------------------------------------------------------
        function is = is_wait_time_exceeded(obj)
            % verify if task exceeded the time to send a message to the
            % framework (framework have not received a message during
            % time-out above)
            %
            %
            % waiting_interval_start_ and estimatied_wait_time_ are
            % updated each time log message is received
            wait_time = toc(obj.waiting_interval_start_);
            if wait_time > obj.time_to_fail
                is = true;
            else
                is = false;
            end
        end
        function time =get.time_to_fail(obj)
            % returns time to wait until no information occurring from the
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
        
    end
end

