classdef test_binfile_v4_common <  TestCase %WithSave
    %Testing common part of the code used to access binary sqw files
    % and various auxiliary methods, available on this class
    %

    properties
        test_data_folder
    end

    methods
        function obj = test_binfile_v4_common(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            %obj = obj@TestCaseWithSave(name,sample_file);
            obj = obj@TestCase(name);
            hp = horace_paths;
            obj.test_data_folder=hp.test_common;
        end
        %-----------------------------------------------------------------
        function test_put_all_ignore_two_blocks(~)
            tob = binfile_v4_block_tester(10);
            tob.level2_a = 'blablabla';
            tob.level2_c = 'lalalalala';

            t_file = fullfile(tmp_dir(),'binfile_v4_put_all_ignore_one.bin');
            clOb = onCleanup(@()delete(t_file));
            writ_obj = binfile_v4_common_tester(tob,t_file);
            writ_obj = writ_obj.put_all_blocks();
            writ_obj.delete();

            assertTrue(is_file(t_file));

            read_obj = binfile_v4_common_tester(t_file);
            wob0 = binfile_v4_block_tester();
            [read_obj,rec_obj] = read_obj.get_all_blocks(wob0, ...
                'ignore_blocks',{'bl__level2_a','bl__level2_c'});
            read_obj.delete();


            assertEqual(rec_obj.level2_c,wob0.level2_c);
            assertEqual(rec_obj.level2_a,wob0.level2_a);
            assertEqual(rec_obj.data,tob.data);
        end

        function test_put_all_ignore_one_block(~)
            tob = binfile_v4_block_tester(10);
            tob.level2_a = 'blablabla';
            tob.level2_c = 'lalalalala';

            t_file = fullfile(tmp_dir(),'binfile_v4_put_all_ignore_one.bin');
            clOb = onCleanup(@()delete(t_file));
            writ_obj = binfile_v4_common_tester(tob,t_file);
            writ_obj = writ_obj.put_all_blocks();
            writ_obj.delete();

            assertTrue(is_file(t_file));

            read_obj = binfile_v4_common_tester();
            wob0 = binfile_v4_block_tester();
            [read_obj,rec_obj] = read_obj.get_all_blocks(t_file,wob0, ...
                'ignore_blocks','bl__level2_a');
            read_obj.delete();


            assertEqual(rec_obj.level2_c,'lalalalala');
            assertEqual(rec_obj.level2_a,wob0.level2_a);
            assertEqual(rec_obj.data,tob.data);
        end


        function test_put_signgle_sqw_block(~)
            tob = binfile_v4_block_tester(10);
            t_file = fullfile(tmp_dir(),'binfile_v4_common_put_block.bin');
            clOb = onCleanup(@()delete(t_file));
            writ_obj = binfile_v4_common_tester(tob,t_file);
            writ_obj = writ_obj.put_all_blocks();
            writ_obj.delete();

            assertTrue(is_file(t_file));


            acc_obj = binfile_v4_common_tester(t_file);
            acc_obj = acc_obj.set_file_to_update();
            acc_obj = acc_obj.put_sqw_block('bl__level2_c', repmat('b',20,1));
            acc_obj.delete();

            read_obj = binfile_v4_common_tester();
            [read_obj,rec_obj] = read_obj.get_all_blocks(t_file,binfile_v4_block_tester());

            assertEqual(rec_obj.level2_c,repmat('b',20,1));
            assertEqual(rec_obj.level2_b,tob.level2_b);
            assertEqual(rec_obj.data,tob.data);

            read_obj.delete();
        end

        function test_get_sqw_block_invalid_argument(~)
            tob = binfile_v4_block_tester(10);
            t_file = fullfile(tmp_dir(),'binfile_v4_common_get_block.bin');
            clOb = onCleanup(@()delete(t_file));
            writ_obj = binfile_v4_common_tester(tob,t_file);
            writ_obj = writ_obj.put_all_blocks();
            writ_obj.delete();

            assertTrue(is_file(t_file));


            read_obj = binfile_v4_common_tester();
            assertExceptionThrown(@()get_sqw_block(read_obj,'bl__level2_c',tob), ...
                'HORACE:binfile_v4_common:invalid_argument');

            assertExceptionThrown(@()get_sqw_block(read_obj,'bl_data_nd_data'), ...
                'HORACE:binfile_v4_common:runtime_error');

            [read_obj,obj1] = read_obj.get_sqw_block('bl__level2_c',t_file);
            assertEqual(obj1,tob.level2_c);

            assertExceptionThrown(@()get_sqw_block(read_obj,'missing_block'), ...
                'HORACE:blockAllocationTable:invalid_argument');
            read_obj.delete();

        end

        function test_get_sqw_block(~)
            tob = binfile_v4_block_tester(10);
            t_file = fullfile(tmp_dir(),'binfile_v4_common_get_block.bin');
            clOb = onCleanup(@()delete(t_file));
            writ_obj = binfile_v4_common_tester(tob,t_file);
            writ_obj = writ_obj.put_all_blocks();
            writ_obj.delete();

            assertTrue(is_file(t_file));


            read_obj = binfile_v4_common_tester(t_file);
            [read_obj,obj1] = read_obj.get_sqw_block('bl__level2_c');
            assertEqual(obj1,tob.level2_c);

            [read_obj,obj2] = read_obj.get_sqw_block('bl_data_nd_data');
            assertEqual(obj2,tob.data.nd_data);

            read_obj.delete();
        end

        function test_replace_blocks(~)
            tob = binfile_v4_block_tester(10);
            t_file = fullfile(tmp_dir(),'binfile_v4_common_tester.bin');
            clOb = onCleanup(@()delete(t_file));
            writ_obj = binfile_v4_common_tester(tob,t_file);
            writ_obj = writ_obj.put_all_blocks();
            writ_obj.delete();

            assertTrue(is_file(t_file));


            read_obj = binfile_v4_common_tester();
            rec_obj= binfile_v4_block_tester();
            [read_obj,rec_obj] = read_obj.get_all_blocks(t_file,rec_obj);

            read_obj.delete();
            assertEqual(rec_obj,tob);
        end

        function test_init_from_obj(~)
            tob = binfile_v4_block_tester(10);
            t_file = fullfile(tmp_dir(),'test_binfile_v4_init_from_obj.bin');
            clOb = onCleanup(@()delete(t_file));
            writ_obj = binfile_v4_common_tester(tob,t_file);
            writ_obj = writ_obj.put_all_blocks();
            writ_obj.delete();

            assertTrue(is_file(t_file));


            read_obj = binfile_v4_common_tester();
            rec_obj= binfile_v4_block_tester();
            [read_obj,rec_obj] = read_obj.get_all_blocks(t_file,rec_obj);

            read_obj.delete();
            assertEqual(rec_obj,tob);
        end
    end
end
