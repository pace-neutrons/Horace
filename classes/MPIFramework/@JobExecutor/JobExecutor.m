classdef JobExecutor<MessagesFramework
    % The class, responsible for running job on a worker
    %
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
        %-------------------------------------
        % Properties of a job runner:
        % the jd of the the job which is running
        job_id;
        % structure, containing output, returned from the job by
        % calling return_results method
        job_outputs;
    end
    %
    properties(Access=private)
        job_ID_ = 0;
        job_outputs_ = [];
    end
    methods(Abstract)
        this=do_job(this,control_struct);
        % abstract method to do particular job.
        % should be overloaded by a particular implementation
    end
    %------------------------------------------------------------------ ---
    methods
        function je = JobExecutor(varargin)
            % Initialize job executor
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to distinguish
            % this job control files from any other job control files
            %Example
            % jd = JobExecutor() -- use randomly generated job control
            % prefix
            % jd = JobExecutor('target_file_name') -- add prefix
            %      which distinguish this job as the job which will produce
            %      the file with the name provided
            %
            % Initialise messaging framework
            je = je@MessagesFramework(varargin{:});
        end
        %
        function [this,argi,mess]=init_worker(this,job_control_string)
            % initiate worker side.
            %e.g:
            % set up tag, indicating that the job have started
            % and process main job control parameters, present in
            % inputs and files:
            %
            % job_control_string  -- the serialized structure,
            %                containing job control  information
            %
            % returns:
            % argi         the structure, containing job's arguments,
            %              used by do_job method
            % mess         if not empty, the reason for failure
            %
            [this,argi,mess]=this.init_worker_(job_control_string);
        end
        %
        function [ok,mess] =finish_job(this)
            % set up tag, indicating that the job have finished
            [ok,mess] = finish_job_(this);
        end
        %------------------------------------------------------------------
        function id = get.job_id(this)
            % get number (job id) of current running job
            id = this.job_ID_;
        end
        %
        function this = return_results(this,final_results)
            % function used by do_job method to return outputs from a job.
            %
            % input:
            % final_results -- the structure, which contain the job
            % output.
            this.job_outputs_ = final_results;
        end
        %
        function out = get.job_outputs(obj)
            out = obj.job_outputs_;
        end
        %------------------------------------------------------------------
        % overloads to exchange messages with JobDispatcher for particular job Executor
        function [ok,err_mess] = send_message(obj,message,varargin)
            % send message to job dispatcher
            [ok,err_mess] = send_message@MessagesFramework(obj,obj.job_id,...
                message,varargin{:});
        end
        function [ok,err_mess,message] = receive_message(obj,mess_name)
            % receive message from job dispatcher
            [ok,err_mess,message] = receive_message@MessagesFramework(obj,obj.job_id,mess_name);
        end
    end
    
end

