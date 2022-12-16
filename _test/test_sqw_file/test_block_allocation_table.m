classdef test_block_allocation_table < TestCase
    properties
        test_structure;
    end

    methods
        function obj = test_block_allocation_table(varargin)
            if nargin == 0
                name = varargin{1};
            else
                name = 'test_block_allocation_table';
            end
            obj = obj@TestCase(name);

            str_a = struct('level2_a',sqw_binfile_common_tester(), ...
                'level2_b',binfile_v2_common_tester());

            str_b = struct('level2_aa',binfile_v2_common_tester(), ...
                'level2_bb',binfile_v2_common_tester());

            obj.test_structure = struct('level1_a',str_a,'level1_b',str_b,'level1_c',str_a);
        end
        function file_deleter(~,fid,file)
            fn = fopen(fid);
            if ~isempty(fn)
                fclose(fid);
            end
            delete(file);
        end
        function test_get_block_position_works(obj)
            data_list = {data_block('level1_a','level2_a'),data_block('level1_a','level2_b')...
                data_block('level1_b','level2_bb'),data_block('level1_b','level2_aa')...
                data_block('level1_c','level2_b'),data_block('level1_c','level2_a')};

            bac = blockAllocationTable(0,data_list);
            assertFalse(bac.initialized);
            assertEqual(bac.bat_bin_size,4+54*4+55*2);
            bac = bac.init_obj_info(obj.test_structure);
            assertTrue(bac.initialized);

            block1 = data_list{1};
            pos1 = bac.get_block_pos(block1);
            assertEqual(pos1,bac.blocks_start_position);

            name2 = data_list{2}.block_name;
            pos2 = bac.get_block_pos(name2);
            assertTrue(pos2>bac.blocks_start_position);
        end

        function test_get_block_position_throws_uninitiated(~)
            data_list = {data_block('level1_a','level2_a'),data_block('level1_a','level2_b')...
                data_block('level1_b','level2_bb'),data_block('level1_b','level2_aa')...
                data_block('level1_c','level2_b'),data_block('level1_c','level2_a')};

            bac = blockAllocationTable(0,data_list);
            assertFalse(bac.initialized);
            assertEqual(bac.bat_bin_size,4+54*4+55*2);

            name = data_list{2};
            assertExceptionThrown(@()get_block_pos(bac,name), ...
                'HORACE:blockAllocationTable:runtime_error');
        end
        %
        function test_save_restore_bat(obj)
            data_list = {data_block('level1_a','level2_a'),data_block('level1_a','level2_b')...
                data_block('level1_b','level2_bb'),data_block('level1_b','level2_aa')...
                data_block('level1_c','level2_b'),data_block('level1_c','level2_a')};

            bac = blockAllocationTable(0,data_list);
            assertFalse(bac.initialized);
            assertEqual(bac.bat_bin_size,4+54*4+55*2);

            bac = bac.init_obj_info(obj.test_structure);
            assertTrue(bac.initialized);

            file = fullfile(tmp_dir(),'put_get_bat.bin');
            fid = fopen(file,'wb+');
            clOb = onCleanup(@()file_deleter(obj,fid,file));

            bac = bac.put_bat(fid);

            bat_rect = blockAllocationTable();
            assertFalse(bat_rect.initialized);
            bat_rect = bat_rect.get_bat(fid);
            assertTrue(bat_rect.initialized);

            assertEqual(bac,bat_rect);

            last_pos = uint64(ftell(fid));
            assertEqual(bat_rect.blocks_start_position,last_pos);
        end


        function test_init_by_list_output_ready(obj)
            data_list = {data_block('level1_a','level2_a'),...
                data_block('level1_b','level2_bb'),...
                data_block('level1_c','level2_b')};

            bac = blockAllocationTable(0,data_list);
            assertFalse(bac.initialized);
            assertEqual(bac.bat_bin_size,167);
            bac = bac.init_obj_info(obj.test_structure);
            assertTrue(bac.initialized);

            bin_data = bac.ba_table;
            assertTrue(isa(bin_data,'uint8'));
            assertEqual(numel(bin_data),bac.bat_bin_size);

            rec_table = blockAllocationTable();
            rec_table.ba_table = bin_data;

            assertEqual(bac,rec_table);
        end
        function test_empty_table(~)
            bac = blockAllocationTable();
            assertFalse(bac.initialized);
            assertEqual(bac.bat_bin_size,4); % Empty table occupies 4 bytes

            bin_data = bac.ba_table;
            assertEqual(numel(bin_data),4);

            assertEqual(typecast(bin_data,'uint32'),uint32(0))

        end

    end

end
