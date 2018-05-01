classdef iMessagesFramework
    % Interface for messages in Herbert distributed jobs framework
    %
    % Defines generic interface a Horace program can use to exchange messages
    % between jobs running either in separate Matlab sessions or in Matlab
    % workers
    % Also contains auxiliary methods and basic operations used by all
    % Herbert MPI frameworks to set up remote jobs.
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
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
        % labindex is assigned to each worker when a job begins execution,
        % and applies only for the duration of that job.
        % The value of labindex spans from 1 to n, where n is the number of
        % workers running the current job, defined by numlabs.
        labIndex;
        % Number of independent workers used by the framework
        numLabs;
    end
    properties(Access=private)
        job_id_;
        mess_exchange_folder_ = '';
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
                    [fp,fs] = fileparts(obj.mess_exchange_folder_);
                    if strcmpi(fs,old_id)
                        obj.mess_exchange_folder_ = fullfile(fp,val);
                    end
                    
                end
                
            else
                error('iMESSAGES_FRAMEWORK:invalid_argument',...
                    'MPI job id has to be a string');
            end
        end
        %
        function obj = set.mess_exchange_folder(obj,val)
            if exist(val,'dir') == 7
                [config_f_base,config_ext] = obj.build_exchange_folder_name(val);
                obj.mess_exchange_folder_ = fullfile(config_f_base,config_ext);
            else
                error('iMESSAGES_FRAMEWORK:invalid_argument',...
                    'Job data exchange folder %s must exist',...
                    val);
            end
        end
        %
        function ind = get.labIndex(obj)
            ind = get_lab_index_(obj);
        end
        function ind = get.numLabs(obj)
            ind = get_num_labs_(obj);
        end
        
        % HERBERT Job control interface+
        function [obj,local_config_folder]= distribute_worker_init(obj,...
                shared_folder_on_local,JE_className,varargin)
            % build worker's control structure, necessary to
            % initiate message framework and jobExecutor.
            % and store this information in the location, where a remote
            % worker should pick it up.
            %
            %
            info = obj.worker_init_info(JE_className,varargin{:});
            [remote_job_folder,local_config_folder] = obj.send_job_info(info,shared_folder_on_local);
            obj.mess_exchange_folder = remote_job_folder;
        end
        
        
        function info = worker_init_info(obj,JE_className,varargin)
            % the structure, used to transmit information to a worker and
            % initialize jobExecutor on a worker through the system pipe.
            % due to the system pipe limited size, this information sould
            % be very restricted.
            % where:
            %
            % shared_folder_on_remote -- other information necessary to initiate
            %                   the messages framework.
            
            if nargin>2
                exit_on_complition = varargin{1};
            else
                exit_on_complition = true;
            end
            % labIndex defines the number of worker. If this is MPI job,
            % the number is derived from MPI framework, if its Herbert
            % framework, the number of worker should be asigned.
            info = struct('JobExecutorClassName',JE_className,...
                'exit_on_compl',exit_on_complition);
        end
        
        function [remote_job_folder,local_config_folder] = send_job_info(obj,info,varargin)
            % store configuration data necessary to initiate Herbert/Horace mpi
            % job on a remote machine.
            %Usage:
            %mpi.send_job_info(info,[shared_folder_on_local]);
            %
            % Info -- the data describing the job itself.
            % shared_folder_on_local -- if present, defines the folder
            %                           where remote job will exchange its data
            %               if absent, parallel_config value will be used
            [remote_job_folder,local_config_folder]...
                = store_config_info_(obj,info,varargin{:});
        end
        
        function [init_info,config_folder]= receive_job_info(obj,data_path,varargin)
            % restore configuration data necessary to initiate Herbert/Horace mpi
            % job on a remote machine.
            %Usage:
            % [job_info,config_folder] = mpi.receive_job_info(data_path,['-keep_info'])
            %Where:
            %
            % data_path       -- the path to the configuration data and
            %                    configuration files.
            %'-keep_job_info' -- if this key is present, the message with job info
            %                    will not be deleted after the data are
            %                    received, if not, the message would be
            %                    destroyed
            % Returns:
            % init_info     -- loaded job configuration data as stored by
            %                  send_job_info operation.
            % config_folder -- the folder where the configuration
            %                  information is stored. This folder should be
            %                  set us config_store folder.
            %
            if ~exist('data_path','var') || isempty(data_path)
                data_path = obj.mess_exchange_folder;
            end
            [init_info,config_folder] = restore_config_info_(obj,data_path,varargin{:});
        end
        
        function [filename,filepath,equal_fs] = par_config_file(obj,varargin)
            % Returns the name and remote path to a file, which stores a remote job
            % configuration, necessary to intiate a worker.
            % Used by send/receive job_info methods.
            %Usage:
            %>>[filename,filepath,equal_fs] = mpi.par_config_file();
            %
            % where:
            % filename -- the name of the file with the information
            % filepath -- path to this file on remote file system
            % equal_fs -- true if file systems are shared and look the same
            %             form local and remote sides.
            if nargin>1
                [top_exchange_folder,mess_subfolder] = obj.build_exchange_folder_name(varargin{1});
            else
                top_exchange_folder = config_store.instance().get_value(...
                    'parallel_config','shared_folder_on_local');
                [top_exchange_folder,mess_subfolder] =obj.build_exchange_folder_name(top_exchange_folder);
            end
            filename = [obj.job_id,'_init_data.mat'];
            if isempty(top_exchange_folder)% by agreement  the
                % remote folder located and mounted
                % on the remote system in the same place as the local folder.
                equal_fs = true;
            else
                equal_fs = false;
            end
            filepath  = fullfile(top_exchange_folder,mess_subfolder);
        end
        %
        function is = is_job_cancelled(obj)
            % method verifies if job has been cancelled
            if ~exist(obj.mess_exchange_folder_,'dir')
                is=true;
            else
                is=false;
            end
        end
        %
    end
    
    methods(Static)
        function cs = build_framework_init(path_to_data_exchange_folder,jobID,labID,numLabs)
            % prepare data path, a worker would take its data from
            % Usage:
            %>> cs =iMessagesFramework.build_framework_init(path_to_data_exchange_folder,labID)
            % Where:
            % path_to_data_exchange_folder -- the path on a remote machine
            %                                 where the file-based messages
            %                                 and initation information
            %                                 should be distributed
            % jobID         -- the name of the parallel job to run
            % labID         -- the worker id, which would be ignored
            %                  (redefined by MPI framework) for proper MPI job
            %                   or used  as MPI labId for filebased
            %                   messages.
            % numLabs       -- number of independent workers, used by MPI
            %                  job. If labID is defined, numLabs has to
            %                  be defined too.
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
        
        % receive message from a task with specified id
        % Usage:
        % >>mf = MessagesFramework();
        % >>mess = aMessage(1,'mess_name')
        % >>[ok,err_mess] = mf.receive_message(1,mess)
        % >>ok  if MPI_err.ok, message have been successfully
        %       received from task with id==1.
        % >>    if not, error_mess and error code indicates reasons for
        %       failure.
        % >> on success, message contains an object of class aMessage,
        %    with message contents
        %>>NOT_YET_IMPLEMENTED: if no message name is provided at input, the command becomes
        %   blocking  but if the message name exist, and the message is not
        %   arrived, it returns immidiately
        %
        [is_ok,err_mess,message] = receive_message(obj,task_id,mess_name)
        
        
        
        % list all messages existing in the system for the tasks
        % with id-s specified as input
        %Input:
        %task_ids -- array of task id-s to check messages for
        %Return:
        % cellarray of strings, containing message names for the requested
        % tasks.
        % if no message for a task is present in the systen,
        % its cell remains empty
        % if task_id list is emtpy or missing, returns all existing
        % messages
        [all_messages_names,task_ids] = probe_all(obj,task_ids,mess_names)
        
        % retrieve (and remove from system) all messages
        % existing in the system for the tasks with id-s specified as input
        %
        %Input:
        %task_ids -- array of task id-s to check messages for
        %Return:
        % all_messages -- cellarray of messages for the tasks requested and
        %                 have messages availible in the system .
        %task_ids       -- array of task id-s for these messages
        [all_messages,task_ids] = receive_all(obj,task_ids,mess_name_or_tag)
        %------------------------------------------------------------------
        % delete all messages belonging to this instance of messages
        % framework and shut the framework down.
        finalize_all(obj)
        
    end
    methods(Abstract,Access=protected)
        % return the labindex
        ind = get_lab_index_(obj);
        n_labs = get_num_labs_(obj);
    end
    methods(Access = protected)
        function [top_exchange_folder,mess_subfolder] = build_exchange_folder_name(obj,top_exchange_folder )
            % build the name of the folder used to exchange messages
            % between the base node and the mpi framework and, if
            % necessary, filebased messages
            if ~exist('top_exchange_folder','var')
                top_exchange_folder = config_store.instance().config_folder;
            end
            [top_exchange_folder,mess_subfolder] = constr_exchange_folder_name_(obj,top_exchange_folder);
        end
    end
    
end

