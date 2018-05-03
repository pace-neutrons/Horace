classdef ParpoolMessages < iMessagesFramework
    % The class providing file-based message exchange functionality for Herbert
    % distributed jobs framework.
    %
    % The framework's functionality is similar to parfor
    % but does not requered parallel toolbox and works by starting
    % separate Matlab sessions to do separate tasks.
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    % This class provides physical mechanism to exchange messages between tasks.
    %
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    %
    properties(Dependent)
    end
    %----------------------------------------------------------------------
    properties(Constant=true)
    end
    %----------------------------------------------------------------------
    properties(Access=protected)
        data_exchange_folder_;
        % time to wait for a message send from one session can be read from
        % another one.
        time_to_react_ = 0.1
    end
    %----------------------------------------------------------------------
    methods
        %
        function jd = ParpoolMessages(varargin)
            % Initialize Messages framework for particular job
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to
            % distinguish this job control files from any other job control
            % files.
            %Example
            % jd = MessagesFramework() -- use randomly generated job control
            %                             prefix
            % jd = MessagesFramework('target_name') -- add prefix
            %      which discribes this job.
            %
            
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
        function fn = mess_name(obj,task_id,mess_name)
            % not used in ParpoolMessages
            fn  = mess_name;
        end
        %
        function [ok,err_mess,message] = receive_message(obj,varargin)
            % receive message from a task with specified id
            % Blocking
            %Usage
            %>>[ok,err,message] = obj.receive_message() -- Receive any message.
            %>>[ok,err,message] = obj.receive_message(labId)  -- Receive
            %                     message from lab with the idSpecified
            % Receive ny message.
            [ok,err_mess,message] = receive_message_(obj,varargin{:});
        end
        %
        function [ok,err_mess] = send_message(obj,task_id,message)
            % send message to a task with specified id
            % NonBlocking
            % Usage:
            % >>mf = MessagesFramework();
            % >>mess = aMessage('mess_name')
            % >>[ok,err_mess] = mf.send_message(1,mess)
            % >>ok  if true, says that message have been successfully send to a
            % >>    task with id==1. (not received)
            % >>    if false, error_mess indicates reason for failure
            %
            ok = true;
            err_mess = [];
            try
                if isa(message,'aMessage')
                    tag = message.tag;
                elseif ischar(message)
                    tag = MESS_NAMES.mess_id(message);
                end
                labSend(message,task_id,tag);
            catch Err
                ok = false;
                err_mess = Err;
            end
        end
        %
        %
        function is = is_job_cancelled(obj)
            %2 method verifies if job has been cancelled
            if ~exist(obj.mess_exchange_folder_,'dir')
                is=true;
            else
                is=false;
            end
        end
        %
        function [messages_name,task_id] = probe_all(obj,varargin)
            % list all messages existing in the system for the tasks
            % with id-s specified as input.
            % NonBlocking
            %Usage:
            %>> [mess_names,task_id] = obj.probe_all([task_ids]);
            %Where:
            % task_ids    -- the task ids of the labs to verify messages
            %                from. Query all availible labs if this field
            %                is empty
            %
            %
            %Returns:
            % mess_names   -- the  cellarray, containing message names
            %                 of the message from  any lab in the pool.
            %                 empty for the
            % task_id     --  the task id of a first availible message
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
            % non-blocking.
            %
            % Usage:
            %>>[all_messages,task_ids] = pm.receive_all([task_is]);
            %Input:
            %task_ids -- array of task id-s to check messages for or emtpy
            %            to check for all messages
            %Return:
            % all_messages -- cellarray of messages for the tasks requested and
            %                have messages availible in the system with empty cells.
            %                for missing messages
            % task_ids    -- array of task id-s for these messages with
            %                zeros for missing messages
            % mess_name    -- if present, receive only the messages with
            %                 the name provided
            %
            %
%             for i=1:numel(varargin)
%                 fprintf('receive_all: Arg N%d = ',i);
%                 disp(varargin{i});
%             end
            [all_messages,task_ids] = receive_all_messages_(obj,varargin{:});
        end
        %
        function finalize_all(obj)
            % delete all messages belonging to this instance of messages
            % framework and delete the framework itself
            delete_job_(obj);
        end
    end
    %----------------------------------------------------------------------
    methods (Access=protected)
        function ind = get_lab_index_(obj)
            ind = labindex();
        end
        function nl = get_num_labs_(obj)
            nl = numlabs();
        end
        
    end
end

