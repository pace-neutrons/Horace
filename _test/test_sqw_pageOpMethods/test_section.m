classdef test_section < TestCase

    methods
        function obj = test_section(name)
            obj = obj@TestCase(name)
        end

        function obj = test_section_works(obj)
            w = sqw.generate_cube_sqw(10);
            test_sec = w.section([-3 3], [], [], []);
            test_cut = w.cut(line_proj([1 0 0], [0 1 0]), [-2.5 1 2.5],[],[],[]);


            assertEqualToTol(test_sec, test_cut);
            assertTrue(obj.is_bins_subset_of(test_sec.data.axes.p, w.data.axes.p));
        end

        function obj = test_section_sqw_fb(obj)
            w = sqw.generate_cube_sqw(10);
            test_sec_mb = w.section([-3 3], [], [], []);
            test_file = fullfile(tmp_dir(),'test_section_fb.sqw');
            clFile = onCleanup(@()del_memmapfile_files(test_file));
            save(w,test_file);

            coWarn = set_temporary_warning('off','HOR_CONFIG:set_mem_chunk_size');
            clob = set_temporary_config_options(hor_config, 'mem_chunk_size', 500);
            wfb = sqw(test_file,'file_backed',true);

            test_sec_fb = wfb.section([-3 3], [], [], []);

            % Re #1350 saved and recovered detector arrays are different
            test_sec_fb.experiment_info.detector_arrays= test_sec_mb.experiment_info.detector_arrays;
            assertEqualToTol(test_sec_mb, test_sec_fb,...
                'ignore_str', true,'-ignore_date');
            skipTest('Re #1350 Saved and recovered dectector arrays are different. This is bug with arrays, not section')

        end

        function test_section_collapse_dim(obj)
            w = sqw.generate_cube_sqw(10);
            test_sec = w.section([-1 0], [], [], []);
            test_cut = w.cut(line_proj([1 0 0], [0 1 0]), [-1 0],[],[],[]);

            assertEqualToTol(test_sec, test_cut);

            assertTrue(obj.is_bins_subset_of(...
                [{test_sec.data.axes.iint'} test_sec.data.axes.p], ...
                w.data.axes.p));
        end

        function test_section_sqw_array(obj)
            w = sqw.generate_cube_sqw(10);
            test(1) = w;
            test(2) = w;
            test_sec = test.section([-3 3], [], [], []);
            test_cut = w.cut(line_proj([1 0 0], [0 1 0]), [-2.5 1 2.5],[],[],[]);

            assertEqualToTol(test_sec(1), test_cut);
            assertEqualToTol(test_sec(2), test_cut);
            assertTrue(obj.is_bins_subset_of(test_sec(1).data.axes.p, w.data.axes.p))
            assertTrue(obj.is_bins_subset_of(test_sec(2).data.axes.p, w.data.axes.p))
        end

        function test_section_get_all_bins(~)
            w = sqw.generate_cube_sqw(10);
            test = w.section([-10 10], [], [], []);

            assertEqualToTol(test, w);
        end

        function test_section_preserves_original(~)
            w = sqw.generate_cube_sqw(10);
            test = w.section([], [], [], []);

            assertEqualToTol(test, w, '-ignore_date');
        end

        function test_section_no_arg_in_unchanged(~)
            w = sqw.generate_cube_sqw(10);
            test = w.section();

            assertEqualToTol(test, w);
        end

        function test_section_fails_0_dim(~)
            w = sqw.generate_cube_sqw(2);
            w = w.cut(line_proj([1 0 0], [0 1 0]), [-1 1],[-1 1],[-1 1],[-1 1]);
            assertEqual(w.dimensions(), 0);
            throw = @() section(w, [], [], [], []);

            ME = assertExceptionThrown(throw, 'HORACE:sqw:invalid_argument');
            assertEqual(ME.message, 'Cannot section a zero dimensional object');
        end

        function test_section_fails_diff_dim(~)
            % Section calls cellfun, so obj array not supported
            % However, section not defined for type cell
            w = sqw.generate_cube_sqw(2);
            test(1) = w.cut(line_proj([1 0 0], [0 1 0]), [],[],[-1 1],[-1 1]);
            test(2) = w.copy();
            assertEqual(test(1).dimensions(), 2);
            assertEqual(test(2).dimensions(), 4);
            throw = @() section(test, [], [], [], []);

            ME = assertExceptionThrown(throw, 'HORACE:sqw:invalid_argument');
            assertEqual(ME.message, 'All objects must have same dimensionality for sectioning to work');
        end

        function test_section_fails_bad_narg(~)
            w = sqw.generate_cube_sqw(2);
            assertEqual(w.dimensions(), 4);
            throw = @() section(w, [], [], []);

            ME = assertExceptionThrown(throw, 'HORACE:sqw:invalid_argument');
            assertEqual(ME.message, 'Check number of arguments');
        end

        function test_find_section_3D(~)
            nbins = ones(10,10,10);
            sel = [4,4,4;8,8,8];
            [bl_start,bl_size] = PageOp_section.find_section(nbins,sel);
            assertEqual(bl_start(1:6),[334;344;354;364;374;434]);
            assertEqual(bl_size,5*ones(25,1));
        end

        function test_find_section_2D(~)
            nbins = ones(10,10);
            sel = [4,4;8,8];
            [bl_start,bl_size] = PageOp_section.find_section(nbins,sel);
            assertEqual(bl_start,[34;44;54;64;74]);
            assertEqual(bl_size,5*ones(5,1));
        end

        function test_find_section_1D(~)
            nbins = ones(1,10);
            sel = [4;8];
            [bl_start,bl_size] = PageOp_section.find_section(nbins,sel);
            assertEqual(bl_start,sel(1,1));
            assertEqual(bl_size,5);
        end

    end

    methods(Static)
        function is = is_bins_subset_of(a, b)
            is = cellfun(@ismember, a, b, 'UniformOutput', false);
            is = cell2mat(is);
            is = all(is);
        end
    end

end
