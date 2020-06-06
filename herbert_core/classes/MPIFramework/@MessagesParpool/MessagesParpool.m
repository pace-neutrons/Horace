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
        % return true if the framework is tested
        is_tested
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
        % computing toolbox)
        MPI_ = [];
        %
        mess_cache_
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
        function [ok,err_mess,message] = receive_message(obj,varargin)
            % receive message from a task with specified id
            %
            % Blocking state depends on the message type requested.
            %
            % If blocking message is requested, blocks until this message
            % has been send. If unblocking message is requested and the
            % message was not issued, returns success and empty message
            %
            %Usage
            %>>[ok,err,message] = obj.receive_message(labId)  -- Receive
            %                     message from lab with the idSpecified or
            %
            %>>[ok,err,message] = obj.receive_message('any')  -- Receive
            %                     Receive any message.
            [ok,err_mess,message] = receive_message_(obj,varargin{:});
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
            try
                obj.MPI_.mlabSend(message,task_id);
            catch Err
                ok = MESS_CODES.a_send_error;
                err_mess = Err;
            end
        end
        %
        function [messages_name,task_id] = probe_all(obj,varargin)
            % list all messages existing in the system and sent from the
            % tasks with id-s specified as input.
            % NonBlocking
            %Usage:
            %>> [mess_names,task_id] = obj.probe_all([task_ids],[mess_name|mess_tag]);
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
            [messages_name,task_id] = labProbe_messages_(obj,varargin{:});
        end
        %
        function [all_messages,task_ids] = receive_all(obj,varargin)
            % retrieve (and remove from system) all messages
            % existing in the system for the tasks with id-s specified as input
            % dublicated messages sent from the same task id are discarded
            % and only the last message retained
            %
            % non-blocking if used without message name and blocking if
            % message name is provided
            %
            %
            % Usage:
            %>>[all_messages,task_ids] = pm.receive_all([task_is],[mess_name]);
            %Input:
            % task_ids -- array of task id-s to check messages for or empty
            %             or 'any' to check for all messages.
            % mess_name -- if present, the name (or tag) of the message to
            %              receive.
            
            %Return:
            % all_messages -- cellarray of messages for the tasks requested and
            %                have messages available in the system with empty cells.
            %                for missing messages
            % task_ids    -- array of task id-s for these messages with
            %                zeros for missing messages
            % mess_name    -- if present, receive only the messages with
            %                 the name provided. The messages sent from the
            %                 specified workers but with the name different
            %                 from provided are stored in the messages
            %                 cache, available for subsequent requests to
            %                 the recieve_all method.
            %
            %
            [all_messages,task_ids] = receive_all_messages_(obj,varargin{:});
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
            obj.mess_cache_.clear();
            %             if obj.numLabs == 1
            %                 return
            %             end
            % receive and reject all messages, may be present in the
            % messages framework.
            [isDataAvail,tag,srcWkrIdx] = obj.MPI_.mlabProbe([],[]);
            while isDataAvail
                for i=1:numel(srcWkrIdx)
                    obj.MPI_.mlabReceive(srcWkrIdx(i),tag(i));
                end
                [isDataAvail,tag,srcWkrIdx] = obj.MPI_.mlabProbe([],[]);
            end
        end
        %
        function [ok,err]=labBarrier(obj,~)
            obj.MPI_.mlabBarrier();
            ok = MESS_CODES.ok;
            err = [];
        end
        %
        function is = is_job_canceled(obj)
            % method verifies if job has been canceled
            mess = obj.probe_all('any','canceled');
            if ~isempty(mess)
                is = true;
            else
                is=false;
            end
        end
        % ----------------------------------------------------------------
        % Test methods
        %
        function is = get.is_tested(obj)
            is = obj.MPI_.is_tested;
        end
        %
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
        
    end
end


