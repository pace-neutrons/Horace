classdef test_sqw_main < TestCase & common_state_holder
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir = tmp_dir();
        tests_dir;
    end

    methods
        function obj = test_sqw_main(name)
            obj = obj@TestCase(name);
            pths = horace_paths();
            obj.tests_dir = pths.test;
        end

        function test_sqw_constructor(~)
            data = d2d();
            sqw_obj = sqw(data);
            assertTrue(sqw_obj.dnd_type)
        end

        function test_read_sqw(obj)

            test_data = fullfile(obj.tests_dir, 'test_change_crystal', 'wref.sqw');
            out_dnd_file = fullfile(obj.out_dir, 'test_sqw_main_test_read_sqw_dnd.sqw');
            cleanup_obj = onCleanup(@()delete(out_dnd_file));

            sqw_data = read_sqw(test_data);
            assertTrue(isa(sqw_data,'sqw'))

            assertElementsAlmostEqual(sqw_data.data.alatt,[2.8700 2.8700 2.8700],'absolute',1.e-4);
            assertElementsAlmostEqual(size(sqw_data.data.npix),[21,20]);
            assertElementsAlmostEqual(sqw_data.data.pax,[2,4]);
            assertElementsAlmostEqual(sqw_data.data.iax,[1,3]);

            test_dnd = d2d(sqw_data);
            [targ_path,targ_file,fext] = fileparts(out_dnd_file);
            save(test_dnd,out_dnd_file);
            loaded_dnd = read_dnd(out_dnd_file);
            assertTrue(isa(loaded_dnd,'d2d'));

            test_dnd.filename = [targ_file, fext];
            test_dnd.filepath = [targ_path, filesep];

            assertEqualToTol(loaded_dnd, test_dnd,1.e-12, 'ignore_str', true);
        end

        function test_setting_pix_page_size_in_constructor_pages_pixels(~)
            % hide warnings when setting pixel page size very small
            page_size = 1000;
            clObj = set_temporary_config_options(hor_config, 'mem_chunk_size', page_size);

            pths = horace_paths();
            fpath = fullfile(pths.test_common, 'sqw_1d_2.sqw');

            % set page size accepting half of the pixels
            sqw_obj = sqw(fpath, ...
                'file_backed',true);
            sqw_pix_pg_size = sqw_obj.pix.page_size;


            % check we're actually paging pixels
            assertTrue(sqw_obj.pix.num_pixels > sqw_pix_pg_size);

            % check the page size is what we set it to
            assertEqual(sqw_pix_pg_size, page_size);
        end

        function test_pixels_not_paged_if_pixel_page_size_arg_not_given(obj)
            fpath = fullfile(obj.tests_dir, 'common_data', 'sqw_1d_2.sqw');
            sqw_obj = sqw(fpath);

            sqw_pix_pg_size = sqw_obj.pix.page_size;
            assertEqual(sqw_pix_pg_size, sqw_obj.pix.num_pixels);
        end
    end
end
