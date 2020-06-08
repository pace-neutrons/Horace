classdef test_mpiexec_send_and_receive < TestCase

properties
    original_pconfig;
end
methods

    function obj = setUp(obj)
        [pc, obj.original_pconfig] = set_local_parallel_config();
        pc.parallel_framework = 'mpiexec_mpi';
    end

    function tearDown(obj)
        set(parallel_config, obj.original_pconfig);
    end

    function test_path_returned_by_get_mpiexec_exists(~)
        mpiexec_path = ClusterMPI.get_mpiexec();
        assertTrue(isfile(mpiexec_path));
    end

    function test_mpiexec_can_send_and_receive_hello_world_messages(~)
        job_class_name = 'HelloWorldJob';
        common_param = struct('base_msg', 'Hello world, from labIndex ');
        loop_params = 3;
        n_workers = 3;
        return_results = true;
        keep_workers_running = false;
        task_query_time = 1;  % second(s)

        jd = JobDispatcher();
        [out, ~, ~] = jd.start_job(...
            job_class_name, ...
            common_param, ...
            loop_params, ...
            return_results, ...
            n_workers, ...
            keep_workers_running, ...
            task_query_time);

        master_node_output = out{1};
        for worker_idx = 1:n_workers
            expected_msg = [common_param.base_msg, num2str(worker_idx)];
            actual_msg = master_node_output{worker_idx};
            assertEqual(actual_msg, expected_msg);
        end
    end

end

end
