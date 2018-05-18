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
        % Properties of a job executor:
        % the id of the running task
        labIndex;
        % Access to messages framework used to exchange messages between
        % executor and controller
        mess_framework;
        % The framework used to exchange messages between MPI jobs pool and
        % the control node. For filebased messages its the same as
        % mess_framework but for proper MPI job or remote host its
        % different.
        control_node_exch;
        % a helper property, containing task outputs if these outputs are
        % defined
        task_outputs
    end
    %
    properties(Access=protected)
        % handle for the messages framework
        mess_framework_ = [];
        % the holder of the class, responsible for comunicatiob between the
        % head node and the worker's pool
        control_node_exch_ = [];
        %------------------------------------------------------------------
        % Protected data, initiated by init method and used by a child's
        % overloaded methods as requested
        %
        % The data common to all iterations of do_job method
        common_data_ = [];
        % number of first iteration to do over common_data
        n_first_iteration_ = 1;
        % number of iterations in the workers's loop (numel(loop_data_) if
        % the loop data contains an array or number of iterations over the
        % common_data_ if the loop_data_ are empty
        n_iterations_ = 0;
        % cellarray of the data, specific to each loop iteration
        loop_data_ = {};
        %
        % if the task needs to return results on completeon.
        return_results_ = false;
        % task results holder used to keep a task's results to return at
        % finish task stage if return_results is set to true;
        % do_job and/or reduce_data should populate this property according
        % to the particular task logic.
        task_results_holder_ =[];
        
    end
    methods(Abstract)
        % should be overloaded by a particular implementation
        %
        % abstract method to do particular job.
        this=do_job(this);
        % abstract method to collect and reduce data, located on different.
        % workers
        this=reduce_data(this);
        % the method to analyze outputs and indicate that the tasks or job
        % has been completed.
        ok = is_completed(this);
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
        end
        %
        function [obj,mess]=init(obj,fbMPI,job_control_struct,InitMessage)
            % initiate worker side.
            %e.g:
            % set up tag, indicating that the job have started
            % and process main job control parameters, present in
            % inputs and files:
            %
            % fbMPI               -- the instance of file-based messages
            %                        framework, used to exchange messages
            %                        between worker and control node.
            %                        Depending on the used framework, this
            %                        class can be used as
            % job_control_struct  -- the structure,
            %                        containing information about
            %                        the messages framework to use
            % InitMessage         -- The message with information necessary
            %                        to run the job itself
            %
            % returns:
            % obj          initialized JobExecutor object
            % mess         if not empty, the reason for failure
            %
            [obj,mess]=init_je_(obj,fbMPI,job_control_struct,InitMessage);
        end
        %
        function [ok,mess] =finish_task(this,varargin)
            % Clearly finish job execution amd inform head node about
            %
            %Usage:
            [ok,mess] = finish_task_(this,varargin{:});
        end
        function [ok,err] = reduce_send_message(obj,mess,varargin)
            % collect similar messages send from all nodes and send final
            % message to the head node
            %usage:
            %[ok,err]=Je_instance.reduce_send_message(message,mess_process_function)
            % where:
            % message -- either message to send or the message's to send
            %            name (from the list of accepted names)
            % mess_process_function -- if present, and not empty, the function
            %                          is used to process the messages from
            %                          recevied from all except one workers
            %                          to produce common result. If absend,
            %                          all messages payloads
            %                          are just combined together into
            %                          cellarray and become the payload of
            %                          the final message, sent to head
            %                          node.
            % no_sync  -- if present and true, the command would not wait
            %             for all messages from workers to arrive and
            %             processes only existing messages. if absent or
            %             false, the method would wait until similar
            %             messages are received from all workers in the pool.
            %
            [ok,err,the_mess] = reduce_messages_(obj,mess,varargin{:});
            if obj.labIndex == 1
                [ok,err] = obj.control_node_exch.send_message(0,the_mess);
            end
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
        function id = get.labIndex(obj)
            % get number (job id) of current running job
            id = obj.mess_framework_.labIndex;
        end
        %
        function out = get.task_outputs(obj)
            out = obj.task_results_holder_;
        end
        function obj = set.task_outputs(obj,val)
            obj.task_results_holder_ = val;
        end
        %
        
        %
        function mf= get.mess_framework(obj)
            mf = obj.mess_framework_;
        end
        %
        function mf = get.control_node_exch(obj)
            mf = obj.control_node_exch_;
        end
        %------------------------------------------------------------------
        % MPI interface
        % overloads to exchange messages with JobDispatcher for particular job Executor
        function [ok,err_mess] = send_message(obj,targ_lab,message)
            % send message to job dispatcher
            % input:
            % message -- an instance of the class aMessage to send to job
            %            dispatcher
            %
            [ok,err_mess] = obj.mess_framework_.send_message(targ_lab,...
                message);
        end
        function [ok,err_mess,message] = receive_message(obj,source_lab,mess_name)
            % receive message from job dispatcher
            [ok,err_mess,message] = obj.mess_framework_.receive_message(source_lab,mess_name);
        end
        function ok=probe_message(obj,mess_name)
            all_names = obj.mess_framework_.probe_all([],mess_name);
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
        function messages = receive_all_messages(obj,varargin)
            % retrieve (and remove from system) all messages
            % existing in the system for the jobs with id-s specified as input
            %
            %Return:
            % all_messages -- cellarray of messages belonging to this job
            %                 have messages available in the system .
            %
            if nargin == 2
                mf = varargin{1};
                messages = mf.receive_all();
            else
                messages = obj.mess_framework_.receive_all();
            end
        end
        function labBarrier(obj)
            % implement labBarrier to synchronize various workers.
            obj.mess_framework.labBarrier();
        end
        %
        function is = is_job_cancelled(obj)
            is = obj.control_node_exch_.is_job_cancelled();
        end
    end
    
end

