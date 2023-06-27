classdef test_section < TestCase

    methods
        function obj = test_section(name)
            obj = obj@TestCase(name)
        end

        function obj = test_section_works(obj)
            w = sqw.generate_cube_sqw(10);
            test_sec = w.section([-3 3], [], [], []);
            test_cut = w.cut(ortho_proj([1 0 0], [0 1 0]), [-2.5 1 2.5],[],[],[]);

            assertEqualToTol(test_sec, test_cut);
        end

        function obj = test_section_collapse_dim(obj)
            w = sqw.generate_cube_sqw(10);
            test_sec = w.section([-1 0], [], [], []);
            test_cut = w.cut(ortho_proj([1 0 0], [0 1 0]), [-1 0],[],[],[]);

            assertEqualToTol(test_sec, test_cut);
        end

        function obj = test_section_sqw_array(obj)
            w = sqw.generate_cube_sqw(10);
            test(1) = w;
            test(2) = w;
            test_sec = test.section([-1 0], [], [], []);
            test_cut = w.cut(ortho_proj([1 0 0], [0 1 0]), [-1 0],[],[],[]);

            assertEqualToTol(test_sec(1), test_cut);
            assertEqualToTol(test_sec(2), test_cut);
        end

        function obj = test_section_get_all_bins(obj)
            w = sqw.generate_cube_sqw(10);
            test = w.section([-10 10], [], [], []);

            assertEqualToTol(test, w);
        end

        function obj = test_section_preserves_original(obj)
            w = sqw.generate_cube_sqw(10);
            test = w.section([], [], [], []);

            assertEqualToTol(test, w, '-ignore_date');
        end

        function obj = test_section_no_arg_in_unchanged(obj)
            w = sqw.generate_cube_sqw(10);
            test = w.section();

            assertEqualToTol(test, w);
        end

        function obj = test_section_fails_0_dim(obj)
            w = sqw.generate_cube_sqw(2);
            w = w.cut(ortho_proj([1 0 0], [0 1 0]), [-1 1],[-1 1],[-1 1],[-1 1]);
            assertEqual(w.dimensions(), 0);
            throw = @() section(w, [], [], [], []);

            ME = assertExceptionThrown(throw, 'HORACE:sqw:invalid_argument');
            assertEqual(ME.message, 'Cannot section a zero dimensional object');
        end

        function obj = test_section_fails_diff_dim(obj)
        % Section calls cellfun, so obj array not supported
        % However, section not defined for type cell
            w = sqw.generate_cube_sqw(2);
            test(1) = w.cut(ortho_proj([1 0 0], [0 1 0]), [],[],[-1 1],[-1 1]);
            test(2) = w.copy();
            assertEqual(test(1).dimensions(), 2);
            assertEqual(test(2).dimensions(), 4);
            throw = @() section(test, [], [], [], []);

            ME = assertExceptionThrown(throw, 'HORACE:sqw:invalid_argument');
            assertEqual(ME.message, 'All objects must have same dimensionality for sectioning to work');
        end

        function obj = test_section_fails_bad_narg(obj)
            w = sqw.generate_cube_sqw(2);
            assertEqual(w.dimensions(), 4);
            throw = @() section(w, [], [], []);

            ME = assertExceptionThrown(throw, 'HORACE:sqw:invalid_argument');
            assertEqual(ME.message, 'Check number of arguments');

        end

    end

end
