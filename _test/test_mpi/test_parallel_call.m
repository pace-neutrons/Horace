classdef test_parallel_call < TestCase

    properties
        sqw_obj;
        stored_hpc;
        stored_par;
    end

    methods

        function obj = test_parallel_call(name)
            if ~exist('name', 'var')
                name = 'test_parallel_call';
            end
            obj = obj@TestCase(name);

            pths = horace_paths();
            data_dir = pths.test_common;
            test_sqw_file = fullfile(data_dir,'sqw_2d_2.sqw');
            obj.sqw_obj = sqw(test_sqw_file);

            hc = hpc_config();
            obj.stored_hpc = hc.get_data_to_store();
            pc = parallel_config();
            obj.stored_par = pc.get_data_to_store();

        end

        function tearDown(obj)
            set(hpc_config, obj.stored_hpc);
            set(parallel_config, obj.stored_par);
        end

        function test_parallel_call_herbert_sqw_eval(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'herbert';
            pc.parallel_workers_number = 4;

            ser = obj.sqw_obj.sqw_eval(@obj.sqw_eval_tester, {});
            par = parallel_call(@sqw_eval, {obj.sqw_obj, @obj.sqw_eval_tester, {}});

            assertEqual(ser.data.s, par.data.s)
            assertEqual(ser.pix.signal, par.pix.signal)
        end

        function test_parallel_call_parpool_sqw_eval(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'parpool';
            pc.parallel_workers_number = 4;

            ser = obj.sqw_obj.sqw_eval(@obj.sqw_eval_tester, {});
            par = parallel_call(@sqw_eval, {obj.sqw_obj, @obj.sqw_eval_tester, {}});

            assertEqual(ser.data.s, par.data.s)
            assertEqual(ser.pix.signal, par.pix.signal)
        end

        function test_parallel_call_mpiexec_mpi_sqw_eval(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'mpiexec_mpi';
            pc.parallel_workers_number = 4;

            ser = obj.sqw_obj.sqw_eval(@obj.sqw_eval_tester, {});
            par = parallel_call(@sqw_eval, {obj.sqw_obj, @obj.sqw_eval_tester, {}});

            assertEqual(ser.data.s, par.data.s)
            assertEqual(ser.pix.signal, par.pix.signal)
        end

        function test_parallel_call_dummy_mpi_sqw_eval(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'dummy';
            pc.parallel_workers_number = 1;

            ser = obj.sqw_obj.sqw_eval(@obj.sqw_eval_tester, {});
            par = parallel_call(@sqw_eval, {obj.sqw_obj, @obj.sqw_eval_tester, {}});

            assertEqual(ser.data.s, par.data.s)
            assertEqual(ser.pix.signal, par.pix.signal)
        end

    end

    methods(Static)
        function dis = sqw_eval_tester(h,k,l,en,~)
            dis = (sin(h) + cos(k) + tan(l)) .* en;
        end
    end

end
