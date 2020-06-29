classdef MessagesFilebased < iMessagesFramework
    % The class providing file-based message exchange functionality for Herbert
    % distributed jobs framework.
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
    properties(Dependent)
        % The folder located on a parallel file system and used for storing
        % initial job info and message exchange between tasks if job uses
        % filebased messages.
        mess_exchange_folder;
        
    end
    properties(Constant=true)
        % the name of the sub-folder where the remote jobs information is stored;
        exchange_folder_name='Herbert_Remote_Job';
    end
    
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    properties(Access=protected)
        % time to wait before checking for next blocking message if
        % previous attempt have not find it.
        time_to_react_ = 1; % (sec)
        %
        % equivalent to labNum in MPI
        task_id_ = 0;
        %
        numLabs_ = 1;
        %
        mess_exchange_folder_ = '';
        % if true, enable debug printout
        DEBUG_ = false;
        % true if framework is tested, i.e. running on single session, not
        % really communicating with with independent workers.
        is_tested_ = false;
        
        % the buffer to count send and receive data messages, Used to keep
        % information about number of synchronous data messages send and
        % received.
        send_data_messages_count_;
        receive_data_messages_count_;
    end
    %----------------------------------------------------------------------
    methods
        %
        function jd = MessagesFilebased(varargin)
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
            %
            % Initialise folder path
            jd = jd@iMessagesFramework();
            if nargin>0
                jd = jd.init_framework(varargin{:});
            end
            
        end
        
        %------------------------------------------------------------------
        %
        function  obj = init_framework(obj,framework_info)
            % using control structure initialize operational message
            % framework
            obj = init_framework_(obj,framework_info);
        end
        %
        function folder = get.mess_exchange_folder(obj)
            folder  = obj.mess_exchange_folder_;
        end
        %
        function obj=set_framework_range(obj,labNum,NumLabs)
            % The function to set numLab and labId describing framework
            % extend during initialization procedure.
            %
            % Also used independently to set up slave file-based framework,
            % in the case when main data exchange framework between nodes
            % is an MPI-based framework
            obj.task_id_ = labNum;
            obj.numLabs_ = NumLabs;
            obj.send_data_messages_count_ = ones(1,NumLabs+1);
            obj.receive_data_messages_count_ = ones(1,NumLabs+1);
            
        end
        %
        function set.mess_exchange_folder(obj,val)
            % set message exchange folder for filebased messages exchange
            % within Herbert/Horace configuration folder
            % and copy Herbert/Horace configurations to new configuration
            % folder if this folder location differs from the default configuration
            % location (for using on remote machines)
            if ~ischar(val)
                error('iMessagesFramework:invalid_argument',...
                    'message exchange folder should be a string');
            end
            
            if isempty(obj.mess_exchange_folder)
                construct_me_folder_(obj,val);
                return;
            end
            
            if strcmp(val,obj.mess_exchange_folder) % the same folder have been already set-up nothing to do
                return;
            end
            % We are setting new folder so should delete old message exchange folder if one exist
            if exist(obj.mess_exchange_folder,'dir') == 7
                rmdir(obj.mess_exchange_folder,'s');
            end
            construct_me_folder_(obj,val);
            
        end
        %------------------------------------------------------------------
        % MPI interface
        %
        %
        function [ok,err_mess,wlock_obj] = send_message(obj,task_id,message)
            % send message to a task with specified id
            %
            % Usage:
            % >>mf = MessagesFramework();
            % >>mess = aMessage('mess_name')
            % >>[ok,err_mess] = mf.send_message(1,mess)
            % >>ok  if true, says that message have been successfully send to a
            % >>    task with id==1. (not received)
            % >>    if false, error_mess indicates reason for failure
            %
            %
            [ok,err_mess,wlock_obj] = send_message_(obj,task_id,message);
        end
        %
        function [ok,err_mess,message] = receive_message(obj,varargin)
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
            % >>ok  if MPI_err.ok, message have been successfully
            %       received from task with the specified id.
            % >>    if not, error_mess and error code indicates reasons for
            %       failure.
            % >> on success, message contains an object of class aMessage,
            %        with the received message contents.
            %
            [ok,err_mess,message] = receive_message_(obj,varargin{:});
        end
        %
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
            %
            if nargin<2
                task_ids_in = 'all';
            end
            if nargin<3
                mess_name = 'any';
            end
            if isempty(mess_name)
                mess_name = 'any';
            end  
            
            if ((ischar(mess_name) && ~strcmp(mess_name,'any')) || ...
                    (isnumeric(mess_name) && mess_name ~=-1))
                % performance boosting operation, especially important for
                % Windows, as dir locks message files there.
                [all_messages_names,task_ids] = list_specific_messages_(obj,task_ids_in,mess_name);
            else % any message
                [all_messages_names,task_ids] = list_all_messages_(obj,task_ids_in,mess_name);
            end
            [mess,id_from] = obj.get_interrupt(task_ids_in);
            % mix received messages names with old interrupt names received earlier
            if ~isempty(mess)
                if ~iscell(mess); mess = {mess}; end
                int_names = cellfun(@(x)(x.mess_name),mess,'UniformOutput',false);
                [all_messages_names,task_ids] = ...
                    obj.mix_messages(all_messages_names,task_ids,int_names,id_from);
            end
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
            if nargin<2
                task_ids = 'all';
            end
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
            % delete all messages belonging to this instance of messages
            % framework and delete the framework itself
            obj.persistent_fail_message_ = [];
            delete_job_(obj);
        end
        %
        function clear_messages(obj)
            % Clear all messages directed to this lab.
            clear_all_messages_(obj);
        end
        %
        function [ok,err]=labBarrier(obj,nothrow)
            if ~exist('nothrow','var')
                nothrow = false;
            end
            if obj.is_tested % no blocking in testing mode
                ok = true;
                err = [];
                return;
            end
            [ok,err]=wait_at_barrier_(obj,nothrow);
        end
        %
        function is = is_job_canceled(obj)
            % method verifies if job has been canceled
            is = ~exist(obj.mess_exchange_folder_,'dir') || ...
                ~isempty(obj.probe_all('all','canceled'));
        end
        %------------------------------------------------------------------
        % Filebased framework specific properties:
        %
        function fn = mess_file_name(obj,lab_to,mess_name,varargin)
            % Generates the name of the messages file.
            %
            % Inputs:
            % mess_name -- the string-name of the message, written to the
            %              file system
            % lab_to   -- is the id (number) of the task this message should
            % be send
            %
            % Returns:
            % The name of the message file, which allows
            % to identify message on the file system system and its source
            % and target workers.
            %
            % Used mainly for debugging purposes to see how messages
            % are propagated
            %
            if ~isnumeric(lab_to)
                error('MESSAGES_FILEBASED:invalid_argument',...
                    'first message_name argument should be the target task number');
            end
            fn = obj.job_stat_fname_(lab_to,mess_name,varargin{:});
        end
        %
        function set_is_tested(obj,is_tested)
            % method, used in tests to set is_tested mode to framework.
            % In test mode, barrier operation is disabled
            %
            % Inputs:
            % is_tested  logical value, setting test mode on (true) or off
            %            (false)
            %
            %
            obj.is_tested_ = logical(is_tested);
        end
    end
    %----------------------------------------------------------------------
    methods (Access=protected)
        function mess_fname = job_stat_fname_(obj,lab_to,mess_name,lab_from,varargin)
            %build filename for a specific message
            % Inputs:
            % lab_to    -- the address of the lab to send message to.
            % mess_name -- the name of the message to send
            % lab_from  -- if present, the number of the lab to send
            %              message from, if not there, from this lab
            %              assumed
            % sender     -- make sence for data messages only, as they
            %               have to be numbered, and each send must meet
            %               its receiver.
            %               if true, defines data message name for sender.
            %               false - for received.
            if ~exist('lab_from','var')
                lab_from = obj.labIndex;
            end
            if nargin < 5
                is_sender = true;
            else
                is_sender = varargin{1};
            end
            mess_fname = MessagesFilebased.mess_fname_(obj,lab_to,mess_name,lab_from,is_sender);
        end
        %
        function    [receive_now,message_names_array,n_steps] = check_whats_coming(obj,task_ids,mess_name,mess_array,n_steps)
            % Service function to check what messages will be arriving during next step waiting in
            % synchroneous mode
            %
            % part of receive_all messages function used in synchroneous messages receive operations.
            % Extractced for unit testing as accessable only from parallel
            % code otherwise
            %
            % Inputs:
            % task_ids -- all lab-nums to receive messages from.
            % mess_name-- the name of the message to check for.
            % mess_array    -- cellarray of size(task_ids) where already received
            %                  messages are stored and not-received messages are
            %                  represented by empty cells
            % mess_received -- boolean array of size task_ids, indicating if some messages
            %                  from the labs requested  have already arrived and
            %                  receieved
            % Returns:
            % receive_now    -- boolean array of size task_ids, where true indicates
            %                   that message from correspondent task id is present and
            %                   can be read.
            % message_names_array -- cellarray of message names to read
            %                    now. 
            %
            [receive_now,message_names_array,n_steps] = check_whats_coming_(obj,task_ids,mess_name,mess_array,n_steps);
        end
        %
        function obj = set_job_id_(obj,new_job_id)
            %
            if is_string(new_job_id) && ~isempty(new_job_id)
                % message exchange folder name is defined on the basis
                % of a job_id. As old job_id is available only here,
                % one needs to deal with old message exchange folder too.
                old_id = obj.job_id_;
                obj.job_id_ = new_job_id;
                if ~isempty(obj.mess_exchange_folder_)
                    old_exchange = obj.mess_exchange_folder_;
                    [fp,fs] = fileparts(obj.mess_exchange_folder_);
                    if strcmpi(fs,old_id)
                        obj.mess_exchange_folder_ = fullfile(fp,new_job_id);
                        if exist(old_exchange,'dir') == 7
                            rmdir(old_exchange,'s');
                        end
                    end
                end
                
            else
                error('MESSAGES_FILEBASED:invalid_argument',...
                    'MPI job id has to be a string');
            end
        end
        %
        function [top_exchange_folder,mess_subfolder] = build_exchange_folder_name(obj,top_exchange_folder )
            % build the name of the folder used to exchange messages
            % between the base node and the MPI framework and, if
            % necessary, filebased messages
            if ~exist('top_exchange_folder','var')
                top_exchange_folder = config_store.instance().config_folder;
            end
            [top_exchange_folder,mess_subfolder] = constr_exchange_folder_name_(obj,top_exchange_folder);
        end
        %
        function ind = get_lab_index_(obj)
            ind = obj.task_id_;
        end
        function ind = get_num_labs_(obj)
            ind = obj.numLabs_;
        end
        function is = get_is_tested(obj)
            % return true if the framework is tested (Running on single
            % Matlab session)
            is = obj.is_tested_;
        end
    end
    methods(Static,Access=protected)
        function mess_fname = mess_fname_(obj,lab_to,mess_name,lab_from,is_sender)
            % Build filename for a specific message.
            % Inputs:
            % lab_to    -- the address of the lab to send message to.
            % mess_name -- the name of the message to send
            % lab_from  -- if present, the number of the lab to send
            %              message from, if not there, from this lab
            %              assumed
            % is_sender     -- make sence for data messages only (blocking messages)
            %               , as they  have to be numbered, and each send
            %               must meet its receiver without overtaking.
            %
            %               if true, defines data message name for sender.
            %               false - for received.
            % Returns
            if MESS_NAMES.is_blocking(mess_name)
                if is_sender
                    mess_num = obj.send_data_messages_count_(lab_to+1);
                else %receiving
                    mess_num = obj.receive_data_messages_count_(lab_from+1);
                end
                mess_fname = fullfile(obj.mess_exchange_folder,...
                    sprintf('mess_%s_FromN%d_ToN%d_MN%d.mat',...
                    mess_name,lab_from,lab_to,mess_num));
            else
                mess_fname= fullfile(obj.mess_exchange_folder,...
                    sprintf('mess_%s_FromN%d_ToN%d.mat',...
                    mess_name,lab_from,lab_to));
            end
        end
        
    end
end
