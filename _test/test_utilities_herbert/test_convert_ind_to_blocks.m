classdef test_convert_ind_to_blocks< TestCase
    properties
    end
    methods
        function this=test_convert_ind_to_blocks(varargin)
            if nargin == 0
                name= mfilename('class');
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        function test_convert_ind_block_3(~)
            block = [10:20,35:40,50:55];


            [min_b,max_b] = convert_ind_to_blocks(block);
            assertEqual(min_b,[10,35,50]);
            assertEqual(max_b,[20,40,55]);            
        end
        
        function test_convert_ind_block1(~)
            block = 10:20;


            [min_b,max_b] = convert_ind_to_blocks(block);
            assertEqual(min_b,10);
            assertEqual(max_b,20);            
        end

        
    end
end

