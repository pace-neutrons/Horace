classdef MessagesFramework
    % Host class for message Herbert distributed jobs framework
    %
    % Similar to parfor bud does not need parallel toolbox and starts
    % separate Matlab sessions to do the job
    %
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    % $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)
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
    methods(Static)
        %
        function params = deserialize_par(par_string)
            % function restores job parameters from job string
            % representation
            %
            par_string = strrep(par_string,'x',' ');
            len = numel(par_string)/3;
            sa = reshape(par_string,len,3);
            iarr = uint8(str2num(sa));
            params  =  hlp_deserialize(iarr);
        end
        %
        function [par,mess] = serialize_par(param)
            % convert job parameters structure or class into job
            % parameter's string
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
        function info = worker_job_info(id,file_pref)
            % the structure, used to transmit information to worker and
            % initialize jobExecutor
            % where:
            % id        -- the job identifier
            % file_pref -- prefix, to distinguish job control files of one
            %              JobDispatcher from another
            info = struct('job_id',id,'file_prefix',file_pref);
        end
        
        %
    end
    %----------------------------------------------------------------------    
    methods
        %
        function jd = MessagesFramework(varargin)
            % Initialize Messages framework for particular job
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to
            % distinguish this job control files from any other job control
            % files.
            %Example
            % jd = MessagesFramework() -- use randomly generated job control
            %                             prefix
            % jd = MessagesFramework('target_file_name') -- add prefix
            %      which distinguish this job as the job which will produce
            %      the file with the name provided
            %
            % Initialise folder path
            jd.exchange_folder_ = make_config_folder(JobDispatcher.exchange_folder_name);
            if nargin>0
                jd.job_control_pref_ = varargin{1};
            end
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
        function preffix = get.job_control_pref(obj)
            % return job control files prefix
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
            cs = MessagesFramework.serialize_par(css);
        end
        %
        function clear_all_messages(obj)
            % delete all messages belonging to this messages framework
            pref = obj.job_control_pref;            
            clear_all_messages_(obj,sprintf('message_%s_',pref));
        end
    end
    %----------------------------------------------------------------------    
    methods (Access=protected)
        function mess_fname = job_stat_fname_(obj,job_id,mess_name)
            pref = obj.job_control_pref;
            mess_fname= fullfile(obj.exchange_folder,...
                sprintf('message_%s_%s_JobN%d.mat',pref,mess_name,job_id));
            
        end
    end
    
end

