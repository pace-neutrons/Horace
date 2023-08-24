classdef test_parallel_cut < TestCase

    methods
        function obj = test_parallel_cut(name)
            if ~exist('name', 'var')
                name = 'test_parallel_cut';
            end
            obj = obj@TestCase(name);
        end

        function test_cut_cube_dummy(~)
            clean = set_temporary_config_options(hpc_config, ...
                                                 'parallel_workers_number', 1, ...
                                                 'parallel_cluster', 'dummy');

            data = sqw.generate_cube_sqw(2);

            proj = line_proj([1 0 0], [0 1 0]);
            params = {[0.5, 1, 2.5], [-5 5], [-5 5], [-5 5]};

            cut_ser = cut(data, proj, params{:});
            cut_par = parallel_call(@cut, {data, proj, params{:}});

            assertEqualToTol(cut_ser.data, cut_par.data, 'ignore_str', true)

        end

        function test_cut_cube_herbert(~)
            skipTest('Job fails on Jenkins for unknown reasons see #1172')
            clean = set_temporary_config_options(hpc_config, ...
                                                 'parallel_workers_number', 2, ...
                                                 'parallel_cluster', 'herbert');

            data = sqw.generate_cube_sqw(2);

            proj = line_proj([1 0 0], [0 1 0]);
            params = {[0.5, 1, 2.5], [-5 5], [-5 5], [-5 5]};

            cut_ser = cut(data, proj, params{:});
            cut_par = parallel_call(@cut, {data, proj, params{:}});

            assertEqualToTol(cut_ser.data, cut_par.data, 'ignore_str', true)

        end

        function test_cut_cube_parpool(~)
            skipTest('Job fails on Jenkins for unknown reasons see #1172')
            clean = set_temporary_config_options(hpc_config, ...
                                                 'parallel_workers_number', 2, ...
                                                 'parallel_cluster', 'parpool');

            data = sqw.generate_cube_sqw(2);

            proj = line_proj([1 0 0], [0 1 0]);
            params = {[0.5, 1, 2.5], [-5 5], [-5 5], [-5 5]};

            cut_ser = cut(data, proj, params{:});
            cut_par = parallel_call(@cut, {data, proj, params{:}});

            assertEqualToTol(cut_ser.data, cut_par.data, 'ignore_str', true)

        end


    end


end
