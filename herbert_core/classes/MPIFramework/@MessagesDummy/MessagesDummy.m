classdef MessagesDummy < iMessagesFramework
    % The class providing file-based message exchange functionality for dummy MPI
    %
    % The framework's functionality is similar to parfor
    % but does not required parallel toolbox and works by starting
    % separate Matlab sessions to do separate tasks.
    %
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    % This class provides physical mechanism to exchange messages between tasks.
    %
    %

    %----------------------------------------------------------------------

    properties(Constant)
        mess_exchange_folder = pwd();
    end

    properties(Access=protected,Hidden=true)
        % equivalent to labNum in MPI
        task_id_ = 1;

        numLabs_ = 1;

        message_stack_ = {};
    end

    %----------------------------------------------------------------------

    methods

        function mf = MessagesDummy(varargin)
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
            % File-based messages framework creates the exchange folder with
            % the filename specified as input.

            % Initialise folder path
            mf = mf@iMessagesFramework();
            mf.interrupt_chan_name_ = MESS_NAMES.interrupt_channel_name;
        end

        function init_framework(obj, framework_info)
            ...
        end

        %------------------------------------------------------------------

        function obj=set_framework_range(obj,labNum,NumLabs)
            % The function to set numLab and labId describing framework
            % extend during initialization procedure.

            % Also used independently to set up slave file-based framework,
            % in the case when main data exchange framework between nodes
            % is an MPI-based framework
            obj.task_id_ = labNum;
            obj.numLabs_ = NumLabs;
            obj.send_data_messages_count_ = 0;
            obj.receive_data_messages_count_ = 0;

        end

        %------------------------------------------------------------------
        % MPI interface


        function [ok,err_mess] = send_message(obj,task_id,message)
            % send message to a task with specified id
            %
            % Usage:
            % >>mf = MessagesFramework();
            % >>mess = aMessage('mess_name')
            % >>[ok,err_mess] = mf.send_message(1,mess)
            % >>ok  if true, says that message have been successfully send to a
            % >>    task with id==1. (not received)
            % >>    if false, error_mess indicates reason for failure

            ok = true;
            err_mess = '';
            obj.message_stack_ = [message.payload, obj.message_stack_];
        end

        function [all_messages_names,task_ids] = probe_all(obj,task_ids_in,mess_name)
            % list all messages existing in the system with id-s specified as input
            % and intended for this task
            %
            %Usage:
            %>> [mess_names,task_ids] = obj.probe_all(task_ids,[mess_name|mess_tag]);
            %Where:
            % task_ids -- array of task id-s to check messages for or all
            %             messages if this is empty
            % message_name or message_tag -- if present, check only for
            %             the messages of specific kind.
            %Returns:
            % mess_names   -- cellarray of strings, containing message names
            %                 for the requested tasks.
            % task_ids     -- array of task id-s for the message names
            %                 in the mess_names
            %
            % if no messages are present in the system
            % all_messages_names and task_ids are empty
            %
            % Always return Inerrtupt message if any is present

            all_messages_names = [];
            task_ids = [];

        end

        function finalize_all(obj)
            % delete all messages belonging to this instance of messages
            % framework and delete the framework itself

            obj.clear_messages();
        end

        function clear_messages(obj)
            % Clear all messages directed to this lab.

            obj.message_stack_ = [];
        end

        function [ok,err]=labBarrier(obj,nothrow)
            %  if nothrow == true, do not throw on errors in message
            %  propagation

            ok = true;
            err = ''
        end

        function is = is_job_cancelled(obj)
            % method verifies if job has been cancelled

            is = false;
        end

    end
    %----------------------------------------------------------------------
    methods (Access=protected)

        function ind = get_lab_index_(obj)
            ind = obj.task_id_;
        end

        function ind = get_num_labs_(obj)
            ind = obj.numLabs_;
        end

        function is = get_is_tested(obj)
            % return true if the framework is tested (Running on single
            % Matlab session)
            is = false;
        end

        function [ok,err_mess,message] = receive_message_internal(obj,...
                from_task_id,mess_name,is_blocking)
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
            % >>ok  if MESS_CODES.ok, message have been successfully
            %       received from task with the specified id.
            % >>    if not, error_mess and error code indicates reasons for
            %       failure.
            % >> on success, message contains an object of class aMessage,
            %        with the received message contents.


            ok = true;
            err_mess = '';
            message = obj.message_stack_{1};
            obj.message_stack_ = obj.message_stack_(2:end);
        end
    end
end
