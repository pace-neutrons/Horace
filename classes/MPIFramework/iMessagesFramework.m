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
    end
    properties(Access=private)
        job_id_;
        job_data_folder_ = '';
    end
    methods
        function obj = iMessagesFramework()
            % default prefix is random string of 10 capital Latin letters
            % (25 such letters)
            obj.job_id_ = char(floor(25*rand(1,10)) + 65);
        end
        
        function id = get.job_id(obj)
            id = obj.job_id_;
        end
        function folder = get.job_data_folder(obj)
            folder  = obj.job_data_folder_;
        end
        
        function obj = set.job_id(obj,val)
            if is_string(val) && ~isempty(val)
                obj.job_id_ = val;
            else
                error('iMESSAGES_FRAMEWORK:invalid_argument',...
                    'MPI job id has to be a string');
            end
        end
        function obj = set.job_data_folder(obj,val)
            if exist(val,'dir') == 7
                obj.job_data_folder_ = val;
            else
                error('iMESSAGES_FRAMEWORK:invalid_argument',...
                    'Job data exchange folder %s must exist',...
                    val);
            end
        end
        
        function info = worker_job_info(obj,framework_name,mpi_info)
            % the structure, used to transmit information to worker and
            % initialize jobExecutor
            % where:
            %
            % framework_name -- the name of the class responsible for
            %                   messages exchange. Should allow empty
            %                   constructor for feval and initialization
            %                   string
            % mpi_info       -- other information necessary to initiate
            %                   the messages framework.
            info = struct('job_id',obj.job_id,...
                'job_data_folder',obj.job_data_folder,...
                'framework_name',framework_name,'mpi_info',mpi_info);
        end
        
    end
    
    methods(Static)
        %
        function params = deserialize_par(par_string)
            % function restores structure or class from a string
            % representation, build to allow transfer through standard
            % system pipe
            %
            par_string = strrep(par_string,'x',' ');
            len = numel(par_string)/3;
            sa = reshape(par_string,len,3);
            iarr = uint8(str2num(sa));
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
                v = hlp_serialize(param);
            catch ME
                mess = ME.message;
                return
            end
            par=num2str(v);
            par = reshape(par,1,numel(par));
            par = strrep(par,' ','x');
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
        cs  = build_control(obj,task_id)
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
        [all_messages,task_ids] = receive_all_messages(obj,task_ids)
        %------------------------------------------------------------------
        % delete all messages belonging to this instance of messages
        % framework and shut the framework down.
        finalize_all(obj)
        
        % method verifies if job has been cancelled
        is = is_job_cancelled(obj)
    end
    
end

