classdef test_join < TestCase
    properties
        test_dir;
    end

    methods
        function obj = test_join(~)
            obj = obj@TestCase('test_join');
            hc = horace_paths;
            obj.test_dir = hc.test_common;
        end

        function test_split_cube_1_run(obj)
            sqw_obj = sqw.generate_cube_sqw(10);

            split_obj = split(sqw_obj);
            reformed_obj = join(sqw_obj);

            assertEqualToTol(split_obj, reformed_obj)
            assertEqualToTol(sqw_obj, reformed_obj)
        end

        function test_split_cube_2_run(obj)
            sqw_obj = sqw.generate_cube_sqw(10);

            sqw_obj.pix.run_idx(8:end) = 2;
            sqw_obj.main_header.nfiles = 2;

            sqw_obj.experiment_info.expdata(2) = struct( ...
                "filename", 'fake', ...
                "filepath", '/fake', ...
                "efix", 1, ...
                "emode", 1, ...
                "cu", 1, ...
                "cv", 1, ...
                "psi", 1, ...
                "omega", 1, ...
                "dpsi", 1, ...
                "gl", 1, ...
                "gs", 1, ...
                "en", 10, ...
                "uoffset", [0 0 0], ...
                "u_to_rlu", eye(3), ...
                "ulen", 1.0, ...
                "ulabel", 'rrr', ...
                "run_id", 1);
            sqw_obj.experiment_info.runid_map(2) = 2;

            split_obj = sqw_obj.split();

            assertEqual(numel(split_obj), 2)

            reformed_obj = join(sqw_obj);

            assertEqualToTol(sqw_obj, reformed_obj)
        end

        function test_split_and_join_returns_same_object_including_pixels(obj)

            fpath = fullfile(obj.test_dir, 'sqw_2d_1.sqw');
            sqw_obj = sqw(fpath);
            split_obj = split(sqw_obj);

            assertTrue(all(arrayfun(@(x) x.main_header.nfiles == 1, split_obj)));

            reformed_obj = join(split_obj);

            % Split reindexes from 1
            reformed_obj.pix.run_idx = reformed_obj.pix.run_idx + min(sqw_obj.pix.run_idx) - 1;

            assertEqualToTol(sqw_obj, reformed_obj, [1e-6, 1e-4], 'ignore_str', true);
        end
    end
end
