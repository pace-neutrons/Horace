classdef MessagesParpool < iMessagesFramework
    % The class providing Matlab Parallel Computing toolbox-based
    % message exchange functionality for Herbert distributed jobs framework.
    %
    % The framework's functionality provides common Herbert interface to
    % Matlab parallel computing toolbox messages exchange functionality.
    %
    %
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    properties(Dependent)
    end
    %----------------------------------------------------------------------
    properties(Constant=true)
    end
    %----------------------------------------------------------------------
    properties(Access=protected)
        % time to wait for a message send from one session can be read from
        % another one.
        time_to_react_ = 0.1
        % holder to the class, wrapping Matlab MPI framework (parallel
        % computing toolbox, used to perform actual send/receive/probe
        % operations
        MPI_ = [];
        
        % Holder for the blocking messages, received asynchronously and
        % to be returned as requested (synchronously or asynchronously)
        blocking_mess_cache_
        % Holder for the non-blocking messages, received asynchronously and
        % to be returned as requested (synchronously or asynchronously)
        state_mess_cache_
    end
    %----------------------------------------------------------------------
    methods
        %
        function jd = MessagesParpool(varargin)
            % Initialize Messages framework for particular job
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to
            % distinguish this job control files from any other job control
            % files.
            %Example
            % jd = MessagesFramework() -- use randomly generated job control
            %                             prefix
            % jd = MessagesFramework('target_name') -- add prefix
            %      which describes this job.
            %
            % jd = MessagesFramework(control_structure) Where the control
            %      structure is the structure with fields:
            %    - job_id -- the string containing job description (like
            %                the one in 'target_name' above.
            %  Optional: (if these fields are present, the messages
            %              framework is initialized in test mode)
            %   - labNum  -- number of this node in test mode
            %
            %   - numLabs -- number of fake 'Virtual nodes' surrounding
            %                this node in the test mode
            jd = jd@iMessagesFramework();
            jd.MPI_ = [];
            if nargin>0
                jd = jd.init_framework(varargin{1});
            end
        end
        %------------------------------------------------------------------
        % HERBERT Job control interface
        function cs  = build_control(obj,task_id,varargin)
            % initialize worker's control structure, necessary to
            % initiate jobExecutor on a client
            name = class(obj);
            css = obj.worker_job_info(name,task_id,varargin{:});
            cs  = iMessagesFramework.serialize_par(css);
        end
        %
        function  obj = init_framework(obj,framework_info)
            % using control structure initialize operational message
            % framework
            obj = init_framework_(obj,framework_info);
        end
        %------------------------------------------------------------------
        % MPI interface
        %
        %
        function [ok,err_mess,message] = receive_message(obj,task_id,varargin)
            % receive message from a task with specified id.
            %
            % Blocking  or unblocking behavior depends on requested message
            % type or can be requested explicitly.
            %
            % If the requested message type is blocking, blocks until the
            % message is available
            % if it is unblocking, return empty message if appropriate message
            % is not present in system
            %
            % Asking a server for a message synchroneously, may block a
            % client if other type of message has been send by server.
            % Exception is FailureMessage, which, if send, will be received
            % in any circumstances.
            %
            % Usage:
            % >>mf = MessagesFramework();
            % >>[ok,err_mess,message] = mf.receive_message(id,mess_name, ...
            %                           ['-synchronous'|'-asynchronous'])
            % or:
            % >>[ok,err_mess,message] = mf.receive_message(id,'any', ...
            %                           ['-synchronous'|'-synchronous'])
            % or 
            % >>[ok,err_mess,message] = mf.receive_message(id, ...
            %                           ['-synchronous'|'-synchronous'])
            % which is equivalent to mf.receive_message(id,'any',___)

            %
            % Inputs:
            % id        - the address of the lab to receive message from
            % mess_name - name/tag of the message to receive.
            %             'any' means any tag.
            % Optional:
            % ['-s[ynchronous]'|'-a[synchronous]'] -- override default message
            %              receiving rules and receive the message
            %              block program execution if '-synchronous' keyword
            %              is provided, or continue execution if message has
            %              not been send ('-asynchronous' mode).
            %
            %Returns:
            %
            % >>ok  if MPI_err.ok, message have been successfully
            %       received from task with the specified id.
            % >>    if not, error_mess and error code indicates reasons for
            %       failure.
            % >> on success, message contains an object of class aMessage,
            %        with the received message contents.
            %
            [ok,err_mess,message] = receive_message_(obj,task_id,varargin{:});
        end
        %
        function [ok,err_mess] = send_message(obj,task_id,message)
            % send message to a task with specified id
            % NonBlocking
            %
            % Usage:
            % >>mf = MessagesFramework();
            % >>mess = aMessage('mess_name')
            % >>[ok,err_mess] = mf.send_message(1,mess)
            % >>ok  if true, says that message have been successfully send to a
            % >>    task with id==1. (not received)
            % >>    if false, error_mess indicates reason for failure
            %
            ok = MESS_CODES.ok;
            err_mess = [];
            obj.MPI_.mlabSend(message,task_id);
        end
        %
        function [messages_name,task_id] = probe_all(obj,task_id,varargin)
            % list all messages existing in the system and sent from the
            % tasks with id-s specified as input.
            % NonBlocking
            %Usage:
            %>> [mess_names,task_id] = obj.probe_all(task_ids,[mess_name|mess_tag]);
            %Where:
            % task_ids    -- the task ids of the labs to verify messages
            %                from. Query all available labs if this field
            %                is empty
            % message_name ! message_tag -- if present, check only for
            %                the messages of the kind, specified by this
            %
            %Returns:
            % mess_names   -- the  cellarray, containing message names
            %                 of the message from  any lab in the pool.
            %                 empty for the
            % task_id     --  the task id of a first available message
            %
            % if no messages are present in the system
            % messages_name and task_id are empty
            %
            [messages_name,task_id] = labProbe_messages_(obj,task_id,varargin{:});
        end
        %
        function [all_messages,task_ids] = receive_all(obj,task_ids,varargin)
            % receive messages from a task with id-s specified as array or
            % all messages from all labs available.
            %
            % Blocking  or unblocking behavior depends on requested message
            % type or can be requested explicitly.
            %
            % If the requested message type is blocking, blocks until the
            % message is available.
            % if it is unblocking, return empty message if appropriate message
            % is not present in system
            %
            % Asking a server for a message synchroneously, may block a
            % client if other type of message has been send by server.
            % Exception for reveive all are FailureMessage and CanceledMessage,
            % which, if send, will be received and returned instead of the
            % requested message in any circumstances.
            %
            % Usage:
            % >>mf = MessagesFramework();
            % >>[ok,err_mess,message] = mf.receive_all(task_ids,mess_name, ...
            %                           ['-synchronous'|'-asynchronous'])
            % or:
            % >>[ok,err_mess,message] = mf.receive_all(id,'any', ...
            %                           ['-synchronous'|'-asynchronous'])
            % or:
            % >>[ok,err_mess,message] = mf.receive_all('all','any', ...
            %                           ['-synchronous'|'-asynchronous'])
            %
            %Inputs:
            % task_ids  - array of task id-s to check for messages or 'all' for
            %             all labs(task-id-s)
            % mess_name - the string, defining the message name or 'any' or
            %             empty variable for any type of message.
            % Optional:
            % ['-s[ynchronous]'|'-a[synchronous]'] -- override default message
            %              receiving rules and receive the message
            %              block program execution if '-synchronous' keyword
            %              is provided, or continue execution if message has
            %              not been send ('-asynchronous' mode).
            %Return:
            % all_messages - cellarray of messages for the tasks requested and
            %                have messages available in the system.
            %task_ids      - array of task id-s where these messages were
            %                received from.
            %                in asynchroneous mode, size(task_ids) at output
            %                may be smaller then the size(task_ids) at input.
            %
            %
            if nargin>1 && ischar(task_ids)
                if strcmp('any',task_ids)
                    warning('Outdated receive all interface. Use all instead of any')
                    task_ids = 'all';
                end
            end
            [all_messages,task_ids] = receive_all_messages_(obj,task_ids,varargin{:});
        end
        %
        function finalize_all(obj)
            obj.clear_messages();
        end
        %
        function clear_messages(obj)
            % delete all messages belonging to this instance of messages
            % framework.
            %
            % Clear persistent fail message may be present in parent
            % framework
            obj.persistent_fail_message_ = [];
            % clear cached messages
            obj.blocking_mess_cache_.clear();
            obj.state_mess_cache_.clear();
            
            % receive and reject all messages, may be send to the lab
            [mess_names,source_id] = obj.MPI_.mlabProbe('all','any');
            while ~isempty(mess_names)
                for i=1:numel(source_id)
                    obj.MPI_.mlabReceive(source_id(i),mess_names(i));
                end
                % just in case failed stuck somewhere.
                obj.persistent_fail_message_ = [];                
                [mess_names,source_id] = obj.MPI_.mlabProbe('all','any');
            end
        end
        %
        function [ok,err]=labBarrier(obj,~)
            obj.MPI_.mlabBarrier();
            ok = MESS_CODES.ok;
            err = [];
        end
        %
        function is = is_job_canceled(obj,tid)
            % method verifies if job has been canceled
            if nargin<2
                mess = obj.probe_all('all','canceled');
            else
                mess = obj.probe_all(tid,'canceled');
            end
            if ~isempty(mess)
                is = true;
            else
                is=false;
            end
        end
        % ----------------------------------------------------------------
        % Test methods:
        %
        function obj=set_framework_range(obj,labNum,NumLabs)
            % The function to set numLab and labId describing framework
            % extend during testing. Will fail if used in production mode. 
            %
            if ~obj.is_tested
                error('MESSAGES_FRAMEWORK:runtime_error',...
                    'Can not setup parpool framework range in production mode')
            end
            obj.MPI_ = MatlabMPIWrapper(true,...
                labNum,NumLabs);            
        end

        
        function obj = set_mpi_wrapper(obj,wrapper)
            if ~isa(wrapper,'MatlabMPIWrapper')
                error('MESSAGES_PARPOOL:invalid_argument',...
                    ' Only MPI wrapper can be provided as input for this function');
            end
            obj.MPI_ = wrapper;
        end
        %
        function wrapper = get_mpi_wrapper(obj)
            wrapper = obj.MPI_;
        end
    end
    %----------------------------------------------------------------------
    methods (Access=protected)
        function ind = get_lab_index_(obj)
            ind = obj.MPI_.labIndex;
        end
        function nl = get_num_labs_(obj)
            nl = obj.MPI_.numLabs;
        end
        function is = get_is_tested(obj)
            is = obj.MPI_.is_tested;
        end
        
    end
end


