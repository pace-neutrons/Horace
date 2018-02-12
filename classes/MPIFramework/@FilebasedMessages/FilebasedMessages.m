classdef FilebasedMessages < iMessagesFramework
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
        % Properties of a job dispatcher:
        % the full path to the folder where the exchange configuration is stored
        exchange_folder;
        % Time in seconds a system waits for blocking message intil
        % returning "not-received"
        time_to_fail;
    end
    %----------------------------------------------------------------------
    properties(Constant=true)
        % the name of the folder where the configuration is stored;
        exchange_folder_name='mprogs_config';
    end
    %----------------------------------------------------------------------
    properties(Access=protected)
        % folder where the messages are located
        exchange_folder_;
        %TODO: time in seconds to waiting in blocking message until
        %unblocking.
        time_to_fail_ = 1000;
    end
    %----------------------------------------------------------------------
    methods
        %
        function jd = FilebasedMessages(varargin)
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
            % Filebased messages frimework creates the exchange folder with
            % the filename specified as input.
            %
            % Initialise folder path
            jd = jd@iMessagesFramework();
            if nargin>0
                jd.job_id = varargin{1};
            end
            root_cf = make_config_folder(FilebasedMessages.exchange_folder_name);
            job_folder = fullfile(root_cf,jd.job_id);
            if ~exist(job_folder,'dir')
                [ok, mess] = mkdir(job_folder);
                if ~ok
                    error('FILEMESSAGES_FRAMEWORK:runtime_error',...
                        'Can not create control folder %s\n  Error message: %s',...
                        root_cf,mess);
                end
            end
            jd.exchange_folder_ = job_folder;
            
        end
        function folder = get.exchange_folder(obj)
            % return job control files prefix
            folder  = obj.exchange_folder_;
        end
        %
        
        %------------------------------------------------------------------
        function fn = mess_name(obj,task_id,mess_name)
            % Fully qualified name of the task status message, which allows
            % to identify message in the system. For filebased messages this
            % is the name of the message file
            fn = obj.job_stat_fname_(task_id,mess_name);
        end

        function [ok,err_mess] = send_message(obj,task_id,message)
            % send message to a task with specified id
            % Usage:
            % >>mf = MessagesFramework();
            % >>mess = aMessage('mess_name')
            % >>[ok,err_mess] = mf.send_message(1,mess)
            % >>ok  if true, says that message have been successfully send to a
            % >>    task with id==1. (not received)
            % >>    if false, error_mess indicates reason for failure
            %
            [ok,err_mess] = send_message_(obj,task_id,message);
        end
        %
        function [ok,err_mess,message] = receive_message(obj,varargin)
            % receive message from a task with specified id
            % Usage:
            % >>mf = MessagesFramework();
            % >>mess = aMessage(1,'mess_name')
            % >>[ok,err_mess] = mf.send_message(1,mess)
            % >>ok  if true, says that message have been successfully
            %       received from task with id==1.
            % >>    if false, error_mess indicates reason for failure
            % >> on success, message contains an object of class aMessage,
            %    with message contents
            %
            [ok,err_mess,message] = receive_message_(obj,varargin{:});
        end
        %
        function is = is_job_cancelled(obj)
            % method verifies if job has been cancelled
            if ~exist(obj.exchange_folder,'dir')
                is=true;
            else
                is=false;
            end
        end
        %
        function [all_messages_names,task_ids] = probe_all(obj,varargin)
            % list all messages existing in the system for the tasks
            % with id-s specified as input
            %Input:
            %task_ids -- array of task id-s to check messages for
            %Return:
            % cellarray of strings, containing message names for the requested
            % tasks.
            % if no message for a job is present in the systen,
            %its cell remains empty
            %
            [all_messages_names,task_ids] = list_all_messages_(obj,varargin{:});
        end
        %
        function [all_messages,task_ids] = receive_all_messages(obj,varargin)
            % retrieve (and remove from system) all messages
            % existing in the system for the tasks with id-s specified as input
            %
            %Input:
            %task_ids -- array of task id-s to check messages for
            %Return:
            % all_messages -- cellarray of messages for the tasks requested and
            %                 have messages availible in the system .
            %task_ids       -- array of task id-s for these messages
            %
            %
            [all_messages,task_ids] = receive_all_messages_(obj,varargin{:});
        end
        %------------------------------------------------------------------
        function cs  = init_worker_control(obj,task_id)
            % function to initiate worker's control structure, necessary to
            % initiate jobExecutor
            css = MessagesFramework.worker_job_info(task_id,obj.job_id);
            cs  = iMessagesFramework.serialize_par(css);
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
        function mess_fname = job_stat_fname_(obj,task_id,mess_name)
            %build filename for a specific message
            mess_fname= fullfile(obj.exchange_folder,...
                sprintf('mess_%s_TaskN%d.mat',mess_name,task_id));
            
        end
    end
    methods(Static)
        
    end
end

