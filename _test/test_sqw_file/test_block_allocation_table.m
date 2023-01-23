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
        function bac = init_bac(~)
            % blocks for working with binfile_v4_block_tester
            data_list = {data_block('','level2_a'),data_block('','level2_b')...
                data_block('','level2_c'),dnd_data_block(),data_block('','level2_d')};
            bac = blockAllocationTable(0,data_list);
            assertFalse(bac.initialized);

            test_class = binfile_v4_block_tester();
            bac  = bac.init_obj_info(test_class);
            assertTrue(bac.initialized);
        end
        function test_set_overlapped_block_position_throws(~)
            data_list = {data_block('','level2_a'),data_block('','level2_b')...
                data_block('','level2_c'),dnd_data_block(),data_block('','level2_d'),...
                pix_data_block()};
            bac = blockAllocationTable(10,data_list);
            assertFalse(bac.initialized);
            first_free = bac.blocks_start_position;
            assertEqual(first_free,bac.end_of_file_pos);
            assertTrue(isempty(bac.free_spaces_and_size));

            % first block insertion
            pdb = data_block('','level2_b');
            block_size = 1000;
            pdb.position = 200;
            pdb.size     = block_size;

            assertEqual(pdb.size,uint64(block_size));
            assertExceptionThrown(@()set_data_block(bac,pdb), ...
                'HORACE:blockAllocatinTable:invalid_argument');
            pdb_w = data_block('missing_block','missing_prop');
            assertExceptionThrown(@()set_data_block(bac,pdb_w), ...
                'HORACE:blockAllocatinTable:invalid_argument');

            pdb.position = 1000;
            bac = bac.set_data_block(pdb);

            % second block insertion
            pdb2 = data_block('','level2_c');
            pdb2.position = 500;
            pdb2.size = 1000;
            assertExceptionThrown(@()set_data_block(bac,pdb2), ...
                'HORACE:blockAllocatinTable:invalid_argument');
            pdb2.position = 2000;
            bac = bac.set_data_block(pdb2);

            % third block insertion
            pdb = data_block('','level2_d');
            pdb.position = 1000;
            pdb.size = 500;
            assertExceptionThrown(@()set_data_block(bac,pdb), ...
                'HORACE:blockAllocatinTable:invalid_argument');
            pdb.position = 400;
            bac = bac.set_data_block(pdb);

            assertEqual(bac.end_of_file_pos,pdb2.position+block_size);
            assertEqual(bac.free_spaces_and_size,[first_free,900;400-first_free-1,99]);            
        end


        function test_set_const_block_position(~)
            data_list = {data_block('','level2_a'),data_block('','level2_b')...
                data_block('','level2_c'),dnd_data_block(),data_block('','level2_d'),...
                pix_data_block()};
            bac = blockAllocationTable(10,data_list);
            assertFalse(bac.initialized);
            first_free = bac.blocks_start_position;
            assertEqual(first_free,bac.end_of_file_pos);
            assertTrue(isempty(bac.free_spaces_and_size));

            pdb = pix_data_block();
            pdb.position = 400;
            pdb.npixels = 1000;

            block_size = 1000*9*4+12;


            assertEqual(pdb.size,uint64(block_size))
            bac = bac.set_data_block(pdb);

            assertEqual(bac.end_of_file_pos,pdb.position+block_size);
            assertEqual(bac.free_spaces_and_size,[first_free;400-first_free-1]);
        end

        function test_set_block_list_with_gaps(~)
            bat = blockAllocationTable();
            blocks = {data_block('','a',174+5,10),...
                data_block('','e',174+55,10),...
                data_block('','c',174+35,10),...
                data_block('','b',174+15,10)};
            bat = bat.init(10,blocks);

            assertEqual(size(bat.free_spaces_and_size),[2,3])
            assertEqual(bat.free_spaces_and_size,[174,174+25,174+45;5,10,10])
        end

        function test_set_block_list_no_gaps(~)
            bat = blockAllocationTable();
            blocks = {data_block('','a',174,10),data_block('','b',174+10,20),...
                data_block('','c',174+30,20),data_block('','e',174+50,20)};
            bat = bat.init(10,blocks);

            assertTrue(isempty(bat.free_spaces_and_size));
        end

        function test_last_block_reallocated_back(obj)

            bac = obj.init_bac();

            bll = bac.blocks_list;
            %
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{1},30);
            %
            assertFalse(compress);
            assertEqual(old_eof_pos,pos);
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{3},50);
            assertTrue(compress);
            assertEqual(old_eof_pos,pos);
            %
            fs_s_new = bac.free_spaces_and_size;
            assertEqual(size(fs_s_new,2),2);
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{3},20);
            assertFalse(compress);
            assertEqual(bll{1}.position,pos);

            fs_s_new = bac.free_spaces_and_size;
            assertEqual(size(fs_s_new,2),1);
            assertEqual(fs_s_new(1,1),bll{3}.position);
            assertEqual(fs_s_new(2,1),uint64(40));
            % end of file position moved back. Is it possible to do this
            % with file on disk using Matlab?
            assertEqual(bac.end_of_file_pos,old_eof_pos-50)
        end

        function test_adjusent_free_blocks_merged(obj)

            bac = obj.init_bac();

            bll = bac.blocks_list;
            %
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{1},30);
            %
            assertFalse(compress);
            assertEqual(old_eof_pos,pos);
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{3},50);
            assertTrue(compress);
            assertEqual(old_eof_pos,pos);
            %
            fs_s_new = bac.free_spaces_and_size;
            assertEqual(size(fs_s_new,2),2);
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{2},45);
            assertFalse(compress);
            assertEqual(double(bll{1}.position),pos);

            fs_s_new = bac.free_spaces_and_size;
            assertEqual(size(fs_s_new,2),1);
            assertEqual(fs_s_new(1,1),double(bll{1}.position+45));
            assertEqual(fs_s_new(2,1),45);
            % end of file position have not changed
            assertEqual(bac.end_of_file_pos,old_eof_pos)
        end

        function test_two_blocks_moved_compression_possible_for_third(obj)

            bac = obj.init_bac();

            bll = bac.blocks_list;
            %
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{1},30);
            %
            assertFalse(compress);
            assertEqual(old_eof_pos,pos);
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{3},50);
            assertTrue(compress);
            assertEqual(old_eof_pos,pos);
            %
            fs_s_new = bac.free_spaces_and_size;
            assertEqual(size(fs_s_new,2),2);
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{5},60);
            assertTrue(compress);
            assertEqual(old_eof_pos,pos);

            fs_s_new = bac.free_spaces_and_size;
            assertEqual(size(fs_s_new,2),3);
            % free space at place of bll{1};
            assertEqual(fs_s_new(1,1),bll{1}.position)
            assertEqual(double(fs_s_new(2,1)),20)
            % free space at place of bll{3};
            assertEqual(fs_s_new(1,2),bll{3}.position)
            assertEqual(double(fs_s_new(2,2)),40)

            % free space at place of bll{5};
            assertEqual(fs_s_new(1,3),bll{5}.position)
            assertEqual(double(fs_s_new(2,3)),50)

            % end of file position
            assertEqual(bac.end_of_file_pos,old_eof_pos+60)
        end

        function test_find_smaller_block_position(obj)
            % Find position of a block in the middle which size have
            % decreased
            bac = obj.init_bac();

            bll = bac.blocks_list;
            %
            fs_s = bac.free_spaces_and_size;
            assertTrue(isempty(fs_s));
            % free space position at the end of the blocks
            assertEqual(bac.end_of_file_pos,bll{5}.position+bll{5}.size);

            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{3},30);
            %--------------------------------------------------------------
            assertFalse(compress);
            assertEqual(pos,bll{3}.position);
            fs_s_new = bac.free_spaces_and_size;
            assertEqual(size(fs_s_new,2),1);
            % free space at the end of the old bll{3};
            assertEqual(fs_s_new(1,1),bll{3}.position+30)
            assertEqual(double(fs_s_new(2,1)),10)
            % end of file position have not changed
            assertEqual(bac.end_of_file_pos,old_eof_pos)
        end

        function test_find_larger_block_position(obj)
            % Find position of a block in the middle which size have
            % increased
            %
            % blocks for working with binfile_v4_block_tester
            bac = obj.init_bac();

            bll = bac.blocks_list;
            assertEqual(bll{1}.position,bac.blocks_start_position);
            assertEqual(bll{1}.size,uint64(20));
            assertEqual(bll{2}.position,bll{1}.position+bll{1}.size);
            assertEqual(bll{2}.size,uint64(30));
            assertEqual(bll{3}.position,bll{2}.position+bll{2}.size);
            assertEqual(bll{3}.size,uint64(40));
            assertEqual(bll{4}.position,bll{3}.position+bll{3}.size);
            assertEqual(bll{4}.size,uint64(252));
            assertEqual(bll{5}.position,bll{4}.position+bll{4}.size);
            assertEqual(bll{5}.size,uint64(50));

            %
            fs_s = bac.free_spaces_and_size;
            assertTrue(isempty(fs_s));
            % free space position at the end of the blocks
            assertEqual(bac.end_of_file_pos,bll{5}.position+bll{5}.size);
            %--------------------------------------------------------------
            old_eof_pos = bac.end_of_file_pos;
            [bac,pos,compress]  = bac.find_block_place(bll{3},50);
            %--------------------------------------------------------------
            assertFalse(compress);
            %  new block{3} position equal old endof file position
            assertEqual(pos,old_eof_pos);
            fs_s_new = bac.free_spaces_and_size;
            assertEqual(size(fs_s_new,2),1);
            % free space on place of the old bll{3};
            assertEqual(fs_s_new(1,1),bll{3}.position)
            assertEqual(fs_s_new(2,1),bll{3}.size)
            % end of file position
            assertEqual(bac.end_of_file_pos,old_eof_pos+50)

        end
        %
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
        %
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
