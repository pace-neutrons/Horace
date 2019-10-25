classdef JobExecutor
    % The class, responsible for running a task on a worker
    %
    %
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    %
    properties(Dependent)
        %-------------------------------------
        % Properties of a job executor:
        % the id(number) of the running task
        labIndex;
        % Access to messages framework used to exchange messages between
        % executor and controller
        mess_framework;
        % The framework used to exchange messages between MPI jobs pool and
        % the control node. For filebased messages its the same as
        % mess_framework but for proper MPI job or remote host its
        % different.
        control_node_exch;
        % a helper property, containing task outputs if these outputs are
        % defined
        task_outputs
    end
    %
    properties(Access=protected)
        % handle for the messages framework
        mess_framework_ = [];
        % the holder of the class, responsible for communication between the
        % head node and the worker's pool
        control_node_exch_ = [];
        %------------------------------------------------------------------
        % Protected data, initiated by init method and used by a child's
        % overloaded methods as requested
        %
        % The data common to all iterations of do_job method
        common_data_ = [];
        % number of first iteration to do over common_data
        n_first_iteration_ = 1;
        % number of iterations in the workers's loop (numel(loop_data_) if
        % the loop data contains an array or number of iterations over the
        % common_data_ if the loop_data_ are empty
        n_iterations_ = 0;
        % cellarray of the data, specific to each loop iteration
        loop_data_ = {};
        %
        % if the task needs to return results on completion.
        return_results_ = false;
        % task results holder used to keep a task's results to return at
        % finish task stage if return_results is set to true;
        % do_job and/or reduce_data should populate this property according
        % to the particular task logic.
        task_results_holder_ ={};
        
    end
    methods(Abstract)
        % should be overloaded by a particular implementation
        %
        % abstract method to do particular job.
        this=do_job(this);
        % abstract method to collect and reduce data, located on different.
        % workers
        this=reduce_data(this);
        % the method to analyse outputs and indicate that the tasks or job
        % has been completed.
        ok = is_completed(this);
    end
    %------------------------------------------------------------------ ---
    methods
        function je = JobExecutor()
            % Initialize job executor
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to distinguish
            % this job control files from any other job control files
            %Example
            % jd = JobExecutor() -- use randomly generated job control
            % prefix
        end
        %
        function [obj,mess]=init(obj,fbMPI,job_control_struct,InitMessage)
            % initiate worker side.
            %e.g:
            % set up tag, indicating that the job have started
            % and process main job control parameters, present in
            % inputs and files:
            %
            % fbMPI               -- the instance of file-based messages
            %                        framework, used to exchange messages
            %                        between worker and control node.
            %                        Depending on the used framework and job,
            %                        this class can be used for communications
            %                        between workers too.
            % job_control_struct  -- the structure,
            %                        containing information about
            %                        the messages framework to use for
            %                        communications between workers.
            % InitMessage         -- The message with information necessary
            %                        to run the job itself
            %
            % returns:
            % obj          initialized JobExecutor object
            % mess         if not empty, the reason for failure
            %
            % On success, also:
            % ReduceSend 'started' message to a control node (its node 1 over MPI
            % framework for workers with labID > 1 and node 0 over
            % FileBased for worker with labID ==  1)
            %
            % clear all possible messages stored in message cache. Should
            % be irrelevant but may be usefil for reinitializing a job
            % executor to run different task on the same parallel worker.
            mess_cache.instance('delete');
            %
            [obj,mess]=init_je_(obj,fbMPI,job_control_struct,InitMessage);
        end
        %
        function [ok,mess,obj] =finish_task(obj,varargin)
            % Cleanly finish job execution and inform head node about it
            %
            %Usage:
            %>>[ok,mess] = obj.finish_task();
            %>>[ok,mess] = obj.finish_task(SomeMessage);
            %>>[ok,mess] = obj.finish_task(SomeMessage,@mess_reduction_function);
            %
            % Where the first form normally waits until all workers return
            %'completed' message to the lab == 1 while the second form
            % expects return of SomeMessage (usually 'failed' message)
            %
            % when mess_reduction_function is present, the messages from
            % all labs processed on the lab one using this function
            %
            [ok,mess,obj] = finish_task_(obj,varargin{:});
        end
        %
        function [ok,err,obj] = reduce_send_message(obj,mess,varargin)
            % collect similar messages send from all nodes and send final
            % message to the head node
            %usage:
            %[ok,err]=Je_instance.reduce_send_message(message,mess_process_function)
            % where:
            % message -- either message to send or the message's to send
            %            name (from the list of accepted names)
            % mess_process_function -- if present, and not empty, the function
            %                          is used to process the messages from
            %                          received from all except one workers
            %                          to produce common result. If absent,
            %                          all messages payloads
            %                          are just combined together into
            %                          cellarray and become the payload of
            %                          the final message, sent to the head
            %                          node.
            % synchronize - if true or absent the the method would wait until
            %               similar messages are received from all workers in
            %               the pool. if false, the method will process only
            %               existing messages.
            %
            %
            [ok,err,the_mess,obj] = reduce_messages_(obj,mess,varargin{:});
            if obj.labIndex == 1
                [ok,err] = obj.control_node_exch.send_message(0,the_mess);
            end
        end
        %
        function log_progress(this,step,n_steps,time_per_step,add_info)
            % log progress of the job execution and report it to the
            % calling framework.
            % Inputs:
            % step     --  current step within the loop which doing the job
            % n_steps  --  number of steps this job will make
            % time_per_step -- approximate time spend to make one step of
            %                  the job
            % add_info -- some additional information provided by the
            %             client. Not processed but printed in a log if not
            %             empty.
            % Outputs:
            % Sends message of type LogMessage to the job dispatcher.
            % Throws JOB_EXECUTOR:cancelled error in case the job has
            %
            log_progress_(this,step,n_steps,time_per_step,add_info);
        end
        %------------------------------------------------------------------
        function id = get.labIndex(obj)
            % get number (job id) of current running job
            if ~isempty(obj.mess_framework_)
                id = obj.mess_framework_.labIndex;
            else % class has not been initiated properly
                id  = -1;
            end
        end
        %
        function out = get.task_outputs(obj)
            out = obj.task_results_holder_;
        end
        %
        function obj = set.task_outputs(obj,val)
            obj.task_results_holder_ = val;
        end
        %
        %
        function mf= get.mess_framework(obj)
            % returns reference to MPI framework, used for exchange between
            % MPI nodes of a cluster
            mf = obj.mess_framework_;
        end
        %
        function mf = get.control_node_exch(obj)
            % returns reference to MPI framework, used for exchange between
            % MPI cluster and control node.
            mf = obj.control_node_exch_;
        end
        %------------------------------------------------------------------
        % MPI interface (Underdeveloped, may be not necessary except
        % is_job_cancelled)
        %
        function [ok,err]=labBarrier(obj,nothrow)
            % implement labBarrier to synchronize various workers.
            [ok,err] = obj.mess_framework.labBarrier(nothrow);
        end
        %
        function is = is_job_cancelled(obj)
            is = obj.control_node_exch_.is_job_cancelled();
            if ~is
                [mess,tids] = obj.mess_framework_.probe_all('all','cancelled');
                if ~isempty(mess)
                    is = true;
                    % discard message(s)
                    obj.mess_framework_.receive_all(tids,'cancelled');
                end
            end
        end
    end
    
end

