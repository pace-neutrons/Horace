classdef test_save < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir = tmp_dir();
        tests_dir;
        sqw_file_res = 'test_sqw_main_save_sqw.sqw'
        sqw_obj;
    end

    methods
        function obj = test_save(varargin)
            if nargin == 0
                name = 'test_save';
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
        function test_save_simple_two(obj)
            [~,fn,fe] = fileparts(obj.sqw_file_res);
            file1 = fullfile(tmp_dir,[fn,'_1_',fe]);
            file2 = fullfile(tmp_dir,[fn,'_2_',fe]);
            targ_files = {file1,file2};
            clOb = onCleanup(@()del_memmapfile_files(targ_files));

            data = repmat(obj.sqw_obj,2,1);
            cl = data.save(targ_files);
            assertTrue(isempty(cl));

            assertTrue(isfile(targ_files{1}));
            assertTrue(isfile(targ_files{2}));
            rec = read_sqw(targ_files{2});

            assertEqualToTol(obj.sqw_obj,rec,'tol',[4*eps('single'),4*eps('single')], ...
                'ignore_str',true);
        end

        function test_save_upgrade_automatically_filebacked(obj)

            targ_file = fullfile(tmp_dir,obj.sqw_file_res);
            clOb = onCleanup(@()del_memmapfile_files(targ_file));

            clConf = set_temporary_config_options( ...
                hor_config,'mem_chunk_size',3000,'fb_scale_factor',3);
            ldr = faccess_sqw_v2();
            test_obj = obj.sqw_obj.save(targ_file,ldr);
            ldr.delete();

            assertTrue(test_obj.is_filebacked)
            test_obj.data.title = 'My image';

            test_obj.save(targ_file);

            ldr = sqw_formats_factory.instance().get_loader(targ_file);
            assertTrue(isa(ldr,'faccess_sqw_v4'));
            rec = ldr.get_sqw();
            ldr.delete();

            assertEqualToTol(rec,test_obj)
        end

        function test_save_upgrade_automatically_membased_large_page(obj)

            targ_file = fullfile(tmp_dir,obj.sqw_file_res);
            clOb = onCleanup(@()del_memmapfile_files(targ_file));

            ldr = faccess_sqw_v2();
            test_obj = obj.sqw_obj.save(targ_file,ldr);
            ldr.delete();

            assertTrue(test_obj.is_filebacked)
            test_obj.data.title = 'My image';

            test_obj.save(targ_file);

            ldr = sqw_formats_factory.instance().get_loader(targ_file);
            assertTrue(isa(ldr,'faccess_sqw_v4'));
            rec = ldr.get_sqw();
            ldr.delete();

            assertEqualToTol(rec,test_obj)

        end
        function test_upgrade_all_bar_pix_filebacked_large_page(obj)

            targ_file = fullfile(tmp_dir,obj.sqw_file_res);
            clOb = onCleanup(@()del_memmapfile_files(targ_file));

            test_obj = obj.sqw_obj.save(targ_file);

            assertTrue(test_obj.is_filebacked)
            test_obj.data.title = 'My image';

            test_obj.save(targ_file);

            ldr = sqw_formats_factory.instance().get_loader(targ_file);
            assertTrue(isa(ldr,'faccess_sqw_v4'));
            rec = ldr.get_sqw();
            ldr.delete();

            assertEqualToTol(rec,test_obj)
        end
        
        
        function test_save_invalid_arguments_throw(obj)
            targ_file = fullfile(tmp_dir,obj.sqw_file_res);

            ldr = faccess_sqw_v2();
            assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj] ...
                ),'HORACE:sqw:invalid_argument');

            assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                targ_file),'HORACE:sqw:invalid_argument');
            assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                {'file1','file2'},'-make_temp'),'HORACE:sqw:invalid_argument');

            assertExceptionThrown(@()save(obj.sqw_obj, ...
                'file1','bla=bla'),'HORACE:sqw:invalid_argument');
            assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                {'file1','file2'},'bla=bla'),'HORACE:sqw:invalid_argument');
            assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                {'file1',ldr}),'HORACE:sqw:invalid_argument');

            assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                {'fule1','file2'},{ldr,'file1'}),'HORACE:sqw:invalid_argument');


        end

        function test_save_with_loader(obj)
            targ_file = fullfile(tmp_dir,obj.sqw_file_res);
            clOb = onCleanup(@()del_memmapfile_files(targ_file));

            ldr = faccess_sqw_v2();
            wout = obj.sqw_obj.save(targ_file,ldr);
            assertTrue(wout.is_filebacked);

            assertTrue(isfile(targ_file));
            ldr = sqw_formats_factory.instance().get_loader(targ_file);
            assertTrue(isa(ldr,'faccess_sqw_v2'));
            rec = ldr.get_sqw();
            ldr.delete();

            assertEqualToTol(obj.sqw_obj,rec, ...
                'tol',[4*eps('single'),4*eps('single')], ...
                'ignore_str',true,'-ignore_date');
        end

        function test_save_simple(obj)
            targ_file = fullfile(tmp_dir,obj.sqw_file_res);
            clOb = onCleanup(@()del_memmapfile_files(targ_file));

            wout = obj.sqw_obj.save(targ_file);
            assertTrue(wout.is_filebacked);

            assertTrue(isfile(targ_file));
            rec = read_sqw(targ_file);

            assertEqualToTol(obj.sqw_obj,rec,'tol',[4*eps('single'),4*eps('single')], ...
                'ignore_str',true);
            % clear output object to release targ_file for deletion
            clear wout;
        end

    end
end
