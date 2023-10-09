classdef test_apply_and_recompute_bin_data < TestCase
    % Series of tests to validate operations using recompute_bin_data and
    % how apply operation works on different type of objects

    properties
        test_sqw
    end

    methods
        function obj=test_apply_and_recompute_bin_data(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_apply_and_recompute_bin_data';
            end
            obj = obj@TestCase(name);
            obj.test_sqw = sqw.generate_cube_sqw(10,@(h,k,l,e,varargin)(2));

        end
        function test_recompute_bin_data_on_file_with_same_name(obj)

            tsqw = obj.test_sqw;
            npix = tsqw.data.npix;
            tsqw.pix = tsqw.pix.invalidate_range();
            tsqw.pix.signal = 4;
            test_file = fullfile(tmp_dir,'recompute_with_pages_same.sqw');
            clFile = onCleanup(@()del_memmapfile_files(test_file));
            save(tsqw,test_file);
            clear tsqw;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',1000);


            tsqw = sqw(test_file,'file_backed',true);
            assertTrue(isa(tsqw.pix,'PixelDataFileBacked'));
            assertFalse(tsqw.pix.is_range_valid())

            new_sqw = recompute_bin_data(tsqw,test_file);
            s = new_sqw.data.s;
            e = new_sqw.data.e;
            assertElementsAlmostEqual(s,4*npix);
            assertElementsAlmostEqual(e,npix);
            assertTrue(new_sqw.pix.is_range_valid())


            assertEqual(new_sqw.full_filename,test_file);
            clear new_sqw;
            clear tsqw;

            assertTrue(is_file(test_file));

            tsqw = sqw(test_file);
            s = tsqw.data.s;
            e = tsqw.data.e;
            assertElementsAlmostEqual(s,4*npix);
            assertElementsAlmostEqual(e,npix);

            assertTrue(tsqw.pix.is_range_valid());
        end
        function test_recompute_bin_data_on_file_with_other_name(obj)

            tsqw = obj.test_sqw;
            npix = tsqw.data.npix;
            tsqw.pix = tsqw.pix.invalidate_range();
            tsqw.pix.signal = 4;
            test_source_file = fullfile(tmp_dir,'recompute_with_pages.sqw');
            test_targ_file = fullfile(tmp_dir,'recompute_with_pages_targ.sqw');            
            clFile1 = onCleanup(@()delete(test_source_file));
            clFile2 = onCleanup(@()delete(test_targ_file));            
            save(tsqw,test_source_file);
            clear tsqw;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',1000);


            tsqw = sqw(test_source_file,'file_backed',true);
            assertTrue(isa(tsqw.pix,'PixelDataFileBacked'));
            assertFalse(tsqw.pix.is_range_valid())

            new_sqw = recompute_bin_data(tsqw,test_targ_file);
            s = new_sqw.data.s;
            e = new_sqw.data.e;
            assertElementsAlmostEqual(s,4*npix);
            assertElementsAlmostEqual(e,npix);
            assertTrue(new_sqw.pix.is_range_valid())


            assertEqual(new_sqw.full_filename,test_targ_file);
            clear new_sqw;
            clear tsqw;

            assertTrue(isfile(test_targ_file));

            tsqw = sqw(test_targ_file);
            s = tsqw.data.s;
            e = tsqw.data.e;
            assertElementsAlmostEqual(s,4*npix,'relative',4*eps('single'));
            assertElementsAlmostEqual(e,npix,'relative',4*eps('single'));

            assertTrue(tsqw.pix.is_range_valid());
        end
        

        function test_recompute_bin_data_on_file(obj)

            tsqw = obj.test_sqw;
            npix = tsqw.data.npix;
            tsqw.pix.signal = 4;

            pix = PixelDataFileBacked(tsqw.pix.data);
            tsqw.pix = pix.invalidate_range();

            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',1000);

            new_sqw = recompute_bin_data(tsqw);
            s = new_sqw.data.s;
            e = new_sqw.data.e;
            assertElementsAlmostEqual(s,4*npix);
            assertElementsAlmostEqual(e,npix);
            assertTrue(new_sqw.pix.is_range_valid())
        end


        function test_recompute_bin_data_in_memory(obj)

            tsqw = obj.test_sqw;
            npix = tsqw.data.npix;
            s = tsqw.data.s;
            e = tsqw.data.e;
            assertElementsAlmostEqual(s,2*npix);
            assertElementsAlmostEqual(e,npix);

            tsqw.pix.signal = 4;
            tsqw.pix = tsqw.pix.invalidate_range();
            assertFalse(tsqw.pix.is_range_valid())

            new_sqw = recompute_bin_data(tsqw);
            s = new_sqw.data.s;
            e = new_sqw.data.e;
            assertElementsAlmostEqual(s,4*npix);
            assertElementsAlmostEqual(e,npix);
            assertTrue(new_sqw.pix.is_range_valid())
        end

    end
end
