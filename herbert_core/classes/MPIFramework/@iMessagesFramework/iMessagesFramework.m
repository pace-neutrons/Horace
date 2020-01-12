classdef iMessagesFramework < handle
    % Interface for messages in Herbert distributed jobs framework
    %
    % Defines generic interface a Horace program can use to exchange messages
    % between jobs running either in separate Matlab sessions or in Matlab
    % workers
    % Also contains auxiliary methods and basic operations used by all
    % Herbert MPI frameworks to set up remote jobs.
    %
    % $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
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
    end
    properties(Access=protected)
        job_id_;
        % time in seconds to waiting in blocking message until
        % unblocking or failing. Does not work for some operations in some frameworks
        % (e.g. receive_message in mpi)
        time_to_fail_ = 300; %(sec)
        % make fail message persistent
        persistent_fail_message_=[];
    end
    methods
        function obj = iMessagesFramework(varargin)
            % default prefix is random string of 10 capital Latin letters
            % (25 such letters)
            if nargin>0
                obj.job_id = varargin{1};
            else
                obj.job_id_ = char(floor(25*rand(1,10)) + 65);
            end
        end
        %
        function id = get.job_id(obj)
            id = obj.job_id_;
        end
        %
        function set.job_id(obj,val)
            % set the string uniquely definging job name.
            set_job_id_(obj,val);
        end
        %
        %
        function ind = get.labIndex(obj)
            ind = get_lab_index_(obj);
        end
        function ind = get.numLabs(obj)
            ind = get_num_labs_(obj);
        end
        %
        function cs = get_worker_init(obj,intercom_name,labID,numLabs)
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
            % cs = obj.get_worker_init1(intercom_name) % -- for real MPI worker
            % or
            % cs = obj.get_worker_init1(intercom_name,labId,numLabs) % for Herbert MPI
            %                                          worker
            % where
            % obj          --  an initiated instance of message exchange
            %                  framework on a head-node and
            % intercom_name -- the name of the framework, used
            %                  to exchange messages between workes
            % labId         -- labIndex if present, defines the number of
            %                  Herbert pseudo MPI worker to initiate
            % numLabs       -- if present, total  number of Herbert pseudo MPI
            %                  workers in the pool.
            %
            %
            datapath = fileparts(fileparts(fileparts(obj.mess_exchange_folder)));
            if exist('labID','var') % Herbert MPI worker. Numlabs and labnum are defined by configuration
                cs = obj.build_worker_init(...
                    datapath,obj.job_id,intercom_name,labID,numLabs);
            else  % real MPI worker (numlabs and labnum is defined by MPIexec
                cs = obj.build_worker_init(...
                    datapath,obj.job_id,intercom_name);
            end
        end
        %
        function check_set_persistent(obj,mess,source_address)
            % check if the input message is a persistent message (the message
            % describing a state of the source which persists until the
            % current job is completed or aborted) and if the message is
            % present store it in framework until the task is completed
            % or aborted
            check_set_persistent_(obj,mess,source_address);
        end
        %
        function [mess,id_from] = check_get_persistent(obj,source_address)
            % check if a message is a persistent message (the message
            % describing a state of the source which persists until the
            % current job is completed or aborted) and return these
            % persistent messages.
            % Input:
            % source_address -- the array of addresses to check for sources
            %                   of the persistent messages
            % Returns:
            % mess   -- cellarray of persisting messages returned from all
            %           or some sources requested
            %id_from -- array of the addresses which have previously
            %           generated persistent messages, stored within the
            %           framework
            [mess,id_from] = check_get_persistent_(obj,source_address);
        end
        %
        function [all_messages,mid_from] = add_persistent(obj,...
                all_messages,mid_from,mes_addr_to_check)
            % Helper method used to add persistent messages to the list
            % of the messages, received from other labs.
            %
            % If both messages are received from the same worker, overide
            % other message with the persistent message.
            % Inputs:
            % all_messages -- cellarray of messages to mix with persistent
            %                 messages.
            % mid_from     -- array of the workers id-s (labNums) where
            %                 these messages can be receved.
            % mes_addr_to_check -- array of labNums to check for presence
            %                 of persistent messages
            % Return:
            % all_messages  -- cellarray of the all present message names,
            %                  persistent and not
            % mid_from      -- array of labNum-s sending these messages.
            %
            [all_messages,mid_from] = add_persistent_(obj,...
                all_messages,mid_from,mes_addr_to_check);
        end
    end
    
    methods(Static)
        function cs = build_worker_init(path_to_data_exchange_folder,jobID,...
                intercom_name,labID,numLabs,test_mode)
            % prepare data necessary to initialize a MPI worker and
            % serialize them into the form, acceptable for transfer through
            % any system's interprocess pipe
            %
            % Usage:
            %>> cs =iMessagesFramework.build_worker_init(path_to_data_exchange_folder,[labID,numLabs])
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
            %              serizlised. Can be defined only if labID
            %              and numLabs are defined
            % Returns:
            % base64-coded and mappped to ASCII 128 symbols linear
            % representaion of the information, necessary to initialize
            % MPI worker operating with any Herbert cluster
            %
            % if test_mode is true, no encoding is performed and the
            %
            %
            cs = struct('data_path',path_to_data_exchange_folder,...
                'job_id',jobID,...
                'intercomm_name',intercom_name);
            serialize_message = true;
            if exist('labID','var')
                cs.labID   = labID;
                cs.numLabs = numLabs;
                if exist('test_mode','var')
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
            iarr = mod(int16(y),256); % convert from int8 to uint8
            params  =  hlp_deserialize(iarr);
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
                v = hlp_serialize(param)';
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
    
    methods(Abstract)
        %------------------------------------------------------------------
        % HERBERT Job control interface
        %
        % initialize message framework
        % framework_info -- data, necessary for framework to operate and
        % do message exchange.
        init_framework(obj,framework_info)
        
        %------------------------------------------------------------------
        % MPI interface
        %
        % Fully qualified name of a message, which allows
        % to identify message in a system.
        fn = mess_name(obj,task_id,mess_name)
        
        % send message to a task with specified id
        % Usage:
        % >>mf = MessagesFramework();
        % >>mess = aMessage('mess_name')
        % >>[ok,err_mess] = mf.send_message(1,mess)
        % >>ok  if MPI_err.ok, the message have been successfully send to a
        % >>    task with id==1. (not received)
        % >>    if other value, error_code and error_mess provide additional
        %       information for the failure
        %
        [ok,err_mess] = send_message(obj,task_id,message)
        % receive message from a task with specified id.
        % Blocking until message is received.
        %
        % Usage:
        % >>mf = MessagesFramework();
        % >>[ok,err_mess,message] = mf.receive_message(id,mess_name)
        %
        % >>ok  if MPI_err.ok, message have been successfully
        %       received from task with the specified id.
        % >>    if not, error_mess and error code indicates reasons for
        %       failure.
        % >> on success, message contains an object of class aMessage,
        %        with message contents
        %
        [is_ok,err_mess,message] = receive_message(obj,task_id,mess_name)
        
        
        
        % list all messages existing in the system for the tasks
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
        
        % retrieve (and remove from system) all messages
        % existing in the system for the tasks with id-s specified as input
        %
        %Input:
        %task_ids -- array of task id-s to check messages for
        %Return:
        % all_messages -- cellarray of messages for the tasks requested and
        %                 have messages available in the system .
        %task_ids       -- array of task id-s for these messages
        [all_messages,task_ids] = receive_all(obj,task_ids,mess_name_or_tag)
        %------------------------------------------------------------------
        % delete all messages belonging to this instance of messages
        % framework and shut the framework down.
        finalize_all(obj)
        % wait until all worker arrive to the part of the code specified
        [ok,err]=labBarrier(obj,nothrow);
        %
        % remove all messages directed to the given lab from MPI message cache
        clear_messages(obj);
        
        % method verifies if job has been canceled
        is = is_job_canceled(obj)
    end
    methods(Abstract,Access=protected)
        % return the labIndex
        ind = get_lab_index_(obj);
        n_labs = get_num_labs_(obj);
    end
    methods(Access = protected)
        function set_job_id_(obj,new_job_id)
            % Set a string, which defines unique job.
            if is_string(new_job_id) && ~isempty(new_job_id)
                obj.job_id_ = new_job_id;
            else
                error('iMESSAGES_FRAMEWORK:invalid_argument',...
                    'MPI job id has to be a string');
            end
        end
    end
    
end
