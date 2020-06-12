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
                obj=construct_me_folder_(obj,val);
                return;
            end
            
            if strcmp(val,obj.mess_exchange_folder) % the same folder have been already set-up nothing to do
                return;
            end
            % We are setting new folder so should delete old message exchange folder if one exist
            if exist(obj.mess_exchange_folder,'dir') == 7
                rmdir(obj.mess_exchange_folder,'s');
            end
            obj=construct_me_folder_(obj,val);
            
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
            [ok,err_mess,wlock_obj] = send_message_(obj,task_id,message);
        end
        %
        function [ok,err_mess,message] = receive_message(obj,varargin)
            % receive message from a task with specified id.
            %
            % Blocking  or unblocking behavior depends on requested message
            % type.
            %
            % If the requested message type is blocking, blocks until the
            % message is available
            % if it is unblocking, return empty message if appropriate message
            % is not present in system
            % There is possibility directly ask for blocking or unblocking
            % behavior.
            %
            % Usage:
            % >>mf = MessagesFramework();
            % >>[ok,err_mess,message] = mf.receive_message(id,mess_name, ...
            %                           ['-synchronous'|'-asynchronous'])
            % or:
            % >>[ok,err_mess,message] = mf.receive_message(id,'any', ...
            %                           ['-synchronous'|'-synchronous'])
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
        %
        function [all_messages_names,task_ids] = probe_all(obj,varargin)
            % list all messages existing in the system with id-s specified as input
            % and intended for this task
            %
            %Usage:
            %>> [mess_names,task_ids] = obj.probe_all([task_ids],[{mess_name,mess_tag}]);
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
            if nargin>2 && ((ischar(varargin{2}) && ~strcmp(varargin{2},'any')) || ...
                    (isnumeric(varargin{2}) && varargin{2} ~=-1))
                % performance boosting operation, especially important for
                % Windows, as dir locks message files there.
                if ischar(varargin{1}) && strcmp(varargin{1},'any')
                    warning('Outdated receive interface -- keyword all should be used')
                    varargin{1} = 'all';
                end
                [all_messages_names,task_ids] = list_specific_messages_(obj,varargin{:});
            else
                [all_messages_names,task_ids] = list_all_messages_(obj,varargin{:});
            end
        end
        %
        function [all_messages,task_ids] = receive_all(obj,varargin)
            % retrieve (and remove from system) all messages
            % existing in the system for the tasks with id-s specified as input
            % Blocks execution until the all requested messages are received
            % if the message names are provided and unblocking if they are
            % absent
            %
            %Input:
            %task_ids -- array of task id-s to check messages for
            %
            %Return:
            % all_messages -- cellarray of messages for the tasks requested and
            %                 have messages available in the system .
            % task_ids     -- array of task id-s for these messages
            % mess_name    -- if present, receive only the messages with
            %                 the name provided
            %
            %
            if nargin>1 && ischar(varargin{1})
                if strcmp('any',varargin{1})
                    warning('Outdated receive all interface. Use all instead of any')
                    varargin{1} = 'all';
                end
            end
            
            [all_messages,task_ids] = receive_all_messages_(obj,varargin{:});
        end
        %
        function finalize_all(obj)
            % delete all messages belonging to this instance of messages
            % framework and delete the framework itself
            obj.persistent_fail_message_ = [];
            delete_job_(obj);
        end
        
        function clear_messages(obj)
            % Clear all messages directed to this lab.
            obj.clear_all_messages_();
        end
        %
        function [ok,err]=labBarrier(obj,nothrow)
            if ~exist('nothrow','var')
                nothrow = false;
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
        function fn = mess_file_name(obj,task_id,mess_name)
            % Generates the name of the messages file.
            %
            % Inputs:
            % mess_name -- the string-name of the message, written to the
            %              file system
            % task_id -- is the id (number) of the task this message should
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
            if ~isnumeric(task_id)
                error('MESSAGES_FILEBASED:invalid_argument',...
                    'first message_name argument should be the target task number');
            end
            fn = obj.job_stat_fname_(task_id,mess_name);
        end
    end
    %----------------------------------------------------------------------
    methods (Access=protected)
        function mess_fname = job_stat_fname_(obj,lab_to,mess_name,lab_from)
            %build filename for a specific message
            if ~exist('lab_from','var')
                lab_from = obj.labIndex;
            end
            mess_fname= fullfile(obj.mess_exchange_folder,...
                sprintf('mess_%s_FromN%d_ToN%d.mat',...
                mess_name,lab_from,lab_to));
            
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
        function [top_exchange_folder,mess_subfolder] = build_exchange_folder_name(obj,top_exchange_folder )
            % build the name of the folder used to exchange messages
            % between the base node and the MPI framework and, if
            % necessary, filebased messages
            if ~exist('top_exchange_folder','var')
                top_exchange_folder = config_store.instance().config_folder;
            end
            [top_exchange_folder,mess_subfolder] = constr_exchange_folder_name_(obj,top_exchange_folder);
        end
        
        
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
        
        function [start_queue_num,free_queue_num]=list_queue_messages(obj,mess_name,send_from,sent_to)
            % process list of the messages already sent from this routine and placed in
            % a queue and return the numbers of the first message in the queue and
            % the number of the  first free place in the queue
            %
            % Inputs:
            % mess_name   -- the name of the messages in the queue
            % send_from   -- the number of job (lab) the messages should be send
            % sent_to     -- the number of job (lab) the messages should be directed.
            % Outputs:
            % start_queue_num -- the number of the first message to pop from the queue.
            % free_queue_num  -- the number of the free space in the queue, i.e. the
            %                    next message to pop in the queue.
            
            [start_queue_num,free_queue_num]=...
                list_queue_messages_(obj.mess_exchange_folder,obj.job_id,mess_name,send_from,sent_to);
        end
        
    end
end
