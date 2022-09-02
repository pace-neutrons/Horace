% Test object which returns some common data, a sum (1..N) where N is the number of steps
% and its (left) neighbour's ID
classdef ExampleRealJobExecutor < JobExecutor

    properties(Access = private)
        finished = false;
        my_int = 0;
    end

    methods

        function obj=reduce_data(obj)
        % Performed at end of do job after synchronise

        % Die after one loop through do_job
            obj.finished = true;
        end

        function ok = is_completed(obj)
        % If returns true, job will not run another cycle of do_job/reduce_data
            ok = obj.finished;
        end

        function obj = do_job(obj)

            % Perform a loop
            for i = 1:obj.n_steps
                obj.my_int = obj.my_int + i;
            end

            % Send my ID to my +1 neighbour
            my_message = DataMessage(obj.labIndex);
            [ok, err_mess] = obj.mess_framework.send_message(mod(obj.labIndex + 1, obj.mess_framework.numLabs)+1, my_message);
            if ~ok
                error('HORACE:ExampleRealJobExecutor:send_error', err_mess)
            end

            % Recieve the data
            [ok, err_mess, data] = obj.mess_framework.receive_message(mod(obj.labIndex + 3, obj.mess_framework.numLabs)+1, 'any');
            if ~ok
                error('HORACE:ExampleRealJobExecutor:receive_error', err_mess)
            end

            % Output some data
            obj.task_outputs = {obj.common_data_, obj.my_int, data};

        end
    end
end
