% Example object which just demonstrates the methods and variables available in JobExecutor
% and where they come from
classdef ExampleJobExecutor < JobExecutor
    methods
        function obj = ExampleJobExecutor()
        % Constructor cannot take args as constructed by JobDispatcher
        end

        function obj=reduce_data(obj)
        % Performed at end of do job after synchronise
        end

        function ok = is_completed(obj)
        % If returns true, job will not run another cycle of do_job/reduce_data
        end

        function obj = do_job(obj)
        % Run once per iteration if "is_completed" does not return true

       %% Data
        % Each job executor will have access to the following data
        % Each datum is local, and if changed, copy will update on local process only

        % Either an empty array if given int loop count or
        % data passed through start_job's loop_params
            obj.loop_data_
        % Same copy of data initially sent to each process
        % passed through start_job's common_params.
            obj.common_data_
        % Number of iterations given if job given number of loops
            obj.n_steps
        % Value returned to outputs
            obj.task_outputs
        % Internal ID of this process
            obj.labIndex
        end
    end
end
