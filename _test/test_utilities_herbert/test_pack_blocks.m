classdef test_pack_blocks< TestCase
    properties
    end
    methods
        function this=test_pack_blocks(varargin)
            if nargin == 0
                name= mfilename('class');
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        function test_pack_all_fit_inside(~)
            free_space = [10,100;40,20];
            eof_pos = 200;
            block = [20,10,30];

            [pos,free_space_rt,pos_eof]= pack_blocks(free_space,block,eof_pos);

            assertEqual(pos,[10,130,100])
            assertTrue(isempty(free_space_rt));
            assertEqual(pos_eof,200);
        end

        function test_pack_two_blcks_inside(~)
            free_space = [10,100;40,10];
            eof_pos = 200;
            block = [20,10,30];

            [pos,free_space_rt,pos_eof]= pack_blocks(free_space,block,eof_pos);

            assertEqual(pos,[200,130,100])
            assertEqual(free_space_rt,[10;10]);
            assertEqual(pos_eof,220);
        end

        function test_pack_blcks_at_the_end(~)
            free_space = zeros(2,0);
            eof_pos = 20;
            block = [20,10,30];

            [pos,free_space_rt,pos_eof]= pack_blocks(free_space,block,eof_pos);

            assertEqual(pos,[50,70,20])
            assertEqual(free_space_rt,free_space);
            assertEqual(pos_eof,80);
        end
        function test_invalid_arguments_throw(~)
            free_space = zeros(2,0);
            eof_pos = 20;
            block = [20,10,30];

            assertExceptionThrown(@()pack_blocks([],block,eof_pos), ...
                'HERBERT:utilities:invalid_argument');
            assertExceptionThrown(@()pack_blocks(free_space,ones(2,2),eof_pos), ...
                'HERBERT:utilities:invalid_argument');
            assertExceptionThrown(@()pack_blocks(free_space,block,'a'), ...
                'HERBERT:utilities:invalid_argument');
        end
    end
end
