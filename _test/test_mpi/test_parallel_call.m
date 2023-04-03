classdef test_parallel_call < TestCase

    properties
        sqw_obj_mb;
        sqw_obj_fb;

        ser;

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
            obj.sqw_obj_fb = sqw(test_sqw_file, 'file_backed', true);

            obj.sqw_obj_mb = obj.sqw_obj_fb;
            obj.sqw_obj_mb.pix = PixelDataMemory(obj.sqw_obj_fb.pix);

            obj.ser = obj.sqw_obj_fb.sqw_eval(@obj.sqw_eval_tester, {});

            hc = hpc_config();
            obj.stored_hpc = hc.get_data_to_store();
            pc = parallel_config();
            obj.stored_par = pc.get_data_to_store();

        end

        function tearDown(obj)
            set(hpc_config, obj.stored_hpc);
            set(parallel_config, obj.stored_par);
        end

        function test_parallel_call_herbert_sqw_eval_filebacked(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'herbert';
            pc.parallel_workers_number = 4;

            par = parallel_call(@sqw_eval, {obj.sqw_obj_fb, @obj.sqw_eval_tester, {}});

            assertEqualToTol(obj.ser.data.s, par.data.s, 'tol', [1e-6, 1e-6])
            assertEqualToTol(obj.ser.pix, par.pix, 'tol', [1e-6, 1e-6])
        end

        function test_parallel_call_parpool_sqw_eval_filebacked(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'parpool';
            pc.parallel_workers_number = 4;

            par = parallel_call(@sqw_eval, {obj.sqw_obj_fb, @obj.sqw_eval_tester, {}});

            assertEqualToTol(obj.ser.data.s, par.data.s, 'tol', [1e-6, 1e-6])
            assertEqualToTol(obj.ser.pix, par.pix, 'tol', [1e-6, 1e-6])
        end

        function test_parallel_call_mpiexec_mpi_sqw_eval_filebacked(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'mpiexec_mpi';
            pc.parallel_workers_number = 2;

            par = parallel_call(@sqw_eval, {obj.sqw_obj_fb, @obj.sqw_eval_tester, {}});

            assertEqualToTol(obj.ser.data.s, par.data.s, 'tol', [1e-6, 1e-6])
            assertEqualToTol(obj.ser.pix, par.pix, 'tol', [1e-6, 1e-6])
        end

        function test_parallel_call_dummy_mpi_sqw_eval_filebacked(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'dummy';
            pc.parallel_workers_number = 1;

            par = parallel_call(@sqw_eval, {obj.sqw_obj_fb, @obj.sqw_eval_tester, {}});

            assertEqualToTol(obj.ser.data.s, par.data.s, 'tol', [1e-6, 1e-6])
            assertEqualToTol(obj.ser.pix, par.pix, 'tol', [1e-6, 1e-6])
        end

        function test_parallel_call_herbert_sqw_eval_memory(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'herbert';
            pc.parallel_workers_number = 4;

            par = parallel_call(@sqw_eval, {obj.sqw_obj_mb, @obj.sqw_eval_tester, {}});

            assertEqualToTol(obj.ser.data.s, par.data.s, 'tol', [1e-6, 1e-6])
            assertEqualToTol(obj.ser.pix, par.pix, 'tol', [1e-6, 1e-6])
        end

        function test_parallel_call_parpool_sqw_eval_memory(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'parpool';
            pc.parallel_workers_number = 4;

            par = parallel_call(@sqw_eval, {obj.sqw_obj_mb, @obj.sqw_eval_tester, {}});

            assertEqualToTol(obj.ser.data.s, par.data.s, 'tol', [1e-6, 1e-6])
            assertEqualToTol(obj.ser.pix, par.pix, 'tol', [1e-6, 1e-6])
        end

        function test_parallel_call_mpiexec_mpi_sqw_eval_memory(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'mpiexec_mpi';
            pc.parallel_workers_number = 4;

            par = parallel_call(@sqw_eval, {obj.sqw_obj_mb, @obj.sqw_eval_tester, {}});

            assertEqualToTol(obj.ser.data.s, par.data.s, 'tol', [1e-6, 1e-6])
            assertEqualToTol(obj.ser.pix, par.pix, 'tol', [1e-6, 1e-6])
        end

        function test_parallel_call_dummy_mpi_sqw_eval_memory(obj)
            pc = parallel_config();
            pc.parallel_cluster = 'dummy';
            pc.parallel_workers_number = 1;

            par = parallel_call(@sqw_eval, {obj.sqw_obj_mb, @obj.sqw_eval_tester, {}});

            assertEqualToTol(obj.ser.data.s, par.data.s, 'tol', [1e-6, 1e-6])
            assertEqualToTol(obj.ser.pix, par.pix, 'tol', [1e-6, 1e-6])
        end


    end

    methods(Static)
        function dis = sqw_eval_tester(h,k,l,en,~)
            dis = (sin(h) + cos(k) + tan(l)) .* en;
        end
    end

end
