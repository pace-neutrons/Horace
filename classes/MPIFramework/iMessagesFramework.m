classdef iMessagesFramework
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
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    %
    %----------------------------------------------------------------------
    properties(Dependent)
        % method returns a qualified name of a program to run (e.g. Matlab
        % with all attributes necessary to start it (e.g. path if the program
        % is not on the path)
        % Job ID  used to identify job control
        % messages for given job
        job_ID;
    end
    properties(Access=private)
        job_ID_;
    end
    
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
        %
    end
    %----------------------------------------------------------------------
    methods(Abstract)
        % send message to a job with specified id
        % Usage:
        % >>mf = MessagesFramework();
        % >>mess = aMessage('mess_name')
        % >>[ok,err_mess] = mf.send_message(1,mess)
        % >>ok  if true, says that message have been successfully send to a
        % >>    job with id==1. (not received)
        % >>    if false, error_mess indicates reason for failure
        %
        [ok,err_mess] = send_message(obj,job_id,message)
        
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
        [ok,err_mess,message] = receive_message(obj,job_id,mess_name)
        % check if specified message from the job with specified id
        % exist or not
        
        ok=check_message(obj,job_id,mess_name)
        % method verifies if job has been cancelled
        is = is_job_cancelled(obj)
        
        % list all messages existing in the system for the jobs
        % with id-s specified as input
        %Input:
        %job_ids -- array of job id-s to check messages for
        %Return:
        % cellarray of strings, containing message names for the requested
        % jobs.
        % if no message for a job is present in the systen,
        % its cell remains empty
        all_messages_names = list_all_messages(obj,job_ids)
        
        % retrieve (and remove from system) all messages
        % existing in the system for the jobs with id-s specified as input
        %
        %Input:
        %job_ids -- array of job id-s to check messages for
        %Return:
        % all_messages -- cellarray of messages for the jobs requested and
        %                 have messages availible in the system .
        %job_ids       -- array of job id-s for these messages
        [all_messages,job_ids] = receive_all_messages(obj,job_ids)
        %------------------------------------------------------------------
        
        % delete all messages belonging to this instance of messages
        % framework        
        clear_all_messages(obj)
    end
    methods(Access=protected)
        function id= get_job_id(obj)
            id = obj.job_ID_;
        end
        function obj= set_job_id(obj,val)
            if is_char(val)
            obj.job_ID_ = val;
        end
        
    end
    
end

