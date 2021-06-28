classdef iMessagesFramework < handle
    % Interface for messages in Herbert distributed jobs framework
    %
    % Defines generic interface a Horace program can use to exchange messages
    % between jobs running either in separate Matlab sessions or in Matlab
    % workers.
    % Also contains auxiliary methods and basic operations used by all
    % Herbert MPI frameworks to set up and run remote jobs.
    %
    %----------------------------------------------------------------------
    properties(Dependent)
        % job ID  used to identify job control messages
        % intended for a particular MPI job. The folder with this
        % name is created in shared location to keep initial job settings
        % and transfer progress messages from cluster to the user's node.
        job_id;

        % returns the index of the worker currently executing the function.
        % labIndex is assigned to each worker when a job begins execution,
        % and applies only for the duration of that job.
        % The value of labIndex spans from 1 to n, where n is the number of
        % workers running the current job, defined by numlabs. Index 0
        % reserved for interactive user's node.
        labIndex;

        % Number of independent workers used by the framework
        numLabs;

        % return true if the framework is tested
        is_tested

        % Time in seconds a system waits for blocking message until
        % returning "not-received" (and normally throwing error)
        time_to_fail;
        %
        % The property defines framework behavior in case when interrupt
        % message (cancelled or failed) received through the network.
        % Normally this means that
        % all processing would be completed and worker shut-down so
        % exception would be thrown. When the framework is gathering
        % information on exceptions to report issue to user,
        % interrupt messages are received to be processed by framework to
        % return the diagnostics to users.
        % The property in this case is set to false.
        throw_on_interrupts
    end
    properties(Access=protected,Hidden=true)
        % The string, uniquely identifying the running job.
        job_id_;

        % time in seconds to waiting in blocking message until
        % unblocking or failing. Does not work for some operations in some frameworks
        % (e.g. receive_message in mpi)
        time_to_fail_ = 300; %(sec)
        % time to wait between subsequent attempts to repeat command, related to a
        % a message exchange
        time_to_react_ = 0.1

        % The holder for persistent messages, used to mark special job states
        % (e.g. completion or failure) for a particular worker (lab)
        % if the variable is not empty, a special event happened, so the
        % worker would operate differently.
        persistent_fail_message_=[];
        % if true, enable debug printout
        DEBUG_ = false;
        % it true, throws on receiving interrupt message. If false, the
        % interrupt message is received and delivered as output of
        % receive_message function.
        throw_on_interrupts_ =  true;

        % interrupt channel name:
        interrupt_chan_name_;
        % the tag of the interrupt channel
        interrupt_chan_tag_ = 100; % let's take it definitively bigger then
        % other message tag defined in the system
    end
    properties(Hidden=true)
        % in debug mode, parallel worker assigns to this property
        % open file handle to do logging.
        ext_log_fh=[];
    end

    methods
        function obj = iMessagesFramework(varargin)
            % default prefix is srting build from the number consisting of
            % 10 digits processID + 3 digits integer, build from
            % current number of seconds
            if nargin>0
                obj.job_id = varargin{1};
            else
                obj.job_id_ = iMessagesFramework.get_framework_id();
            end
            obj.interrupt_chan_name_ = MESS_NAMES.interrupt_channel_name;
        end
        %------------------------------------------------------------------
        % SETTERS/GETTERS       *****
        %------------------------------------------------------------------
        %
        function id = get.job_id(obj)
            id = obj.job_id_;
        end
        %
        function set.job_id(obj,val)
            % set the string uniquely defining job name.
            set_job_id_(obj,val);
        end
        %
        function ind = get.labIndex(obj)
            ind = get_lab_index_(obj);
        end
        %
        function ind = get.numLabs(obj)
            ind = get_num_labs_(obj);
        end
        %
        function is = get.is_tested(obj)
            is = get_is_tested(obj);
        end
        %
        function set.time_to_fail(obj,val)
            obj.time_to_fail_ = val;
        end
        %
        function val = get.time_to_fail(obj)
            val = obj.time_to_fail_ ;
        end
        %
        function set.throw_on_interrupts(obj,val)
            obj.throw_on_interrupts_ = logical(val);
        end
        %
        function do = get.throw_on_interrupts(obj)
            do = obj.throw_on_interrupts_;
        end
        %------------------------------------------------------------------
        %
        function cs = get_worker_init(obj,intercom_name,labID,numLabs,varargin)
            % Generate slave MPI worker init info, using static
            % build_worker_init method and information, retrieved from
            % the initialized control node.
            %
            % The information used on the stage 1 of the worker
            % initialization procedure, when the communication channels
            % between workers and the worker and the control node are
            % established.
            %
            % Usage:
            % cs = obj.get_worker_init(intercom_name) % -- for real MPI worker
            % or
            % cs = obj.get_worker_init(intercom_name,labId,numLabs) % for Herbert MPI
            %                                          worker
            % cs = obj.get_worker_init(___,test_mode)
            %                     for MPI worker, initialized
            %                     in test mode, i.e. barrier is not deployed.
            %
            % if test_mode is character string, testing is enabled and the
            % output is serialized. If its Boolean, testing is enabled but
            % if the output is serialized defined if its true (serialized)
            % or false (initialization structure is returned)
            %
            %
            % where
            % obj          --  an initiated instance of message exchange
            %                  framework on a head-node and
            % intercom_name -- the name of the framework, used
            %                  to exchange messages between workers
            % labId         -- labIndex if present, defines the number of
            %                  Herbert pseudo MPI worker to initiate
            % numLabs       -- if present, total  number of Herbert pseudo MPI
            %                  workers in the pool.
            %
            %
            datapath = fileparts(fileparts(fileparts(obj.mess_exchange_folder)));
            if exist('labID', 'var') % Herbert MPI worker. numlabs and labNum are defined by configuration
                if nargin> 4
                    if ischar(varargin{1})
                        test_with_serialation = false;
                    else
                        test_with_serialation = logical(varargin{1});
                    end
                    cs = obj.build_worker_init(...
                        datapath,obj.job_id,intercom_name,labID,numLabs,test_with_serialation);

                else
                    cs = obj.build_worker_init(...
                        datapath,obj.job_id,intercom_name,labID,numLabs);
                end
            else  % real MPI worker (numLabs and labNum are defined by MPIexec
                cs = obj.build_worker_init(...
                    datapath,obj.job_id,intercom_name);
            end
        end
        %
        function set_interrupt(obj,mess,source_address)
            % check if the input message is an interrupt message
            % and if the message is an interrupt,
            % set it as framework output until the task is completed
            % or aborted.
            %
            % Interrupt message is the message describing a state
            % of the source which persists until the current job
            % is completed or aborted.

            set_interrupt_(obj,mess,source_address);
        end
        %
        function [mess,id_from] = get_interrupt(obj,source_address)
            % check if an interrupt message has been received from any of the
            % source addresses and return such messages.
            %
            % Interrupt message is the message describing a state
            % of the source which persists until the current job
            % is completed or aborted.
            %
            % Input:
            % source_address -- the array of addresses to check for sources
            %                   of the persistent messages
            % Returns:
            % mess    -- cellarray of interrupt messages returned from all
            %            or some sources requested
            % id_from -- array of the addresses which have previously
            %            generated interrupt messages, stored within the
            %            framework
            [mess,id_from] = get_interrupt_(obj,source_address);
        end
        %
        function [all_messages,mid_from] = retrieve_interrupt(obj,...
                all_messages,mid_from,mes_addr_to_check)
            % Helper method used to add interrupt (persistent) messages
            % to the list of the messages, received from other labs.
            %
            % If both messages are received from the same worker, override
            % other message with the persistent message.
            % Inputs:
            % all_messages -- cellarray of messages to mix with persistent
            %                 messages.
            % mid_from     -- array of the workers id-s (labNums) where
            %                 these messages can be received.
            % mes_addr_to_check -- array of labNums to check for presence
            %                 of persistent messages
            % Return:
            % all_messages  -- cellarray of the all present message names,
            %                  persistent and not
            % mid_from      -- array of labNum-s sending these messages.
            %
            [all_messages,mid_from] = retrieve_interrupt_(obj,...
                all_messages,mid_from,mes_addr_to_check);
        end
        %
        function clear_interrupt(obj,task_id)
            % method clears interrupt, receved from task_id (labIndex)
            % provided as input
            if isempty(obj.persistent_fail_message_)
                return;
            end
            if isKey(obj.persistent_fail_message_,int32(task_id))
                remove(obj.persistent_fail_message_,int32(task_id));
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
            % Asking a server for a message synchronously, blocks the
            % client until this message is send by server.
            %
            % FailureMessage and CancelledMessage (is_persistent=true)
            % if send, are received and returned instead of the
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
            %              receiving rules and receive the message.
            %              block program execution if '-synchronous' keyword
            %              is provided, or continue execution if message has
            %              not been send ('-asynchronous' mode).
            %Return:
            % all_messages - cellarray of messages for the tasks requested and
            %                have messages available in the system.
            %task_ids      - array of task id-s where these messages were
            %                received from.
            %                in asynchronous mode, size(task_ids) at output
            %                may be smaller then the size(task_ids) at input.
            %
            if nargin<2
                task_ids = 'all';
            end
            [all_messages,task_ids] = receive_all_messages_(obj,task_ids,varargin{:});
        end
        %
        function [ok,err_mess,message] = receive_message(obj,from_task_id,varargin)
            %
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
            % Asking a server for a message synchronously, may block a
            % client if other type of message has been send by server.
            % Exception are interrupt messages (is_persistent==true), which, if send,
            % will be received in any circumstances.
            %
            % Usage:
            % >>mf = MessagesFramework();
            % >>[ok,err_mess,message] = mf.receive_message(id,mess_name, ...
            %                           ['-synchronous'|'-asynchronous'])
            % or:
            % >>[ok,err_mess,message] = mf.receive_message(id,'any', ...
            %                           ['-synchronous'|'-asynchronous'])
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

            % call common function to check and validate inputs
            [from_task_id,mess_name,is_blocking]=obj.check_receive_inputs(from_task_id,varargin{:});
            %
            [ok,err_mess,message] = obj.receive_message_internal(from_task_id,mess_name,is_blocking);
        end
        function names= get_node_names(obj)
            % Return list of node names, participating in the pool
            names = cell(obj.numLabs,1);
            for i=1:obj.numLabs
                names{i} = ['Node',num2str(i)];
            end
        end
    end

    methods(Static)
        function cs = build_worker_init(path_to_data_exchange_folder,jobID,...
                intercom_name,labID,numLabs,test_mode)
            % prepare data necessary to initialize a MPI worker and
            % serialize them into the form, acceptable for transfer through
            % any system's inter-process pipe
            %
            % Usage:
            %>> cs =iMessagesFramework.build_worker_init(...
            %       path_to_data_exchange_folder,[labID,numLabs])
            % Where:
            % path_to_data_exchange_folder -- the path on a remote machine
            %                                 where the file-based messages
            %                                 and initiation information
            %                                 should be distributed
            % jobID          - the name of the parallel job to run
            %
            % intercomm_name - the name of the parallel framework, used to
            %                  exchange messages between the workers.
            % Optional:
            % if inter-worker communication framework is filebased
            % framework, these two parameters define addresses of the
            % workers in this framework. For proper MPI framework these
            % values should not be provided
            %
            % labID     -- the worker id, used  as MPI labId for filebased
            %              messages.
            % numLabs   -- number of independent workers, used by filebased
            %              MPI job. If labID is defined, numLabs has to
            %              be defined too.
            % test_mode -- if true, generates the structure, used to
            %              initialize CppMpi framework in test mode
            %              In this case, the messages is not
            %              serialized. Can be defined only if labID
            %              and numLabs are defined
            % Returns:
            % base64-coded and mapped to ASCII 128 symbols linear
            % representation of the information, necessary to initialize
            % MPI worker operating with any Herbert cluster
            %
            % if test_mode is true, no encoding is performed and the
            % initialization structure is returned as it is.
            %
            cs = struct('data_path',path_to_data_exchange_folder,...
                'job_id',jobID,...
                'intercomm_name',intercom_name);
            serialize_message = true;
            if exist('labID', 'var')
                cs.labID   = labID;
                cs.numLabs = numLabs;
                if exist('test_mode', 'var')
                    serialize_message = ~test_mode;
                    cs.test_mode = true;
                end
            end
            if serialize_message
                cs = iMessagesFramework.serialize_par(cs);
            end
        end
        %
        function params = deserialize_par(par_string)
            % function restores structure or class from a string
            % representation, build to allow transfer through standard
            % system pipe
            %
            par_string = strrep(par_string,'-','=');
            y = uint8(strrep(par_string,'_','/'));
            %import com.mathworks.mlwidgets.io.InterruptibleStreamCopier
            %a=java.io.ByteArrayInputStream(y);
            %b=java.util.zip.InflaterInputStream(a);
            %isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
            %c = java.io.ByteArrayOutputStream;
            %isc.copyStream(b,c);
            %y=typecast(c.toByteArray,'uint8');

            base64 = org.apache.commons.codec.binary.Base64;
            y = base64.decode(y);
            iarr = uint8(mod(int16(y),256)); % convert from int8 to uint8, wrapping negatives back into 255 range
            params  =  deserialise(iarr);
        end
        %
        function [par,mess] = serialize_par(param)
            % convert a structure or class into a string representation
            % which allows transfer through standard system pipe
            %
            % (e.g. serialize job parameters in a way, to be able to
            % transfer it to other Matlab session
            %
            mess = '';
            par = '';
            try
                v = serialise(param)';
            catch ME
                mess = ME.message;
                return
            end
            %f=java.io.ByteArrayOutputStream();
            %g=java.util.zip.DeflaterOutputStream(f);
            %g.write(v);
            %g.close;
            %v=typecast(f.toByteArray,'uint8');
            %f.close;
            base64 = org.apache.commons.codec.binary.Base64;
            v = base64.encodeBase64(v, false);
            v = char(v)';
            v = strrep(v,'=','-');
            par = strrep(v,'/','_');
        end
        %
    end

    methods(Static,Access=protected)
        function id = get_framework_id()
            % get random ID for messaging framework
            % use process ID and time as job ID. This prevents clashes
            % between processes.
            % the id is a string representation of 10 digit-pid
            % + added 3 digit number of current seconds.
            %
            % Ensure pid contans 10 digits. Complement it with 0 at the end
            % if it contans less digits  or trunkate extra digits if has
            % more
            pid = feature('getpid');
            mod = round(log10(pid))+1;
            delta =10-mod;
            pid  = round(pid*10^delta);

            id = sprintf('%i',pid+round(datetime('now').Second*10));
        end
        %
        function is_blocking = check_is_blocking(mess_name,options)
            % helper function used to check if the requested message should
            % be processed synchronously or asynchronously.
            %
            %
            if isempty(options)
                is_blocking = MESS_NAMES.is_blocking(mess_name);
                return
            end
            [ok,mess,synch,asynch]=parse_char_options(options,{'-synchronous','-asynchronous'});
            if ~ok
                error('MESSAGES_FRAMEWORK:invalid_argument',mess);
            end
            if synch && asynch
                error('MESSAGES_FRAMEWORK:invalid_argument',...
                    'Both -synchronous and -asynchronous options are provided as input. Only one is allowed');
            end
            if synch
                is_blocking = true;
            elseif asynch
                is_blocking = false;
            else
                is_blocking = MESS_NAMES.is_blocking(mess_name);
            end
        end
        %
        function [messages,tid_from] = mix_messages(messages,tid_from,add_mess,tid_add_from)
            % helper function to add more messages to the list of existing messages
            %
            % Used to add interrupts to list of existing messages.
            % the additional messages overwrite the old one if have the same task id-s
            % Inputs:
            % messages -- cellarray of objects
            % tid_from -- numeric array of indexes, indicating where the
            %             objects are obtained from.
            %             Requested size(messages) == size(tid_from);
            % add_mess -- cellarray of additional objects
            % tid_add_from -- array of indexes, inticating where additional
            %                 objects have arrived from. The values may
            %                 coinside withsome or all indexes from
            %                 tid_from.
            %             Requested size(add_mess) == size(tid_add_from);
            % Returns
            % messages  -- cellarray of objects, combined from messages and
            %              add_mess celarrays
            % tid_from  -- unique indexes, sources of objects in messaves
            %              celarray
            % if some indexes in tid_from coinside with indexes from
            % tid_add_from, the values in correspondent cells of outipt messages
            % are replaced by correspondent values from  add_mess;
            %
            [messages,tid_from] = mix_messages_(messages,tid_from,add_mess,tid_add_from);
        end
    end
    methods(Abstract)
        %------------------------------------------------------------------
        % Job control interface
        %
        % initialize message framework
        % framework_info -- data, necessary for framework to operate and
        % do message exchange.
        init_framework(obj,framework_info)

        %------------------------------------------------------------------
        % MPI interface
        %
        % send message to a task with specified id
        % Usage:
        % >>mf = MessagesFramework();
        % >>mess = aMessage('mess_name')
        % >>[ok,err_mess] = mf.send_message(1,mess)
        % >>ok  if MPI_err.ok, the message have been successfully send to a
        % >>    task with id==1. (not received)
        % >>    if other value, error_code and error_mess provide additional
        %       information for the failure
        [ok,err_mess] = send_message(obj,task_id,message)


        % list all messages existing in the system from the tasks
        % with id-s specified as input
        %Input:
        %task_ids -- array of task id-s to check messages for
        %Return:
        % cellarray of strings, containing message names for the requested
        % tasks.
        % if no message for a task is present in the system,
        % its cell remains empty
        % if task_id list is empty or missing, returns all existing
        % messages
        [all_messages_names,task_ids] = probe_all(obj,task_ids,mess_names)

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
        % Asking a server for a message synchronously will block a
        % client if other type of message has been send by the server.
        %
        % Exception is FailureMessage and CancelledMessage,
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
        %                in asynchronous mode, size(task_ids) at output
        %                may be smaller then the size(task_ids) at input.
        %[all_messages,task_ids] = receive_all(obj,task_ids,mess_name_or_tag,varargin)

        % wait until all workers arrive to the part of the code marked
        % by this barrier.
        [ok,err]=labBarrier(obj,nothrow);
        %------------------------------------------------------------------
        % delete all messages belonging to this instance of messages
        % framework and shut the framework down.
        finalize_all(obj)

        %
        % remove all messages directed to the given lab from MPI message
        % cache
        % Do not shut the cluster down
        clear_messages(obj);

        % method verifies if job has been cancelled
        is = is_job_cancelled(obj)

        % the method, used by filebased framework to set up number of
        % parallel workers and the worker-id or by other frameworks to set
        % up these numbers in test mode.
        obj = set_framework_range(obj,labNum,NumLabs);
    end
    %
    methods(Abstract,Access=protected)
        % return the labIndex
        ind = get_lab_index_(obj);
        % return number of parallel workers
        n_labs = get_num_labs_(obj);
        %
        is = get_is_tested(obj);
        %
        % Internal receive messages function, which depends on physical
        % implementation of the receive mechanism
        % Inputs:
        % task_id -- the address of the host to receive message from
        % mess_name -- the name of the message to receive (may be 'any')
        % is_blocking -- should one receive the message synchronously
        % (wait until message appears in the system) or asynchronously --
        % return if the message is absent)
        % Outputs:
        % >>ok  if MESS_CODES.ok, message have been successfully
        %       received from task with the specified id.
        % >>    if not, error_mess and error code indicates reasons for
        %       failure.
        % >> on success, message contains an object of class aMessage,
        %        with the received message contents.

        [is_ok,err_mess,message] = receive_message_internal(obj,task_id,mess_name,is_blocking)
    end
    %
    methods(Access = protected)
        %
        function set_job_id_(obj,new_job_id)
            % Set a string, which defines unique job.
            if is_string(new_job_id) && ~isempty(new_job_id)
                obj.job_id_ = new_job_id;
            else
                error('iMESSAGES_FRAMEWORK:invalid_argument',...
                    'MPI job id has to be a string');
            end
        end
        %
        function [from_task_id,mess_name,is_blocking]=check_receive_inputs(obj,from_task_id,mess_name,varargin)
            % Helper function to check if receive message inputs are correct
            %
            % Returns the receive function various form of inputs converted in the standard form:
            %
            % from_task_id -- the index(number) of the worker(lab) to
            %                 receive message from.
            % mess_name    -- the name of the message to receive. May be
            %                 'any' if any message is requested.
            % is_blocking  -- if the receiving should be blocking(synchronous)
            %                 or unblocking (asynchronous)
            %
            %
            if ~exist('from_task_id', 'var') || isempty(from_task_id) ||...
                    (isnumeric(from_task_id ) && from_task_id < 0) || ...
                    ischar(from_task_id)
                %receive message from any task
                error('MESSAGES_FRAMEWORK:invalid_argument',...
                    'Requesting receive message from undefined lab is not currently supported');
            end
            if ~isnumeric(from_task_id)
                error('MESSAGES_FRAMEWORK:invalid_argument',...
                    'Task_id to receive message should be a number');
            else
                if numel(from_task_id)>1
                    error('MESSAGES_FRAMEWORK:invalid_argument',...
                        'Receiving only one message from one lab may be requested. Asked for: %d',...
                        numel(from_task_id));
                end
                if from_task_id>obj.numLabs
                    error('MESSAGES_FRAMEWORK:invalid_argument',...
                        'Receiving message from one lab N%d out of framework range: %d',...
                        from_task_id,obj.numLabs)
                end
            end
            if ~exist('mess_name', 'var') %receive any message for this task
                mess_name = 'any';
            end
            if isnumeric(mess_name)
                mess_name = MESS_NAMES.mess_name(mess_name,obj.interrupt_chan_tag_);
            end
            if ~ischar(mess_name)
                error('MESSAGES_FRAMEWORK:invalid_argument',...
                    'mess_name in recive_message command should be a message name (e.g. "starting")');
            end

            % check if the message should be received synchronously or asynchronously
            is_blocking = obj.check_is_blocking(mess_name,varargin);
        end
        %
        function [receive_now,message_names_array,n_steps] = check_whats_coming(obj,task_ids,mess_name,mess_array,n_steps)
            % Service function to check what messages will be arriving during next step waiting in
            % synchronous mode.
            %
            % part of receive_all messages function used in synchronous messages receive operations.
            % Extracted for unit testing as accessible only from parallel
            % code otherwise
            %
            % Inputs:
            % task_ids -- all lab-nums to receive messages from.
            % mess_name-- the name of the message to check for.
            % mess_array    -- cellarray of size(task_ids) where already received
            %                  messages are stored and not-received messages are
            %                  represented by empty cells
            % mess_received -- Boolean array of size task_ids, indicating if some messages
            %                  from the labs requested  have already arrived and
            %                  received
            % Returns:
            % receive_now    -- Boolean array of size task_ids, where true indicates
            %                   that message from correspondent task id is present and
            %                   can be read.
            % message_names_array -- cellarray of message names to read
            %                    now.
            %
            [receive_now,message_names_array,n_steps] = check_whats_coming_(obj,task_ids,mess_name,mess_array,n_steps);
        end
        %
    end

end
