classdef ParallelSQWEval < JobExecutor

    methods
        % Constructor cannot take args as constructed by JobDispatcher
        function obj = ParallelSQWEval()
            obj = obj@JobExecutor();
        end

        function obj=reduce_data(obj)
        % Performed at end of do job after synchronise
        % Required for API
        end

        function ok = is_completed(obj)
        % If returns true, job will not run another cycle of do_job/reduce_data
        % This never needs more than one cycle
            ok = true;
        end

        function obj = setup(obj)
            data = obj.loop_data_{1};
            common = obj.common_data_;

            w_out = common.func(data.w, common.args{:})
            obj.task_outputs = w_out;

        end

        function obj = do_job(obj)
        % Required for API
        end
    end

end