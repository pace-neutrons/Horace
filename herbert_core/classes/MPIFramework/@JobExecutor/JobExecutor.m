classdef JobExecutor
    % The abstract class, responsible for running a specific task on a
    % worker.
    %
    % Works in conjunction with the  <a href="matlab:help('parallel_worker');">worker</a>]
    % function from MPIFramework folder.
    %
    % The script, initializing Herbert and Horace has to be placed on Matlab
    % search path before Herbert and Horace are initiated
    %
    % JobExecutor Properties and Methods
    %-------------------------------------
    % Abstract methods to overload:
    %
    % setup        - Pre-do_job-loop setup called once before entering main loop.
    % finalise     - Post-do_job-loop finalisation called once after leaving main loop.
    % do_job       - Do chunk of the job independent on other parallel executors
    % reduce_data  - Receive partial results from neighbors and combine them on the head worker
    % is_completed - Check if the job completed and return true if it is.
    %
    %-------------------------------------
    % JobExecutor Properties:
    %
    % labIndex          - The number of the running task.
    % numLabs           - The number of running tasks.
    % mess_framework    - Access to messages framework used for messages
    %                     exchange between the parallel tasks.
    % control_node_exch - The instance of the framework used to exchange
    %                     messages between MPI jobs pool and the control (login) node
    % task_outputs      - A helper property, containing task outputs to
    %                     transfer to the headnode.
    % n_steps           - Number of steps to loop over job data
    %
    % do_job_completed  - Helper method used for synchronization with
    %                     worker, if the task have failed
    %-------------------------------------
    % Communicator methods i.e. convenience methods, operating over defined
    % messages frameworks:
    %
    % init                - Initialize JobExecutor's communications
    %                        capabilities
    % reduce_send_message - collect similar messages send from all nodes and
    %                        send final message to the head node
    %                        (node 1 for nodes with N>1 or logon node for node 1)
    % send_message        - shortcut wrapper to message framework equivalent method
    % receive_message     - shortcut wrapper to message framework equivalent method
    % log_progress        - log progress of the job execution and report
    %                       it to the logon node.
    % labBarrier          - synchronize parallel workers execution,
    %                       deploying MPI barrier operation of the framework,
    %                       used for inter-process communications.
    % finish_task         - Safely complete job execution and inform other
    %                       nodes about it.

    properties(Dependent)
        % The id(number) of the running task. Worker Number in filebased,
        % labNum in Matlab or MPI rank for MPI
        labIndex;

        % Number of running tasks.
        numLabs;

        % Access to messages framework used for messages exchange between
        % the parallel tasks.
        % For file-based messages its the same as control_node_exch
        % but for proper MPI job on a remote host it is usually  different.
        mess_framework;

        % Framework to exchange messages between MPI jobs pool and control
        % node.
        % For filebased messages its the same as
        % mess_framework but for proper MPI job or remote host its
        % different.
        control_node_exch;

        % a helper property, containing task outputs to transfer to the
        % headnode, if these outputs are defined.
        task_outputs

        % Number of steps to loop over job data. Public interface to
        % n_iterations_. Read-only
        n_steps

        % Helper method used for workers synchronization,
        % in case when some workers failed at "do_job" operation but
        % others were able to complete it.
        %
        % After worker finishes "do_job" operation, it comes to barrier,
        % waiting for all other workers to finish "do_job" operation before
        % data reduction can begin.
        % false at this property indicates that if an exception is thrown,
        % the worker should wait other workers at another barrier after
        % processing exception, as the barrier after do_job have been
        % bypassed.
        do_job_completed

        % Whether process is root (1)
        is_root

    end

    properties(Hidden=true)
        % in debug mode, parallel worker assigns to this property
        % open file handle to do logging.
        ext_log_fh;
    end

    properties(Access=protected, Hidden = true)
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

        % abstract method to do particular chunk of the job independently
        % on other workers
        this=do_job(this);

        % abstract method to collect and reduce data, located on different.
        % workers.
        this=reduce_data(this);

        % the method to analyze outputs and indicate that the tasks or job
        % has been completed.
        ok = is_completed(this);
    end

    %------------------------------------------------------------------ ---

    methods
        function je = JobExecutor()
            % Create the job executor empty instance
            % ready for initialization.
            %
        end

        function [obj,mess]=init(obj,fbMPI,intercom_class,InitMessage,is_tested)
            % Initiate Job executor on a worker side.
            % namely:
            % set up tag, indicating that the job have started
            % and process main job control parameters, present in
            %
            % inputs:
            %
            % fbMPI               -- the initialized instance of file-based
            %                        messages framework, used for messages
            %                        exchange between worker and the control node.
            %                        Depending on the used framework and job,
            %                        this class can be used for communications
            %                        between workers too.
            % intercom_class     --  the class, providing MPI or pseudo MPI
            %                        communications between workers.
            % InitMessage         -- The message with information necessary
            %                        to run the job itself. The message
            %                        template is generated buy
            %                        iMessageFramework.build_worker_init
            %                        method.
            % is_tested           -- if present and true, the method would
            %                        run in test mode avoiding blocking
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
            % be irrelevant but may be useful for re-initializing a job
            % executor to run different task on the same parallel worker.

            if ~exist('is_tested', 'var')
                synchronize = true;
            else
                synchronize = ~is_tested;
            end

            [obj,mess]=init_je_(obj,fbMPI,intercom_class,InitMessage,synchronize);
        end

        %------------------------------------------------------------------

        function id = get.labIndex(obj)
            % get number (job id) of current running job
            if isempty(obj.mess_framework_)
                % class has not been initiated properly
                id  = -1;
            else
                id = obj.mess_framework_.labIndex;
            end
        end

        function out = get.is_root(obj)
            out = obj.labIndex == 1;
        end

        function id = get.numLabs(obj)
            % get number of currently running jobs
            if isempty(obj.mess_framework_)
                % class has not been initiated properly
                id  = -1;
            else
                id = obj.mess_framework_.numLabs;
            end
        end

        function out = get.task_outputs(obj)
            out = obj.task_results_holder_;
        end

        function obj = set.task_outputs(obj,val)
            obj.task_results_holder_ = val;
        end

        function n_steps = get.n_steps(obj)
            n_steps = obj.n_iterations_;
        end

        function mf= get.mess_framework(obj)
            % returns reference to MPI framework, used for exchange between
            % MPI nodes of a cluster
            mf = obj.mess_framework_;
        end

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
        % convenience MPI interface, operating with all initialized
        % MPI frameworks
        %
        function [ok,mess,obj] =finish_task(obj,varargin)
            % Safely finish job execution and inform the head node about it.
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
            % 'completed' message to the lab == 1,
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

        function [ok,err,obj] = reduce_send_message(obj,mess,reduction_state_name,varargin)
            % collect similar messages send from all nodes and send final
            % message to the head node
            %usage:
            %[ok,err]=Je_instance.reduce_send_message(message,mess_process_function,[synchronize])
            % where:
            % message -- either message to send or the message's to send
            %            name (from the list of acceptable names)
            %            This is the message, containing information about
            %            current worker state.
            % reduction_state_name   -- the name of the message/state to process.
            %                           This contains the information about
            %                           desired state the call to this
            %                           function expects.
            %            Under normal circumstances it is equal to the mess.mess_name,
            %            but if exception have occurred, mess contains the
            %            information about the failure, but reduction_type_name
            %            still informs what the state of the worker
            %            should be processed.
            %
            % mess_process_function -- if present, and not empty, the function
            %                          is used to process the messages from
            %                          received from all except one workers
            %           to produce common result. If absent,
            %           all messages payloads are just combined together
            %           into cellarray and become the payload of
            %           the final message, sent to the head node.
            %
            % synchronize - if true or absent the the method would wait until
            %               similar messages are received from all workers in
            %               the pool. if false, the method will process only
            %               existing messages.
            %
            %
            [ok,err,the_mess,obj] = reduce_messages_(obj,mess,reduction_state_name,varargin{:});
            if obj.labIndex == 1
                [ok,err] = obj.control_node_exch.send_message(0,the_mess);
            end
        end

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

        function [ok,err]=labBarrier(obj,nothrow)
            % implement labBarrier to synchronize various workers.
            [ok,err] = obj.mess_framework_.labBarrier(nothrow);
        end

        function [ok,err]=send_message(obj,message)
            % Wrapper to send_message to ease writing
            [ok,err] = obj.mess_framework_.send_message(message);
        end

        function [ok,err,message]=receive_message(obj,from_task_id,varargin)
            % Wrapper to receive_message to ease writing
            [ok,err,message] = obj.mess_framework_.receive_message(from_task_id,varargin{:});
        end

        function obj = setup(obj)
            % Function called once before entering do_job loop
            % to give opportunity to initialise JobExecutor data
            % with access to parallel comms.

            % Function is empty with intent to be overridden by subclasses

        end

        function obj = finalise(obj)
            % Function called once after leaving do_job loop
            % to give opportunity to finalise JobExecutor data
            % with access to parallel comms.

            % Function is empty with intent to be overridden by subclasses

        end

        function [cancelled,reas] = is_job_cancelled(obj)
            % check all available framework for the job cancellation state.
            %
            % Returns true if job folder has been deleted

            cancelled = false;
            reas = '';

            if is_folder(obj.control_node_exch_.mess_exchange_folder)
                [mess,tids] = obj.mess_framework_.probe_all('all','cancelled');
                if ~isempty(mess)
                    cancelled = true;
                    if nargout > 1
                        reas = sprintf(' Received %d cancellation messages: ',numel(mess));
                        for i=1:numel(tids)
                            reas = sprintf('%s\n name: %s; from node %d',reas,mess{i},tids(i));
                        end
                    end
                end
            else
                cancelled = true;
                if nargout>1
                    reas = sprintf(' Job folder %s has been deleted',...
                        obj.control_node_exch_.mess_exchange_folder);
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

            if ~exist('exit_on_completion', 'var')
                exit_on_completion = true;
            end
            if ~exist('keep_worker_running', 'var')
                keep_worker_running = false;
            end
            JE_className = class(obj);
            initMessage = JobExecutor.build_worker_init(JE_className,...
                exit_on_completion,keep_worker_running);
        end

        function mess_with_err=process_fail_state(obj,ME,varargin)
            % Process and gracefully complete an exception, thrown by the
            % user code running on the worker.
            % Inputs:
            % ME        -- exception class, thrown by the user code
            %Optional:
            % fh        -- if present, means logging mode -- received
            %              opened file handle to write log information into it
            %Performs:
            % If exception is any except 'cancelled', sends 'cancelled'
            % message to all neighboring nodes. If 'cancelled', just returns
            % synchronize worker according to the state of the parallel job
            % execution.
            %
            %
            % Returns:
            % FailedMessage of the finish_task operation

            mess_with_err = process_fail_state_(obj,ME,varargin{:});
        end

        function obj=migrate_job_folder(obj,delete_old_folder)
            % the function user to change location of message exchane
            % folder when task is completed and new task should start.
            %
            % used to bypass issues with NFS caching when changing subtasks

            if nargin<2
                delete_old_folder = true;
            end
            obj.control_node_exch.migrate_message_folder(delete_old_folder);
        end
    end

    methods % Common parallel operations
        function varargout = bcast(obj, root, varargin)
            % Send a copy of data from root to each process
            %
            % Usage :
            %
            %  Send my_val to each process
            %  my_val = obj.bcast(1, my_val)
            %  Send both my_val1 and my_val2 to each process (only one send)
            %  [my_val1, myval2] = obj.bcast(1, my_val1, my_val2)
            %
            %  Inputs
            %  ------
            %  root       Process to send data
            %
            %  varargin   Values to be scattered
            %
            %  Outputs
            %  -------
            %  varargout  Received values

            if obj.numLabs == 1
                varargout = varargin;
                return
            end

            if obj.labIndex == root
                % Send data
                varargout = varargin;
                send_data = DataMessage(varargin);
                to = 1:obj.numLabs;
                to = to(to ~= root);
                for i=1:obj.numLabs-1
                    [ok, err_mess] = obj.mess_framework.send_message(to(i), send_data);
                    if ~ok
                        error('HORACE:MFParallel_Job:send_error', err_mess)
                    end
                end

            else

                % Receive the data
                [ok, err_mess, data] = obj.mess_framework.receive_message(root, 'data');
                if ~ok
                    error('HORACE:MFParallel_Job:receive_error', err_mess)
                end
                varargout = data.payload;
            end

        end

        function val = scatter(obj, root, val_in, nData, dim)
            % Split data and send section to each process
            %
            % Usage :
            %
            %  Split a vector into chunks and send element to each process
            %  val = obj.scatter(1, [1 2 3 4], [1 1 1 1], 0)
            %
            %  Inputs
            %  ------
            %  root     Process to send data
            %
            %  val_in   Value to be scattered
            %
            %  nData    Vector [nWorkers x 1] of number of elements to send to each process
            %
            %  dim      Dimension of data to scatter
            %           One of:
            %             - 0   Treat as vector
            %             - 1   Split across rows
            %             - 2   Split across columns
            %
            %  Outputs
            %  -------
            %  val      Section of data on this process

            if obj.numLabs == 1
                val = val_in;
                return
            end

            if obj.labIndex == root
                if numel(nData) ~= obj.numLabs
                    error('HORACE:MFParallel_Job:send_error', 'nData does not match nWorkers')
                end

                if (dim~= 0 && sum(nData) ~= size(val_in, dim)) || ...
                          (dim == 0 && sum(nData) ~= numel(val_in))
                    error('HORACE:MFParallel_Job:send_error', 'nData does not match data size')
                end

                slices = [0; cumsum(nData)];

                % Send data
                for i=1:obj.numLabs
                    switch dim
                      case 0
                        to_send = val_in(slices(i)+1:slices(i+1));
                      case 1
                        to_send = val_in(slices(i)+1:slices(i+1), :);
                      case 2
                        to_send = val_in(:, slices(i)+1:slices(i+1));
                      otherwise
                        error('HORACE:MFParallel_Job:send_error', 'Dim %d not supported', dim)
                    end
                    if i ~= root
                        send_data = DataMessage(to_send);
                        [ok, err_mess] = obj.mess_framework.send_message(i, send_data);
                        if ~ok
                            error('HORACE:MFParallel_Job:send_error', err_mess)
                        end
                    else
                        val = to_send;
                    end
                end

            else

                % Receive the data
                [ok, err_mess, recv_data] = obj.mess_framework.receive_message(root, 'data');
                if ~ok
                    error('HORACE:MFParallel_Job:receive_error', err_mess)
                end
                val = recv_data.payload;
            end

        end


        function val = reduce(obj, root, val, op, opt, varargin)
            % Reduce data (val) from all processors on lab root using operation op
            % If op requires a list rather than array
            %
            % Usage :
            %
            %  Sum my_val and set on process 1
            %  >> my_val = obj.reduce(1, my_val, @sum)
            %  Return each my_val incremented by 3
            %  >> my_val = obj.reduce(1, my_val, @plus, 'mat', 3)
            %  Return my_val from each proc as cell array
            %  >> my_val = obj.reduce(1, my_val, @(x) x, 'cell')
            %
            %  Inputs
            %  ------
            %  root     Process to receive and operate on data
            %           (note that val will only be set on this process)
            %
            %  val      Value to be reduced
            %
            %  op       Operation to perform as reduction
            %
            %  opt      Means by which to perform operation (default: mat)
            %           One of:
            %             - mat   Treat received data as elements of a matrix     : op([1 2 3 4], extras)
            %             - cell  Treat received data as elements of a cell array : op({1 2 3 4}, extras)
            %             - args  Expand received data as arguments to op         : op(1, 2, 3, 4, extras)
            %
            %  extras   Extra arguments to pass to op (after received data
            %
            %  Outputs
            %  -------
            %  val      Reduced data after op

            if ~exist('opt', 'var')
                opt = 'mat';
            end

            if obj.numLabs == 1
                recv_data = {val};
                switch opt
                    case 'mat'
                      recv_data = cell2mat(recv_data);
                      val = op(recv_data, varargin{:});
                    case 'cell'
                      val = op(recv_data, varargin{:});
                    case 'args'
                      val = op(recv_data{:}, varargin{:});
                end
                return
            end

            if obj.labIndex == root
                [recv_data, ids] = obj.mess_framework.receive_all('all', 'data');
                [~,ind] = sort(ids);

                recv_data = recv_data(ind);
                recv_data = cellfun(@(x) (x.payload), recv_data, 'UniformOutput', false);
                recv_data = {val, recv_data{:}};
                switch opt
                  case 'mat'
                    recv_data = cell2mat(recv_data);
                    val = op(recv_data, varargin{:});
                  case 'cell'
                    val = op(recv_data, varargin{:});
                  case 'args'
                    val = op(recv_data{:}, varargin{:});
                end

            else
                send_data = DataMessage(val);

                [ok, err_mess] = obj.mess_framework.send_message(root, send_data);
                if ~ok
                    error('HORACE:MFParallel_Job:send_error', err_mess)
                end

                val = [];
            end
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

            if ~exist('exit_on_completion', 'var')
                exit_on_completion = true;
            end
            if ~exist('keep_worker_running', 'var')
                keep_worker_running = false;
            end

            info = struct(...
                'JobExecutorClassName',JE_className,...
                'exit_on_compl',exit_on_completion ,...
                'keep_worker_running',keep_worker_running);
            initMessage  = StartingMessage(info);
        end

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
                mis =MPI_State.instance();
                if mis.trace_log_enabled
                    fh = mis.debug_log_handle;
                    fwrite(fh,sprintf('initializing intercom: %s\n', ...
                        control_structure.intercomm_name));
                end
                %
                mf = feval(control_structure.intercomm_name);
                mf = mf.init_framework(control_structure);
                %
                if mis.trace_log_enabled
                    fwrite(fh,sprintf('intercom: %s initialized\n', ...
                        control_structure.intercomm_name));
                end
                % set labNum and NumLabs for filebased  MPI framework,
                % equal to values, defined for proper MPI framework to
                % avoid cross-talking and invalid indexing
                cntrl_node_exchange = cntrl_node_exchange.set_framework_range(mf.labIndex,mf.numLabs);
                internode_exchange  = mf;
            end
        end

        function report_cluster_ready(fbMPI, intercomm)
            % When MPI framework was initialized, collect starting messages
            % from all neighboring nodes and inform the server that the
            % cluster have started.
            %
            %Inputs:
            %fbMPI -- fully initialized file-based messages exchange
            %         framework, used for communicating between cluster and
            %         the Matlab session, which lounching it.
            % intercomm -- fully initalized MPI framework, used for
            %          communications between cluster's nodes
            %
            % Throws if all messages were not received within the time-out
            % period

            report_cluster_ready_(fbMPI, intercomm);
        end
    end

end
