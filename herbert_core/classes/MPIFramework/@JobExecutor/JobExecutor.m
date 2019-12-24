classdef JobExecutor
    % The class, responsible for running a task on a worker
    %
    %
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    % $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
    %
    %
    properties(Dependent)
        %-------------------------------------
        % Properties of a job executor:
        % the id(number) of the running task
        labIndex;
        % Number of steps to loop over job data. Public interface to
        % n_iterations_. Read-only
        n_steps
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
        % Helper method used for synchronization with worker
        % needed to verify barrier in case of some worker failed
        % while some finished do_job but some failed before that.
        do_job_completed
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
        % holder for do_job_completed value
        do_job_completed_  = false;
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
        function [obj,mess]=init(obj,fbMPI,intercom_class,InitMessage,is_tested)
            % initiate worker side.
            %e.g:
            % set up tag, indicating that the job have started
            % and process main job control parameters, present in
            % inputs and files:
            %
            % fbMPI               -- the initialized instance of file-based 
            %                        messages framework, used for messages 
            %                        exchange between worker and the control node.
            %                        Depending on the used framework and job,
            %                        this class can be used for communications
            %                        between workers too.
            % intercom_class     --  the class, providing MPI or pseudo MPI
            %                         communications between workers
            % InitMessage         -- The message with information necessary
            %                        to run the job itself. The message
            %                        template is generated buy
            %                        iMessageFramework.build_worker_init
            %                        method.
            % is_tested           -- if present and true, the method would
            %                        run in test mode to avoid blocking
            %                        communications
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
            if ~exist('is_tested','var')
                synchronize = true;
            else
                synchronize = ~is_tested;
            end
            %
            [obj,mess]=init_je_(obj,fbMPI,intercom_class,InitMessage,synchronize);
        end
        %
        function [ok,mess,obj] =finish_task(obj,varargin)
            % Safely finish job execution and inform head node about it.
            %
            %Usage:
            %>>[ok,mess] = obj.finish_task();
            %>>[ok,mess] = obj.finish_task(SomeMessage);
            %>>[ok,mess] = obj.finish_task(SomeMessage,@mess_reduction_function);
            %>>[ok,mess] = obj.finish_task(SomeMessage,...
            %              @mess_reduction_function,...
            %              ['-synchronous'|'-asynchronous']);
            %
            % Where the first form waits until all workers return
            %'completed' message to the lab == 1,
            % The second form if message is not empty,
            % return of SomeMessage (usually 'failed' message)
            % asynchronous.
            %
            % when mess_reduction_function is present, the messages from
            % all labs processed on the lab one using this function. If
            % asynchronous execution is needed, the in this case, the
            % message should be defined by empty placeholder,i.e.:
            % obj = obj.finish_task([],@custom_reduction)
            %
            % the last option, if present, forces synchronous or
            % asynchronous execution explicitly.
            %
            [ok,mess,obj] = finish_task_(obj,varargin{:});
        end
        %
        function [ok,err,obj] = reduce_send_message(obj,mess,varargin)
            % collect similar messages send from all nodes and send final
            % message to the head node
            %usage:
            %[ok,err]=Je_instance.reduce_send_message(message,mess_process_function,[synchronize])
            % where:
            % message -- either message to send or the message's to send
            %            name (from the list of acceptable names)
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
            % Throws JOB_EXECUTOR:canceled error in case the job has
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
        function n_steps = get.n_steps(obj)
            n_steps = obj.n_iterations_;
        end
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
        function is = get.do_job_completed(obj)
            is = obj.do_job_completed_;
        end
        function obj = set.do_job_completed(obj,val)
            obj.do_job_completed_ = logical(val);
        end
        
        %------------------------------------------------------------------
        % MPI interface (Underdeveloped, may be not necessary except
        % is_job_canceled)
        %
        function [ok,err]=labBarrier(obj,nothrow)
            % implement labBarrier to synchronize various workers.
            [ok,err] = obj.mess_framework_.labBarrier(nothrow);
        end
        %
        function is = is_job_canceled(obj)
            is = obj.control_node_exch_.is_job_canceled();
            if ~is
                [mess,tids] = obj.mess_framework_.probe_all('all','canceled');
                if ~isempty(mess)
                    is = true;
                    % discard message(s)
                    obj.mess_framework_.receive_all(tids,'canceled');
                end
            end
        end
        function initMessage = get_worker_init(obj,exit_on_completion,...
                keep_worker_running)
            % Builds the structure, used by a worker to initialize this
            % particular job executor class and its mode of operation
            % (Stage 2 of worker initialization) to run on a worker.
            % Needs to be called from the instance of the jobExectutor to
            % run on the nodes
            %
            % where:
            % exit_on_completion -- true if worker's Matlab session should
            %                exit when job is finished.
            % keep_worker_running -- true if worker's Matlab session should
            %                run after JE work is completed waiting for
            %                another starting and init messages.
            %
            % Returns initialized 'starting' message class, to be accepted
            % by a worker and used to initialize the job execution on the
            % second step of the worker initialization.
            %
            if ~exist('exit_on_completion','var')
                exit_on_completion = true;
            end
            if ~exist('keep_worker_running','var')
                keep_worker_running = false;
            end
            JE_className = class(obj);
            initMessage = JobExecutor.build_worker_init(JE_className,...
                exit_on_completion,keep_worker_running);
        end
        %
        function [ok,err_message]=process_fail_state(obj,ME,is_tested)
            % Process and gracefully complete an exception, thrown by the
            % user code running on the worker.
            % Inputs:
            % ME        -- exception class, thrown by the user code
            % is_tested -- if false, indicates that the  code is run on a
            %              mpi worker or if true, is tested within a
            %               main Matlab session so blocking operations
            %               should be disabled
            % Returns:
            % results of the finish_task operation
            %
            % Should run on non-initialized object
            [ok,err_message] = process_fail_state_(obj,ME,is_tested);
        end
    end
    methods(Static)
        function initMessage = build_worker_init(JE_className,exit_on_completion,...
                keep_worker_running,test_mode)
            % Builds the structure, used by a worker to initialize a
            % particular job executor class and its mode of operation
            % (Stage 2 of worker initialization) to run on a worker.
            %
            % where:
            % JE_className -- the name of the class to do job on a worker
            %                (needs empty constructor and init method +
            %                child of the JobExecutor class)
            % exit_on_completion -- true if worker's Matlab session should
            %                exit when job is finished.
            % keep_worker_running -- true if worker's Matlab session should
            %                run after JE work is completed waiting for
            %                another starting and init messages.
            % test_mode   -- the mode used for testing CppMPI framework. 
            %                if present and true, sets-up test framework
            %                mode
            %
            if ~exist('exit_on_completion','var')
                exit_on_completion = true;
            end
            if ~exist('keep_worker_running','var')
                keep_worker_running = false;
            end           
            
            info = struct(...
                'JobExecutorClassName',JE_className,...
                'exit_on_compl',exit_on_completion ,...
                'keep_worker_running',keep_worker_running);
            initMessage  = aMessage('starting');
            initMessage.payload = info;
        end
        %
        function [cntrl_node_exchange,internode_exchange]=init_frameworks(control_structure)
            % Take control structure and initialize the frameworks for
            % communications between the nodes of cluster and the cluster
            % and the headnode.
            %
            % The control structure is defined on iMessageFramework class,
            % get_worker_init method which actually describes the particular 
            % frameworks to use for message exchange within the job.
            %
            % here we need to know what framework to use to exchange messages between
            % the MPI jobs.
            fbMPI = MessagesFilebased();
            cntrl_node_exchange = fbMPI.init_framework(control_structure);
            if strcmpi(class(fbMPI),control_structure.intercomm_name)
                % filebased messages all around:
                if isfield(control_structure,'labID') && isfield(control_structure,'numLabs')
                    internode_exchange = cntrl_node_exchange;
                else % the filebased messages framework has not been initialized properly
                    error('JOB_EXECUTOR:invalid_argument',...
                        'filebased messages framework have not been initialized properly');
                end
            else % the framework is defined by the appropriate framework name
                mf = feval(control_structure.intercomm_name);
                mf = mf.init_framework(control_structure);
                cntrl_node_exchange = cntrl_node_exchange.set_framework_range(mf.labIndex,mf.numLabs);
                internode_exchange  = mf;
            end
        end
        
    end
    
end


