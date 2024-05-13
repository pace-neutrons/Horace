classdef test_pc_spec_config < TestCase
    % Testing default configuration manager, selecting
    % configuration as function of a pc type

    methods

        function obj = test_pc_spec_config(name)
            if nargin<1
                name = 'test_pc_spec_config';
            end
            obj = obj@TestCase(name);
        end

        function test_optimal_configuration(obj)

            [hc, pc, hpc] = optimal_configuration('dryrun', true, ...
                                                  'quiet', true);

            assertEqualToTol(hc.mem_chunk_size, ...
                             0.6 * sys_memory() / ...
                             (8 * PixelDataBase.DEFAULT_NUM_PIX_FIELDS))
            assertEqual(pc.parallel_workers_number, feature('numcores'))
            assertEqual(pc.threads, 0)
            assertEqual(pc.parallel_threads, 0)

        end

        function test_opt_conf_w_ncores(obj)

            [hc, pc, hpc] = optimal_configuration('num_cores', 2, 'dryrun', true, ...
                                                  'quiet', true);

            assertEqual(pc.parallel_workers_number, 2)
            assertEqual(pc.threads, 2)
            assertEqual(pc.parallel_threads, 1)

        end

        function test_opt_conf_w_mem(~)

            [hc, pc, hpc] = optimal_configuration('system_memory', 80000, 'dryrun', true, ...
                                                  'quiet', true);

            assertEqualToTol(hc.mem_chunk_size, 666)
            assertEqual(hpc.mex_combine_buffer_size, 6000)

            [hc, pc, hpc] = optimal_configuration('system_memory', 80000, 'mem_pct', 50, 'dryrun', true, ...
                                                  'quiet', true);

            assertEqualToTol(hc.mem_chunk_size, 555)
            assertEqual(hpc.mex_combine_buffer_size, 5000)
        end

    end
end
