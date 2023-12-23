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
            rec = data.save(targ_files);

            assertTrue(isfile(targ_files{1}));
            assertTrue(isfile(targ_files{2}));

            assertEqualToTol(data,rec,'tol',[4*eps('single'),4*eps('single')], ...
                'ignore_str',true);
        end

        %------------------------------------------------------------------
        function test_save_upgrade_automatically_filebacked(obj)

            targ_file = fullfile(tmp_dir,obj.sqw_file_res);
            clOb = onCleanup(@()del_memmapfile_files(targ_file));

            clConf = set_temporary_config_options( ...
                hor_config,'mem_chunk_size',500000,'fb_scale_factor',3);
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

            assertEqualToTol(rec,test_obj,'tol',[4*eps('single'),4*eps('single')],'-ignore_date')
        end

        function test_save_upgrade_automatically_filebacked_large_page(obj)

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

            assertEqualToTol(rec,test_obj,'tol',[4*eps('single'),4*eps('single')])

        end
        %
        function test_save_tmp_moves_to_new_file_upgrades_all_bar_pix(obj)
            source_to_move = fullfile(tmp_dir,'test_save_tmp_moves.tmp');
            targ_file      = fullfile(tmp_dir,'save_filebacked_different_file.sqw');
            clOb = onCleanup(@()del_memmapfile_files(targ_file));

            test_obj = obj.sqw_obj.save(source_to_move);
            assertTrue(test_obj.is_filebacked)
            assertTrue(test_obj.is_tmp_obj)

            test_obj.data.title = 'My image';

            test_obj.save(targ_file);
            assertFalse(isfile(source_to_move));

            ldr = sqw_formats_factory.instance().get_loader(targ_file);
            assertTrue(isa(ldr,'faccess_sqw_v4'));
            rec = ldr.get_sqw();
            ldr.delete();

            test_obj = obj.sqw_obj;
            test_obj.data.title = 'My image';
            assertEqualToTol(rec,test_obj,'ignore_str',true,'tol',[4*eps('single'),4*eps('single')]);
        end
        %------------------------------------------------------------------
        function test_save_permanent_creates_new_file(obj)
            source_for_fb = fullfile(tmp_dir,obj.sqw_file_res);
            targ_file      = fullfile(tmp_dir,'save_filebacked_different_file.sqw');
            clOb = onCleanup(@()del_memmapfile_files(source_for_fb,targ_file));

            test_obj = obj.sqw_obj.save(source_for_fb);

            assertTrue(test_obj.is_filebacked)
            test_obj.data.title = 'My image';

            test_obj.save(targ_file);
            assertTrue(isfile(source_for_fb));

            ldr = sqw_formats_factory.instance().get_loader(targ_file);
            assertTrue(isa(ldr,'faccess_sqw_v4'));
            rec = ldr.get_sqw();
            ldr.delete();

            assertEqualToTol(rec,test_obj,'ignore_str',true);
        end

        function test_save_invalid_arguments_throw(obj)
            targ_file = fullfile(tmp_dir,obj.sqw_file_res);

            ldr = faccess_sqw_v2();
            ME1= assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj] ...
                ),'HORACE:sqw:invalid_argument');
            % multiple object saving request multiple filenames provided
            assertTrue(strncmp(ME1.message,'No target filenames provided to save method',35));

            ME2 = assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                targ_file),'HORACE:sqw:invalid_argument');
            assertTrue(strncmp(ME2.message,'No target filenames provided to save method',35));

            ME3 = assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                {'file1','file2'},'-make_temp'),'HORACE:sqw:invalid_argument');
            assertTrue(strncmp(ME3.message, ...
                'If you use "-make_temporary" option, you need to return output object(s)',35));

            ME4 = assertExceptionThrown(@()save(obj.sqw_obj, ...
                'file1','bla=bla'),'HORACE:sqw:invalid_argument');
            assertTrue(strncmp(ME4.message, ...
                'More then one input ({''file1''}    {''bla=bla''}) can be interpreted as filename',20));

            ME5 = assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                {'file1','file2'},'bla=bla'),'HORACE:sqw:invalid_argument');
            assertTrue(strncmp(ME5.message, ...
                'Unable to use class "char" as faccess-or for sqw data',35));

            ME6 = assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                {'file1',ldr}),'HORACE:sqw:invalid_argument');
            assertTrue(strncmp(ME6.message, ...
                'Not all members of filenames cellarray (Argument N1 ) are the text strings',35));

            ME7 = assertExceptionThrown(@()save([obj.sqw_obj,obj.sqw_obj], ...
                {'fule1','file2'},{ldr,'file1'}),'HORACE:sqw:invalid_argument');
            assertTrue(strncmp(ME7.message, ...
                'Not every file-accessor provided as input (Argument N2) is child of horace_binfile_interface (faccess loader)',35));
        end

        function test_save_simple_filebacked(obj)
            % Prepare recent faccess version source file.
            tmp_sampl_file = fullfile(tmp_dir,obj.sqw_file_res);
            targ_file =      fullfile(tmp_dir,'test_save_simple_filebacked.sqw');
            clOb = onCleanup(@()del_memmapfile_files(tmp_sampl_file,targ_file));

            wout = obj.sqw_obj.save(tmp_sampl_file);
            assertTrue(wout.is_filebacked);
            assertTrue(isfile(tmp_sampl_file));
            assertEqual(wout.full_filename,tmp_sampl_file);
            wout.data.title = 'My image';

            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',wout.pix.num_pixels/4);
            wout2 = wout.save(targ_file);
            assertTrue(wout2.is_filebacked);
            assertTrue(isfile(targ_file));
            assertEqual(wout2.full_filename,targ_file);

            assertEqualToTol(wout,wout2, 'ignore_str',true);
            % clear output object to release targ_file for deletion
            clear wout;
            clear wout2;
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
