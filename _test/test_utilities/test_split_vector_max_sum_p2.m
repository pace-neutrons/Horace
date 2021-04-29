classdef test_split_vector_max_sum_p2 < TestCase
    
    methods
        function obj = test_split_vector_max_sum_p2(~)
            obj@TestCase('test_split_vector_max_sum_p-1');
        end
        
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
        function test_split_big_block_in_the_middle(~)
            vector     = [5,34,6];
            start_pos  = [100,200,300];
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),5);
            ref_pos = {[100;200],206,216,[226;300],302};
            ref_sizes = {[5;5];10;10;10;5};
            for i=1:5
                ch = chunks{i};
                pos = ch{1};
                size = ch{2};
                assertEqual(pos,ref_pos{i});
                assertEqual(size,ref_sizes{i});
            end
        end
        
        
        function test_split_big_block(~)
            vector     = 34;
            start_pos  = 100;
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),4);
            ref_pos = {100,111,121,131};
            ref_sizes = {10,10,10,4};
            for i=1:4
                ch = chunks{i};
                pos = ch{1};
                size = ch{2};
                assertEqual(pos,ref_pos{i});
                assertEqual(size,ref_sizes{i});
            end
        end
        
        function test_split_2p_block_pages_split(~)
            vector     = [3, 3, 4, 3, 3, 3, 5];
            %             !--------!--------!----;3 Pages
            start_pos  = [10,20,30,40,50,60,70];
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),3);
            ch = chunks{1};
            pos = ch{1};
            size = ch{2};
            assertEqual(sum(size),max_sum)
            assertEqual(pos(1),start_pos(1));
            assertEqual(pos(2),start_pos(2));
            assertEqual(pos(3),start_pos(3));
            assertEqual(size(1) ,vector(1));
            assertEqual(size(2),vector(2));
            assertEqual(size(3),vector(3));
            
            ch = chunks{2};
            pos = ch{1};
            size = ch{2};
            assertEqual(sum(size),max_sum)
            assertEqual(pos(1) ,start_pos(4));
            assertEqual(pos(2) ,start_pos(5));
            assertEqual(pos(3) ,start_pos(6));
            assertEqual(pos(4) ,start_pos(7));
            assertEqual(size(1),vector(4));
            assertEqual(size(2),vector(5));
            assertEqual(size(3),vector(6));
            assertEqual(size(4),1);
            
            ch = chunks{3};
            pos = ch{1};
            size = ch{2};
            assertEqual(pos(1),start_pos(7)+2);
            assertEqual(size(1) ,vector(7)-1);
            
        end
        
        function test_split_2p_block_last_pages_hungs(~)
            vector     = [5,5,5,3];
            start_pos  = [10,25,400,700];
            max_sum = 10;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),2);
            for i=1:2
                ch = chunks{i};
                pos = ch{1};
                size = ch{2};
                assertEqual(pos(1),start_pos(2*(i-1)+1));
                assertEqual(pos(2),start_pos(2*(i-1)+2));
                assertEqual(size(1) ,vector(2*(i-1)+1));
                assertEqual(size(2),vector(2*(i-1)+2));
            end
        end
        %
        function test_split_block_first_page_overruns(~)
            vector     = 3;
            start_pos  = 10;
            max_sum = 5;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),1);
            for i=1:1
                ch = chunks{i};
                pos = ch{1};
                size = ch{2};
                
                assertEqual(pos,start_pos(i));
                assertEqual(size,vector(i));
            end
        end
        
        %
        function test_split_block_last_pages_hungs(~)
            vector     = [5,5,3];
            start_pos  = [10,25,400];
            max_sum = 5;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),3);
            for i=1:3
                ch = chunks{i};
                pos = ch{1};
                size = ch{2};
                
                assertEqual(pos,start_pos(i));
                assertEqual(size ,vector(i));
            end
        end
        %
        function test_split_block_equal_pages(~)
            vector     = [5,5,5];
            start_pos  = [10,25,400];
            max_sum = 5;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),3);
            for i=1:3
                ch = chunks{i};
                pos = ch{1};
                size = ch{2};
                
                assertEqual(pos ,start_pos(i));
                assertEqual(size,vector(i));
            end
        end
        function test_split_block_large_page(~)
            vector     = [5,5,5];
            start_pos  = [10,25,400];
            max_sum = 100;
            chunks = split_data_blocks(start_pos,vector, max_sum);
            assertEqual(numel(chunks),1);
            
            ch = chunks{1};
            pos = ch{1};
            size = ch{2};
            assertEqual(pos,start_pos');
            assertEqual(size,vector');
        end
        
    end
    
end
