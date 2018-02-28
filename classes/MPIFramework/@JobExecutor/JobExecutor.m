classdef JobExecutor
    % The class, responsible for running a task on a worker
    %
    %
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    % $Revision$ ($Date$)
    %
    %
    properties(Dependent)
        %-------------------------------------
        % Properties of a job runner:
        % the jd of the the job which is running
        task_id;
        % structure, containing output, returned from the job by
        % calling return_results method
        task_outputs;
        % Access to messages framework used to exchange messages between
        % executor and controller
        mess_framework;
    end
    %
    properties(Access=private)
        task_id_ = 0;
        task_outputs_ = [];
        % handle for the messages framework
        mess_framework_ = [];
    end
    methods(Abstract)
        this=do_job(this,control_struct);
        % abstract method to do particular job.
        % should be overloaded by a particular implementation
    end
    %------------------------------------------------------------------ ---
    methods
        function je = JobExecutor()
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
            %je = je@MessagesFramework(varargin{:});
        end
        %
        function [this,argi,job_controls,mess]=init_worker(this,job_control_string)
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
            % job_controls - decoded job control structure
            % mess         if not empty, the reason for failure
            %
            [this,argi,job_controls,mess]=this.init_worker_(job_control_string);
        end
        %
        function [ok,mess] =finish_job(this)
            % Clearly finish job execution
            [ok,mess] = finish_job_(this);
        end
        %
        function log_progress(this,step,n_steps,time_per_step,add_info)
            % log progress of the job execution and report it to the
            % calling framework.
            % Inputs:
            % step     --  current step within the loop which doing the job
            % n_steps  --  number of steps this job will make
            % time_per_step -- approximate time spend to make one step of
            %                  the job
            % add_info -- some additional information provided by the
            %             client. Not processed but printed in a log if not
            %             empty.
            % Outputs:
            % Sends message of type LogMessage to the job dispatcher.
            % Throws MESSAGE_FRAMEWORK:cancelled error in case the job has
            %
            log_progress_(this,step,n_steps,time_per_step,add_info);
        end
        %------------------------------------------------------------------
        function id = get.task_id(this)
            % get number (job id) of current running job
            id = this.task_id_;
        end
        %
        function this = return_results(this,final_results)
            % function used by do_job method to return outputs from a job.
            %
            % input:
            % final_results -- the structure, which contain the job
            % output. As output is distributed within log message, it should not
            % be too heavy.
            %
            this.task_outputs_ = final_results;
        end
        %
        function out = get.task_outputs(obj)
            out = obj.task_outputs_;
        end
        %
        function out = get.mess_framework(obj)
            out = obj.mess_framework_;
        end        
        %------------------------------------------------------------------
        % MPI interface
        % overloads to exchange messages with JobDispatcher for particular job Executor
        function [ok,err_mess] = send_message(obj,message)
            % send message to job dispatcher
            % input:
            % message -- an instance of the class aMessage to send to job
            %            dispatcher
            %
            [ok,err_mess] = obj.mess_framework_.send_message(obj.task_id,...
                message);
        end
        function [ok,err_mess,message] = receive_message(obj,mess_name)
            % receive message from job dispatcher
            [ok,err_mess,message] = obj.mess_framework_.receive_message(obj.task_id,mess_name);
        end
        function ok=probe_message(obj,mess_name)
            all_names = obj.mess_framework_.probe_all(obj.task_id);
            if exist('mess_name','var')
                if any(ismember(mess_name,all_names))
                    ok = true;
                else
                    ok = false;
                end
            else
                if isempty(all_names)
                    ok = false;
                else
                    ok = true;
                end
            end
            
        end
        function messages = receive_all_messages(obj)
            % retrieve (and remove from system) all messages
            % existing in the system for the jobs with id-s specified as input
            %
            %Return:
            % all_messages -- cellarray of messages belonging to this job
            %                 have messages available in the system .
            %
            messages = obj.mess_framework_.receive_all_messages(obj.task_id);
        end
        %
        function is = is_job_cancelled(obj)
            is = obj.mess_framework_.is_job_cancelled();
        end
    end
    
end

