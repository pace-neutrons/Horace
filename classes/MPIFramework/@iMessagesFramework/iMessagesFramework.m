classdef iMessagesFramework
    % Interface for messages in Herbert distributed jobs framework
    %
    % Defines generic interface a Horace program can use to exchange messages
    % between jobs running either in separate Matlab sessions or in Matlab
    % workers
    %
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    %----------------------------------------------------------------------
    properties(Dependent)
        % job ID  used to identify job control
        % messages intended for a particular MPI job.
        job_id;
        % The folder located on a parallel file system and used for
        % data exchange between tasks and storing input data.
        % if empty, default Herbert value is used.
        job_data_folder;
        % returns the index of the worker currently executing the function.
        % labindex is assigned to each worker when a job begins execution,
        % and applies only for the duration of that job.
        % The value of labindex spans from 1 to n, where n is the number of
        % workers running the current job, defined by numlabs.
        labIndex;
        
    end
    properties(Access=private)
        job_id_;
        job_data_folder_ = '';
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
        function folder = get.job_data_folder(obj)
            folder  = obj.job_data_folder_;
        end
        %
        function obj = set.job_id(obj,val)
            if is_string(val) && ~isempty(val)
                obj.job_id_ = val;
            else
                error('iMESSAGES_FRAMEWORK:invalid_argument',...
                    'MPI job id has to be a string');
            end
        end
        %
        function obj = set.job_data_folder(obj,val)
            if exist(val,'dir') == 7
                obj.job_data_folder_ = val;
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
        
        function info = worker_job_info(obj,framework_name,mpi_info,varargin)
            % the structure, used to transmit information to a worker and
            % initialize jobExecutor on a worker through the system pipe.
            % due to the system pipe limited size, this information sould
            % be very restricted.
            % where:
            %
            % framework_name -- the name of the class responsible for
            %                   messages exchange. Should allow empty
            %                   constructor for feval and initialization
            %                   string
            % mpi_info       -- other information necessary to initiate
            %                   the messages framework.
            if nargin>3
                exit_on_complition = varargin{1};
            else
                exit_on_complition = true;
            end
            info = struct('job_id',obj.job_id,...
                'job_data_folder',obj.job_data_folder,...
                'framework_name',framework_name,'mpi_info',mpi_info,...
                'exit_on_compl',exit_on_complition);
        end
        
        function send_job_info(obj,info)
            % store configuration data necessary to initiate Herbert/Horace mpi
            % job on a remote machine.
            %
            % Info -- the data describing the job itself.
            store_config_info_(obj,info);
        end
        
        function [init_info,config_folder]= receive_job_info(obj,data_path)
            % restore configuration data necessary to initiate Herbert/Horace mpi
            % job on a remote machine.
            %
            % data_path -- the path to the configuration data and
            %              configuration files.
            % Returns:
            % init_info  -- loaded job configuration data as stored by
            %               send_job_info operation.
            % config_folder -- the folder where the configuration
            %                  information is stored. This folder should be
            %                  set us config_store folder.
            [init_info,config_folder] = restore_config_info_(obj,data_path);
        end
        
        function fname = get_par_config_file_name(obj,varargin)
            % The fill name (with path) to a file, which stores a remote job
            % configuration, necessary to intiate a worker. Used by
            % send/receive job_info methods.
            %Usage:
            %>>fname = mpi.get_config_file_name([a_folder]);
            %
            % without parameters returns the config file for current config
            % setting, with the path, returns a file, which would be located
            % within a configuration wihin the folder path specified.
            filename = [obj.job_id,'_init_data.mat'];
            if nargin == 1
                config_folder = config_store.instance().config_folder;
                fname  = fullfile(config_folder,obj.exchange_folder_name,filename);
            else
                cf_name = config_store.config_folder_name;
                other_folder = varargin{1};
                [~,fn] = fileparts(other_folder);
                if strcmpi(fn,cf_name)
                    fname  = fullfile(other_folder,obj.exchange_folder_name,filename);
                elseif strcmpi(fn,obj.exchange_folder_name)
                    fname  = fullfile(other_folder,filename);                    
                else
                    fname  = fullfile(other_folder,cf_name,obj.exchange_folder_name,filename);
                end
            end
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
        
        % build worker's control structure, necessary to
        % initiate message framework and jobExecutor. Must use
        % iMessagesFramework.worker_job_info to build appropriate framework
        cs  = build_control(obj,task_id,varargin)
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
        all_messages_names = probe_all(obj,task_ids)
        
        % retrieve (and remove from system) all messages
        % existing in the system for the tasks with id-s specified as input
        %
        %Input:
        %task_ids -- array of task id-s to check messages for
        %Return:
        % all_messages -- cellarray of messages for the tasks requested and
        %                 have messages availible in the system .
        %task_ids       -- array of task id-s for these messages
        [all_messages,task_ids] = receive_all(obj,task_ids)
        %------------------------------------------------------------------
        % delete all messages belonging to this instance of messages
        % framework and shut the framework down.
        finalize_all(obj)
        
    end
    methods(Abstract,Access=protected)
        % return the labindex
        ind = get_lab_index_(obj);
    end
    
end

