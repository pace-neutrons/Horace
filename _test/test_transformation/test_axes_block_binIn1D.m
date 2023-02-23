classdef test_axes_block_binIn1D < TestCase
    % Series of tests for bins_in_1Drange method of axes_block class

    properties
        out_dir=tmp_dir();
        working_dir
    end

    methods
        function obj=test_axes_block_binIn1D(varargin)
            if nargin<1
                name = 'test_axes_block_binIn1D';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            obj.working_dir = fileparts(mfilename("fullpath"));
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function test_range_inside_cross1st_bin(~)
            bins = 1:10;
            range = [-0.5,1.5];
            [in,is_inside] = ortho_axes.bins_in_1Drange(bins,range);
            assertTrue(in)
            inside = false(1,10);
            inside(1) = true;
            assertEqual(is_inside,inside);
        end
        
        function test_range_outside_adjacent(~)
            bins = 1:10;
            range = [10,11];
            [in,is_inside] = ortho_axes.bins_in_1Drange(bins,range);
            assertFalse(in)
            inside = false(1,10);
            assertEqual(is_inside,inside);
        end

        function test_range_inside_range_at_end(~)
            bins = 1:10;
            range = [9.5,10.5];
            [in,is_inside] = ortho_axes.bins_in_1Drange(bins,range);
            assertTrue(in)
            inside = false(1,10);
            inside(9) = true;
            assertEqual(is_inside,inside);
        end

        function test_range_inside_range(~)
            bins = 1:10;
            range = [4.5,4.9];
            [in,is_inside] = ortho_axes.bins_in_1Drange(bins,range);
            assertTrue(in)
            inside = false(1,10);
            inside(4) = true;
            assertEqual(is_inside,inside);
        end
        function test_range_all_outside_smaller(~)
            bins = 1:10;
            range = [-1,1];
            [in,is_inside] = ortho_axes.bins_in_1Drange(bins,range);
            assertFalse(in)
            inside = false(1,10);
            assertEqual(is_inside,inside);
        end
        

        function test_range_all_outside_bigger(~)
            bins = 1:10;
            range = [11,12];
            [in,is_inside] = ortho_axes.bins_in_1Drange(bins,range);
            assertFalse(in)
            inside = false(1,10);
            assertEqual(is_inside,inside);
        end
        
        function test_range_inside(~)
            bins = 1:10;
            range = [4,5];
            [in,is_inside] = ortho_axes.bins_in_1Drange(bins,range);
            assertTrue(in)
            inside = false(1,10);
            inside(4) = true;
            inside(5) = true;
            assertEqual(is_inside,inside);
        end
    end
end
