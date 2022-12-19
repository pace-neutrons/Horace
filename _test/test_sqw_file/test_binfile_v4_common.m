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
        function test_replace_blocks_(~)
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
