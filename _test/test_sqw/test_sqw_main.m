classdef test_sqw_main < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir = tmp_dir();
        tests_dir = fileparts(fileparts(mfilename('fullpath')));
    end

    methods
        function obj = test_sqw_main(name)
            obj = obj@TestCase(name);
        end
        
        function test_sqw_constructor(~)
            skipTest("Construction of sqw from data_sqw_dnd not yet available");
            data = data_sqw_dnd();
            sqw_obj = sqw(data);
            assertTrue(sqw_obj.data.dnd_type)
        end
        
        function test_read_sqw(obj)
            test_data = fullfile(obj.tests_dir, 'test_change_crystal', 'wref.sqw');
            out_dnd_file = fullfile(obj.out_dir, 'test_sqw_main_test_read_sqw_dnd.sqw');
            cleanup_obj = onCleanup(@()delete(out_dnd_file));

            sqw_data = sqw(test_data);
            assertTrue(isa(sqw_data,'sqw'))

            assertElementsAlmostEqual(sqw_data.data.alatt,[2.8700 2.8700 2.8700],'absolute',1.e-4);
            assertElementsAlmostEqual(size(sqw_data.data.npix),[21,20]);
            assertElementsAlmostEqual(sqw_data.data.pax,[2,4]);
            assertElementsAlmostEqual(sqw_data.data.iax,[1,3]);

            test_dnd = d2d(sqw_data);
            [targ_path,targ_file,fext] = fileparts(out_dnd_file);
            save(test_dnd,out_dnd_file)
            loaded_dnd = read_dnd(out_dnd_file);
            assertTrue(isa(loaded_dnd,'d2d'))
            %
            test_dnd.filename = [targ_file, fext];
            test_dnd.filepath = [targ_path, filesep];

            [ok, mess] = equal_to_tol(loaded_dnd, test_dnd, 'ignore_str', true);
            assertTrue(ok, mess)
        end

        function test_setting_pix_page_size_in_constructor_pages_pixels(obj)
            % hide warnings when setting pixel page size very small
            old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');
            cleanup = onCleanup(@() warning(old_warn_state));

            fpath = fullfile(obj.tests_dir, 'test_sqw_file', 'sqw_1d_2.sqw');
            page_size_bytes = 7.8e4;
            sqw_obj = sqw(fpath, 'pixel_page_size', page_size_bytes);
            sqw_pix_pg_size = sqw_obj.data.pix.page_size;

            % check we're actually paging pixels
            assertTrue(sqw_obj.data.pix.num_pixels > sqw_pix_pg_size);

            % check the page size is what we set it to
            pix_size = PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
            expected_pg_size = floor(page_size_bytes/pix_size);
            assertEqual(sqw_pix_pg_size, expected_pg_size);
        end

        function test_pixels_not_paged_if_pixel_page_size_arg_not_given(obj)
            fpath = fullfile(obj.tests_dir, 'test_sqw_file', 'sqw_1d_2.sqw');
            sqw_obj = sqw(fpath);

            sqw_pix_pg_size = sqw_obj.data.pix.page_size;
            assertEqual(sqw_pix_pg_size, sqw_obj.data.pix.num_pixels);
        end

        function test_error_setting_negative_pix_page_size_in_constructor(obj)
            fpath = fullfile(obj.tests_dir, 'test_sqw_file', 'sqw_1d_2.sqw');
            page_size_bytes = -1000;
            f = @() sqw(fpath, 'pixel_page_size', page_size_bytes);
            assertExceptionThrown(f, 'PIXELDATA:validate_mem_alloc');
        end

        function test_error_setting_non_numeric_pix_page_size_in_constructor(obj)
            fpath = fullfile(obj.tests_dir, 'test_sqw_file', 'sqw_1d_2.sqw');
            s = struct();
            f = @() sqw(fpath, 'pixel_page_size', s);
            assertExceptionThrown(f, 'PIXELDATA:validate_mem_alloc');
        end

    end
end
