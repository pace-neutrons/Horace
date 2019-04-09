classdef iMessagesFramework
    % Interface for messages in Herbert distributed jobs framework
    %
    % Defines generic interface a Horace program can use to exchange messages
    % between jobs running either in separate Matlab sessions or in Matlab
    % workers
    % Also contains auxiliary methods and basic operations used by all
    % Herbert MPI frameworks to set up remote jobs.
    %
    % $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
    %
    %----------------------------------------------------------------------
    properties(Dependent)
        % job ID  used to identify job control
        % messages intended for a particular MPI job.
        job_id;
        % The folder located on a parallel file system and used for storing
        % initial job info and
        % message exchange between tasks if job uses  filebased messages.
        mess_exchange_folder;
        % returns the index of the worker currently executing the function.
        % labIndex is assigned to each worker when a job begins execution,
        % and applies only for the duration of that job.
        % The value of labIndex spans from 1 to n, where n is the number of
        % workers running the current job, defined by numlabs.
        labIndex;
        % Number of independent workers used by the framework
        numLabs;
    end
    properties(Access=protected)
        job_id_;
        mess_exchange_folder_ = '';
        % time in seconds to waiting in blocking message until
        % unblocking or failing. Does not work for some operations in some frameworks
        % (e.g. receive_message in mpi)
        time_to_fail_ = 1000; %(sec)
    end
    properties(Constant=true)
        % the name of the sub-folder where the remote jobs information is stored;
        exchange_folder_name='Herbert_Remote_Job';
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
        function folder = get.mess_exchange_folder(obj)
            folder  = obj.mess_exchange_folder_;
        end
        %
        function obj = set.job_id(obj,val)
            if is_string(val) && ~isempty(val)
                old_id = obj.job_id_;
                obj.job_id_ = val;
                if ~isempty(obj.mess_exchange_folder_)
                    old_exchange = obj.mess_exchange_folder_;
                    [fp,fs] = fileparts(obj.mess_exchange_folder_);
                    if strcmpi(fs,old_id)
                        obj.mess_exchange_folder_ = fullfile(fp,val);
                        rmdir(old_exchange,'s');
                    end
                end
                
            else
                error('iMESSAGES_FRAMEWORK:invalid_argument',...
                    'MPI job id has to be a string');
            end
        end
        %
        function obj = set.mess_exchange_folder(obj,val)
            % set message exchange folder for filebased messages exchange
            % within Herbert/Horace configuration folder
            % and copy Herbert/Horace configurations to new configuration
            % folder if this folder differs from default configuration
            
            if strcmp(val,obj.mess_exchange_folder)
                return;
            end
            
            if exist(obj.mess_exchange_folder,'dir') == 7
                rmdir(obj.mess_exchange_folder,'s');
            end
            [remote_job_base,config_ext] = obj.build_exchange_folder_name(val);
            obj.mess_exchange_folder_ = fullfile(remote_job_base,config_ext);
            if ~(exist(obj.mess_exchange_folder,'dir') ==7)
                mkdir(obj.mess_exchange_folder);
            end
            existing_config_f = config_store.instance().config_folder;
            remote_config_folder = fullfile(remote_job_base,config_store.config_folder_name);
            if ~strcmp(remote_config_folder,existing_config_f)
                copy_existing_config_to_remote_(existing_config_f,remote_config_folder);
            end
            
        end
        %
        function ind = get.labIndex(obj)
            ind = get_lab_index_(obj);
        end
        function ind = get.numLabs(obj)
            ind = get_num_labs_(obj);
        end
        %
        function cs = gen_worker_init(obj,labID,numLabs)
            % Generate slave MPI worker init info, using static build_worker_init
            % method and information, retrieved from initialized control node
            % Usage:
            % cs = obj.gen_worker_init() % -- for real MPI worker
            % or
            % cs = obj.gen_worker_init(labId,numLabs) % for Herbert MPI
            %                                          worker
            % where
            % obj     -- an initiated instance of message exchange framework on a head-node and
            % labId   -- labIndex of Herbert MPI worker to initiate
            % numLabs -- number of Herbert MPI workers
            %
            %
            datapath = fileparts(fileparts(fileparts(obj.mess_exchange_folder)));
            if exist('labID','var') % Herbert MPI worker. Numlabs and labnum are defined by configuration
                cs = obj.build_worker_init(...
                    datapath,obj.job_id,labID,numLabs);
            else  % real MPI worker (numlabs and labnum is defined by MPIexec
                cs = obj.build_worker_init(...
                    datapath,obj.job_id);
            end
            
        end
        
        % HERBERT Job control interface+
        function is = is_job_cancelled(obj)
            % method verifies if job has been cancelled
            if ~exist(obj.mess_exchange_folder_,'dir')
                is=true;
            else
                is=false;
            end
            if ~is
                mess = obj.probe_all('all','cancelled');
                if ~isempty(mess)
                    is = true;
                end
            end
        end
        %
    end
    
    methods(Static)
        function initMessage = build_je_init(JE_className,exit_on_completion,keep_worker_running)
            % the structure, used to initialize job executor class, to run on
            % a particular worker
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
            %
            if ~exist('exit_on_completion','var')
                exit_on_completion = true;
            end
            if ~exist('keep_worker_running','var')
                keep_worker_running = false;
            end
            
            % labIndex defines the number of worker. If this is MPI job,
            % the number is derived from MPI framework, if its Herbert
            % framework, the number of worker should be assigned.
            info = struct(...
                'JobExecutorClassName',JE_className,...
                'exit_on_compl',exit_on_completion ,...
                'keep_worker_running',keep_worker_running);
            initMessage  = aMessage('starting');
            initMessage.payload = info;
        end
        
        function cs = build_worker_init(path_to_data_exchange_folder,jobID,labID,numLabs)
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
            % jobID         -- the name of the parallel job to run
            %
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
            cs = struct('data_path',path_to_data_exchange_folder,...
                'job_id',jobID);
            if exist('labID','var')
                cs.labID   = labID;
                cs.numLabs = numLabs;
            end
            cs = iMessagesFramework.serialize_par(cs);
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
        obj = init_framework(obj,framework_info)
        
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
        % remove all messages from MPI message cache
        clear_messages(obj);
        
    end
    methods(Abstract,Access=protected)
        % return the labIndex
        ind = get_lab_index_(obj);
        n_labs = get_num_labs_(obj);
    end
    methods(Access = protected)
        function [top_exchange_folder,mess_subfolder] = build_exchange_folder_name(obj,top_exchange_folder )
            % build the name of the folder used to exchange messages
            % between the base node and the MPI framework and, if
            % necessary, filebased messages
            if ~exist('top_exchange_folder','var')
                top_exchange_folder = config_store.instance().config_folder;
            end
            [top_exchange_folder,mess_subfolder] = constr_exchange_folder_name_(obj,top_exchange_folder);
        end
    end
    
end

