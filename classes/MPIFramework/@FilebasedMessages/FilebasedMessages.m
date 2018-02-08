classdef FilebasedMessages < iMessagesFramework
    % The class providing file-based message exchange functionality for Herbert
    % distributed jobs framework.
    %
    % The framework's functionality is similar to parfor
    % but does not requered parallel toolbox and works by starting
    % separate Matlab sessions to do separate jobs.
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    % This class provides physical mechanism to exchange messages between jobs.
    %
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    %
    properties(Dependent)
        % Properties of a job dispatcher:
        % the full path to the folder where the exchange configuration is stored
        exchange_folder;
        % method returns a qualified name of a program to run (e.g. Matlab
        % with all attributes necessary to start it (e.g. path if the program
        % is not on the path)
        % Job control file prefix used to distinguish between control
        % files of the same user but created by different Matlab sessions
        job_control_pref;
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
        % default prefix is random string of 10 capital Latin letters
        % (25 such letters)
        job_control_pref_ = char(floor(25*rand(1,10)) + 65);
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
            if nargin>0
                jd.job_control_pref_ = varargin{1};
            end
            root_cf = make_config_folder(FilebasedMessages.exchange_folder_name);
            job_folder = fullfile(root_cf,jd.job_control_pref_);
            if ~exist(job_folder,'dir')
                [ok, mess] = mkdir(job_folder);
                if ~ok
                    error('MESSAGES_FRAMEWORK:constructor_error',...
                        'Can not create control folder %s\n  Error message: %s',...
                        root_cf,mess);
                end
            end
            jd.exchange_folder_ = job_folder;
            
        end
        %
        function [ok,err_mess] = send_message(obj,job_id,message)
            % send message to a job with specified id
            % Usage:
            % >>mf = MessagesFramework();
            % >>mess = aMessage('mess_name')
            % >>[ok,err_mess] = mf.send_message(1,mess)
            % >>ok  if true, says that message have been successfully send to a
            % >>    job with id==1. (not received)
            % >>    if false, error_mess indicates reason for failure
            %
            [ok,err_mess] = send_message_(obj,job_id,message);
        end
        %
        function [ok,err_mess,message] = receive_message(obj,job_id,mess_name)
            % receive message from a job with specified id
            % Usage:
            % >>mf = MessagesFramework();
            % >>mess = aMessage(1,'mess_name')
            % >>[ok,err_mess] = mf.send_message(1,mess)
            % >>ok  if true, says that message have been successfully
            %       received from job with id==1.
            % >>    if false, error_mess indicates reason for failure
            % >> on success, message contains an object of class aMessage,
            %    with message contents
            %
            [ok,err_mess,message] = receive_message_(obj,job_id,mess_name);
        end
        %
        function ok=check_message(obj,job_id,mess_name)
            % check if specified message from the job with specified id
            % exist or not
            mess_fname = obj.job_stat_fname_(job_id,mess_name);
            if exist(mess_fname,'file') == 2
                ok = true;
            else
                ok = false;
            end
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
        function all_messages_names = list_all_messages(obj,job_ids)
            % list all messages existing in the system for the jobs
            % with id-s specified as input
            %Input:
            %job_ids -- array of job id-s to check messages for
            %Return:
            % cellarray of strings, containing message names for the requested
            % jobs.
            % if no message for a job is present in the systen,
            %its cell remains empty
            %
            all_messages_names = list_all_messages_(obj,job_ids);
        end
        %
        function [all_messages,job_ids] = receive_all_messages(obj,job_ids)
            % retrieve (and remove from system) all messages
            % existing in the system for the jobs with id-s specified as input
            %
            %Input:
            %job_ids -- array of job id-s to check messages for
            %Return:
            % all_messages -- cellarray of messages for the jobs requested and
            %                 have messages availible in the system .
            %job_ids       -- array of job id-s for these messages
            %
            %
            [all_messages,job_ids] = receive_all_messages_(obj,job_ids);
        end
        %------------------------------------------------------------------
        function preffix = get.job_control_pref(obj)
            % returns job control files prefix
            preffix  = obj.job_control_pref_;
        end
        %
        function folder = get.exchange_folder(obj)
            % return job control files prefix
            folder  = obj.exchange_folder_;
        end
        %
        function cs  = init_worker_control(obj,job_id)
            % function to initiate worker's control structure, necessary to
            % initiate jobExecutor
            css = MessagesFramework.worker_job_info(job_id,obj.job_control_pref);
            cs = iMessagesFramework.serialize_par(css);
        end
        %
        function clear_all_messages(obj)
            % delete all messages belonging to this instance of messages
            % framework
            clear_all_messages_(obj);
        end
    end
    %----------------------------------------------------------------------
    methods (Access=protected)
        function mess_fname = job_stat_fname_(obj,job_id,mess_name)
            mess_fname= fullfile(obj.exchange_folder,...
                sprintf('mess_%s_JobN%d.mat',mess_name,job_id));
            
        end
    end
    methods(Static)
        function info = worker_job_info(id,file_pref)
            % the structure, used to transmit information to worker and
            % initialize jobExecutor
            % where:
            % id        -- the job identifier
            % file_pref -- prefix, to distinguish job control files of one
            %              JobDispatcher from another
            info = struct('job_id',id,'file_prefix',file_pref);
        end
        
    end
end

