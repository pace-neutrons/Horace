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
            clOb = onCleanup(@()del_memmapfile_files(file1,file2));

            data = repmat(obj.sqw_obj,2,1);
            rec = data.save({file1,file2});

            assertTrue(isfile(file1));
            assertTrue(isfile(file2));

            assertEqualToTol(data,rec,'tol',[4*eps('single'),4*eps('single')], ...
                'ignore_str',true);
        end
        %------------------------------------------------------------------
        function test_save_make_tmp(obj)
            targ_file = fullfile(tmp_dir,'testfile_save_make_tmp.sqw');

            test_obj = obj.sqw_obj.save(targ_file,'-make_temporary');
            assertTrue(test_obj.is_filebacked)
            assertTrue(test_obj.is_tmp_obj)
            assertTrue(isfile(targ_file));

            clear test_obj ;
            assertFalse(isfile(targ_file));
        end

        function test_save_assume_updated_file_moved_with_output(obj)
            source_file = fullfile(tmp_dir,'testfile_save_assume_updated_source.sqw');
            targ_file = fullfile(tmp_dir,'testfile_save_assume_updated_result.sqw');
            clOb = onCleanup(@()del_memmapfile_files(targ_file));
            test_obj = obj.sqw_obj.save(source_file);
            assertTrue(test_obj.is_filebacked)
            assertFalse(test_obj.is_tmp_obj)

            test_obj.data.s(1) = 666;

            out_obj = save(test_obj,targ_file,'-assume_updated');

            assertFalse(isfile(source_file));
            assertTrue(isfile(targ_file));

            assertTrue(out_obj.is_filebacked)
            assertEqualToTol(obj.sqw_obj,out_obj, ...
                [4*eps('single'),4*eps('single')],'ignore_str',true,'-ignore_date');
            assertEqual(out_obj.full_filename,targ_file)
            % clear out_obj to release outfie for clOb to be able to delete it
            clear out_obj;
        end

        function test_save_assume_updated_file_moved_no_output(obj)
            source_file = fullfile(tmp_dir,'testfile_save_assume_updated_source.sqw');
            targ_file = fullfile(tmp_dir,'testfile_save_assume_updated_result.sqw');
            clOb = onCleanup(@()del_memmapfile_files(targ_file));
            test_obj = obj.sqw_obj.save(source_file);
            assertTrue(test_obj.is_filebacked)
            assertFalse(test_obj.is_tmp_obj)

            test_obj.data.s(1) = 666;

            save(test_obj,targ_file,'-assume_updated');

            assertFalse(isfile(source_file));
            assertTrue(isfile(targ_file));

            checkObj = read_sqw(targ_file);
            assertFalse(checkObj.is_filebacked)
            assertEqualToTol(obj.sqw_obj,checkObj,'tol', ...
                [4*eps('single'),4*eps('single')],'ignore_str',true,'-ignore_date');
            assertEqual(checkObj.full_filename,targ_file)

        end

        function test_save_update_with_file_works_like_save_file_copied(obj)
            targ_file = fullfile(tmp_dir,'testfile_save_update_sqw1.sqw');
            test_file = fullfile(tmp_dir,'testfile_save_update_sqw2.sqw');
            clOb = onCleanup(@()del_memmapfile_files(test_file,targ_file));
            test_obj = obj.sqw_obj.save(targ_file);
            assertTrue(test_obj.is_filebacked)
            assertFalse(test_obj.is_tmp_obj)

            test_obj.data.title = 'My image';
            save(test_obj,test_file,'-update');
            assertTrue(isfile(targ_file));
            assertTrue(isfile(test_file));

            checkObj = read_sqw(test_file);
            assertFalse(checkObj.is_filebacked)
            assertEqualToTol(test_obj,checkObj,'ignore_str',true);
        end

        function test_save_update_tmp_with_file_works_like_save_file_moved(obj)
            targ_file = fullfile(tmp_dir,'testfile_save_update_tmp.tmp');
            test_file = fullfile(tmp_dir,'testfile_save_update_tmp.sqw');
            clOb = onCleanup(@()del_memmapfile_files(test_file));
            test_obj = obj.sqw_obj.save(targ_file);
            assertTrue(test_obj.is_filebacked)
            assertTrue(test_obj.is_tmp_obj)

            test_obj.data.title = 'My image';
            test_obj = save(test_obj,test_file,'-update');
            assertFalse(isfile(targ_file));
            assertTrue(isfile(test_file));

            checkObj = read_sqw(test_file);
            assertFalse(checkObj.is_filebacked)
            assertEqualToTol(test_obj,checkObj);

            test_obj = obj.sqw_obj;
            test_obj.data.title = 'My image';
            assertEqualToTol(test_obj,checkObj, ...
                'tol',[4*eps('single'),4*eps('single')],'ignore_str',true);
        end

        function test_save_update_updates(obj)
            targ_file = fullfile(tmp_dir,'testfile_save_update_updates.sqw');
            clOb = onCleanup(@()del_memmapfile_files(targ_file));
            test_obj = obj.sqw_obj.save(targ_file);
            assertTrue(test_obj.is_filebacked)

            test_obj.data.title = 'My image';
            save(test_obj,'-update');
            assertTrue(isfile(targ_file));


            checkObj = read_sqw(targ_file);
            assertFalse(checkObj.is_filebacked)
            assertEqualToTol(test_obj,checkObj);

            clear test_obj;
            assertTrue(isfile(targ_file));
        end

        function test_save_with_clear_moves_tmp_leaves_tmp_broken(obj)
            % test shows tmp object gets broken.
            targ_file = fullfile(tmp_dir,'testfile_save_update_tmp.tmp');
            test_file = fullfile(tmp_dir,'testfile_save_update_tmp.sqw');
            clOb = onCleanup(@()del_memmapfile_files(test_file));
            test_obj = obj.sqw_obj.save(targ_file);
            assertTrue(test_obj.is_filebacked)
            assertTrue(test_obj.is_tmp_obj)

            test_obj.data.title = 'My image';
            other_obj = save(test_obj,test_file,'-clear_source');
            assertFalse(isfile(targ_file));
            assertTrue(isfile(test_file));

            checkObj = read_sqw(test_file);
            assertFalse(checkObj.is_filebacked)
            assertEqualToTol(other_obj,checkObj,'ignore_str',true);

            try
                s = test_obj.pix.signal;
            catch ME
                assertEqual(ME.identifier,'MATLAB:memmapfile:mapfile:cannotStatFile');
            end
        end


        function test_save_move_tmp_leaves_tmp_broken(obj)
            % test shows tmp object gets broken.
            targ_file = fullfile(tmp_dir,'testfile_save_update_tmp.tmp');
            test_file = fullfile(tmp_dir,'testfile_save_update_tmp.sqw');
            clOb = onCleanup(@()del_memmapfile_files(test_file));
            test_obj = obj.sqw_obj.save(targ_file);
            assertTrue(test_obj.is_filebacked)
            assertTrue(test_obj.is_tmp_obj)

            test_obj.data.title = 'My image';
            save(test_obj,test_file,'-assume_upd');
            assertFalse(isfile(targ_file));
            assertTrue(isfile(test_file));

            checkObj = read_sqw(test_file);
            assertFalse(checkObj.is_filebacked)
            tob = test_obj;
            tob.pix = [];
            chob = checkObj;
            chob.pix = [];
            assertEqualToTol(tob,chob,'ignore_str',true);

            try
                s = test_obj.pix.signal;
            catch ME
                assertEqual(ME.identifier,'MATLAB:memmapfile:mapfile:cannotStatFile');
            end
        end

        function test_save_update_invalid_folder_throw(obj)
            tobj = obj.sqw_obj;
            if ispc()
                test_fn = 'c:\non_existent_directory\save_update_throw_invalid_file.sqw';
            else
                test_fn = '/non_existent_directory/save_update_throw_invalid_file.sqw';
            end
            tobj.full_filename =test_fn  ;

            mess = sprintf('Default folder: "%s" for saving memory-based object with "-update" key does not exist',...
                test_fn);
            ME1= assertExceptionThrown(@()save(tobj,'-update'), ...
                'HORACE:sqw:invalid_argument');
            assertTrue(strncmp(ME1.message,mess,35));

        end
        %------------------------------------------------------------------
        function test_save_dnd_return_dnd(obj)
            targ_file = fullfile(tmp_dir,'save_dnd_test_file.sqw');
            clOb = onCleanup(@()del_memmapfile_files(targ_file ));

            rec =obj.sqw_obj.data.save(targ_file);
            assertTrue(isfile(targ_file));

            assertEqualToTol(obj.sqw_obj.data,rec);

            rec_file = read_horace(targ_file);
            assertEqualToTol(rec_file,rec, ...
                'ignore_str',true);
        end
        %
        function test_save_dnd_produces_dnd_file(obj)
            targ_file = fullfile(tmp_dir,'save_dnd_test_dnd.sqw');
            clOb = onCleanup(@()del_memmapfile_files(targ_file ));

            obj.sqw_obj.data.save(targ_file);
            assertTrue(isfile(targ_file));

            rec_file = read_horace(targ_file);
            assertEqualToTol(rec_file,obj.sqw_obj.data, ...
                'ignore_str',true);
        end
        %------------------------------------------------------------------
        function test_save_upgrade_automatically_filebacked(obj)

            targ_file = fullfile(tmp_dir,obj.sqw_file_res);
            clOb = onCleanup(@()del_memmapfile_files(targ_file));

            clConf = set_temporary_config_options( ...
                hor_config,'mem_chunk_size',500000,'fb_scale_factor',3);
            % prepare previous verion sqw file
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

            test_obj = test_obj.save(targ_file);
            assertFalse(isfile(source_to_move));

            ldr = sqw_formats_factory.instance().get_loader(targ_file);
            assertTrue(isa(ldr,'faccess_sqw_v4'));
            rec = ldr.get_sqw();
            ldr.delete();
            assertEqualToTol(rec,test_obj,'ignore_str',true,'tol',[4*eps('single'),4*eps('single')]);

            ref_obj = obj.sqw_obj;
            ref_obj.data.title = 'My image';
            assertEqualToTol(rec,ref_obj,'ignore_str',true,'tol',[4*eps('single'),4*eps('single')]);
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
            tmp_source_file = fullfile(tmp_dir,obj.sqw_file_res);
            targ_file       = fullfile(tmp_dir,'test_save_simple_filebacked.sqw');
            clOb = onCleanup(@()del_memmapfile_files(tmp_source_file,targ_file));
            % write test source file to check for save later and check it
            % is written correctly.
            wout = obj.sqw_obj.save(tmp_source_file);
            assertTrue(wout.is_filebacked);
            assertTrue(isfile(tmp_source_file));
            assertEqual(wout.full_filename,tmp_source_file);

            % modify file for saving change and prepare paged save.
            wout.data.title = 'My image';
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',wout.pix.num_pixels/4);
            wout2 = wout.save(targ_file);
            % check file is written as expected.
            assertTrue(wout2.is_filebacked);
            assertTrue(isfile(targ_file));
            assertEqual(wout2.full_filename,targ_file);

            assertEqualToTol(wout,wout2, 'ignore_str',true);
            % clear output objects to release targ_file and tmp_source_file
            % for deletion
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
