classdef test_has_pixels < TestCase
    %% TEST_HAS_PIXELS tests the behaviour of the helper function
    %
    properties
        sqw_1d_file_path = '../common_data/sqw_1d_1.sqw';
        sqw_2d_file_path = '../common_data/sqw_2d_1.sqw';
        sqw_3d_file_path = '../common_data/w3d_d3d.sqw';
        sqw_4d_file_path = '../common_data/sqw_4d.sqw';
        d2d_obj;
    end

    methods

        function obj = test_has_pixels(varargin)
            obj = obj@TestCase('test_has_pixels');
        end

        function test_has_pixels_returns_false_for_d0d_object(~)
            d0d_obj = d0d();
            pix = d0d_obj.has_pixels();
            assertFalse(pix);
        end
        function test_has_pixels_returns_false_for_d1d_object(obj)
            d1d_obj = read_dnd(obj.sqw_1d_file_path);
            pix = d1d_obj.has_pixels();
            assertFalse(pix);
        end
        function test_has_pixels_returns_false_for_d2d_object(obj)
            d2d_ob = read_dnd(obj.sqw_2d_file_path);
            pix = d2d_ob.has_pixels();
            assertFalse(pix);
        end
        function test_has_pixels_returns_false_for_d3d_object(obj)
            d3d_obj = read_dnd(obj.sqw_3d_file_path);
            pix = d3d_obj.has_pixels();
            assertFalse(pix);
        end
        function test_has_pixels_returns_false_for_d4d_object(obj)
            d4d_obj = read_dnd(obj.sqw_4d_file_path);
            pix = d4d_obj.has_pixels();
            assertFalse(pix);
        end

    end
end
