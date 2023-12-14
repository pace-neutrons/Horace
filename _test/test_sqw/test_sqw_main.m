classdef test_sqw_main < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir = tmp_dir();
        tests_dir;
        sqw_file_res = 'test_sqw_main_save_sqw.sqw'
        sqw_obj;
    end

    methods
        function obj = test_sqw_main(varargin)
            if nargin == 0
                name = 'test_sqw_main';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            pths = horace_paths();
            obj.tests_dir = pths.test;

            pths = horace_paths;
            data_dir = pths.test_common;
            par_file=  'map_4to1_dec09.par';
            par_file = fullfile(data_dir,par_file);

            en=-80:8:760;


            efix=800;
            emode=1;
            alatt=[2.87,2.87,2.87];
            angdeg=[90,90,90];
            u=[1,0,0];
            v=[0,1,0];
            omega=1;dpsi=2;gl=3;gs=4;

            psi=4;

            obj.sqw_obj = dummy_sqw(en, par_file, '', efix,...
                emode, alatt, angdeg,...
                u, v, psi, omega, dpsi, gl, gs,...
                [10,5,5,5]);
            obj.sqw_obj = obj.sqw_obj{1};

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
            pths = horace_paths();
            fpath = fullfile(pths.test_common, 'sqw_1d_2.sqw');
            clWarn = set_temporary_warning('off','HORACE:old_file_format');
            % set page size accepting half of the pixels
            sq_obj = sqw(fpath, ...
                'file_backed',true);

            % check we're actually got filebacked data
            assertTrue(isa(sq_obj.pix,'PixelDataFileBacked'));

        end

        function test_pixels_not_paged_if_pixel_page_size_arg_not_given(obj)
            fpath = fullfile(obj.tests_dir, 'common_data', 'sqw_1d_2.sqw');
            sq_obj = sqw(fpath);

            sqw_pix_pg_size = sq_obj.pix.page_size;
            assertEqual(sqw_pix_pg_size, sq_obj.pix.num_pixels);
        end

        function test_sqw_constructor(~)
            data = d2d();
            tsqw_obj = sqw(data);
            assertTrue(tsqw_obj.dnd_type)
        end
    end
end
