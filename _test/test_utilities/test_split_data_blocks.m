classdef test_split_data_blocks < TestCase
    
    methods
        function obj = test_split_data_blocks(~)
            obj@TestCase('test_split_data_blocks');
        end
        %
        function compare_chunks(~,chunks,blocks,ref_pos,ref_sizes)
            assertEqual(sum([ref_sizes{:}]),sum(blocks));
            for i=1:numel(chunks)
                ch = chunks{i};
                pos = ch{1};
                size = ch{2};
                assertEqual(pos,ref_pos{i},sprintf(' incorrect positions for chunk N%d',i));
                assertEqual(size,ref_sizes{i},sprintf(' incorrect sizes for chunk N%d',i));
            end
        end
        %
        function test_outputs_are_empty_if_inputs_are_empty(~)
            [chunks, csum] = split_data_blocks([], []);
            assertTrue(isa(chunks, 'cell'))
            assertTrue(isempty(chunks));
            assertTrue(isa(csum, 'double'))
            assertTrue(isempty(csum));
        end
        function test_error_if_different_sizes(~)
            vector = ones(1, 10);
            pos = ones(1,8);
            f = @() split_data_blocks(pos,vector,100);
            assertExceptionThrown(f, 'HORACE:utilities:invalid_argument');
        end
        function test_split_2big_blocks_buf_underun_overrun(obj)
            vector     = [9,33,6,9,35];
            start_pos  = [100,200,300,400,500];
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),8);
            ref_pos = {100,200,210,220,[300,400],500,510,520};
            ref_sizes = {9,10,10,13,[6,9],10,10,15};
            
            obj.compare_chunks(chunks,vector,ref_pos,ref_sizes);
        end
        
        function test_split_2big_blocks(obj)
            vector     = [5,34,6,10,30];
            start_pos  = [100,200,300,400,500];
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),7);
            ref_pos = {[100,200],210,220,[300,400],500,510,520};
            ref_sizes = {[5,10],10,14,[6,10],10,10,10};
            
            obj.compare_chunks(chunks,vector,ref_pos,ref_sizes);
        end
        %
        function test_split_big_block_in_the_middle_extra_buf(obj)
            vector     = [5,44,8];
            start_pos  = [100,200,300];
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),5);
            
            ref_pos = {[100,200],210,220,230,300};
            ref_sizes = {[5,10],10,10,14,8};
            
            obj.compare_chunks(chunks,vector,ref_pos,ref_sizes);
        end
        
        %
        function test_split_big_block_in_the_middle_fit_buf(obj)
            vector     = [5,44,6];
            start_pos  = [100,200,300];
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),5);
            
            ref_pos = {[100,200],210,220,230,300};
            ref_sizes = {[5,10],10,10,14,6};
            
            obj.compare_chunks(chunks,vector,ref_pos,ref_sizes);
        end
        %
        function test_split_big_block(obj)
            vector     = 34;
            start_pos  = 100;
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),3);
            ref_pos = {100,110,120};
            ref_sizes = {10,10,14};
            obj.compare_chunks(chunks,vector,ref_pos,ref_sizes);
        end
        %
        function test_split_2p_block_pages_split(obj)
            vector     = [3, 3, 4, 3, 3, 3, 5];
            %             !--------!--------!----;3 Pages
            start_pos  = [100,200,300,400,500,600,700];
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),3);
            
            ref_pos = {[100,200,300],[400,500,600],700};
            ref_sizes = {[3,3,4],[3,3,3],5};
            
            obj.compare_chunks(chunks,vector,ref_pos,ref_sizes);
            
        end
        
        %
        
        function test_split_2p_block_last_page_small(obj)
            vector     = [5,5,5,3];
            start_pos  = [10,25,400,700];
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),2);
            
            ref_sizes = {[5,5],[5,3]};
            ref_pos = {[10,25],[400,700]};
            
            obj.compare_chunks(chunks,vector ,ref_pos,ref_sizes);
        end
        %
        function test_split_block_first_page_small(obj)
            vector     = 3;
            start_pos  = 10;
            max_sum = 5;
            chunks = split_data_blocks(start_pos,vector,max_sum);
            assertEqual(numel(chunks),1);
            
            ref_pos = {10};
            ref_sizes = {3};
            
            obj.compare_chunks(chunks,vector ,ref_pos,ref_sizes);
        end
        %
        function test_split_block_last_page_small(obj)
            vector     = [5,5,3];
            start_pos  = [10,25,400];
            max_sum = 5;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),3);
            
            ref_pos = {10,25,400};
            ref_sizes = {5,5,3};
            
            obj.compare_chunks(chunks,vector ,ref_pos,ref_sizes);
        end
        %
        function test_split_two_adjacent_two_blocks(obj)
            blocks     = [3, 3, 3, 3, 5];
            %             !--------!----;
            start_pos  = [1, 4, 7, 20, 23]; %2 Pages, 2 blocks
            buf_size = 10;
            chunks = split_data_blocks(start_pos,blocks, buf_size);
            assertEqual(numel(chunks),2);
            ref_pos = {1,20};
            ref_sizes = {9,8};
            
            obj.compare_chunks(chunks,blocks ,ref_pos,ref_sizes);
        end
        %
        function test_split_two_adjacent_one_block(obj)
            blocks     = [3, 3, 3, 3, 5];
            start_pos  = [1, 4, 7, 20, 23]; %2 Pages, one block
            buf_size = 20;
            chunks = split_data_blocks(start_pos,blocks, buf_size);
            assertEqual(numel(chunks),1);
            ref_pos = {[1,20]};
            ref_sizes = {[9,8]};
            
            obj.compare_chunks(chunks,blocks,ref_pos,ref_sizes);
        end
        %
        function test_split_block_large_page(obj)
            vector     = [5,5,5];
            start_pos  = [10,25,400];
            buf_size = 100;
            chunks = split_data_blocks(start_pos,vector, buf_size);
            assertEqual(numel(chunks),1);
            
            ref_pos = {start_pos};
            ref_sizes = {vector};
            
            obj.compare_chunks(chunks,vector ,ref_pos,ref_sizes);
        end
        %
        function test_split_block_equal_pages(obj)
            vector     = [5,5,5];
            start_pos  = [10,25,400];
            max_sum = 5;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            
            assertEqual(numel(chunks),3);
            
            ref_pos = {10,25,400};
            ref_sizes = {5,5,5};
            
            obj.compare_chunks(chunks,vector ,ref_pos,ref_sizes);
        end
        
    end
    
end
