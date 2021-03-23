classdef test_has_pixels < TestCase
%% TEST_HAS_PIXELS tests the behaviour of the helper function
%
properties
    sqw_1d_file_path = '../test_sqw_file/sqw_1d_1.sqw';
    sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    sqw_4d_file_path = '../test_sqw_file/sqw_4d.sqw';
    d2d_obj;
end

methods

    function obj = test_has_pixels(varargin)
        obj = obj@TestCase('test_has_pixels');
    end

    function test_has_pixels_returns_false_for_d0d_object(~);
        d0d_obj = d0d();
        pix = d0d_obj.has_pixels();
        assertFalse(pix);
    end
    function test_has_pixels_returns_false_for_d1d_object(obj);
        d1d_obj = d1d(obj.sqw_1d_file_path);
        pix = d1d_obj.has_pixels();
        assertFalse(pix);
    end
    function test_has_pixels_returns_false_for_d2d_object(obj);
        d2d_obj = d2d(obj.sqw_2d_file_path);
        pix = d2d_obj.has_pixels();
        assertFalse(pix);
    end
    function test_has_pixels_returns_false_for_d3d_object(obj);
        skipTest('No 3d test data available');
        d3d_obj = d3d(obj.test_sqw_file_path);
        pix = d3d_obj.has_pixels();
        assertFalse(pix);
    end
    function test_has_pixels_returns_false_for_d4d_object(obj);
        d4d_obj = d4d(obj.sqw_4d_file_path);
        pix = d4d_obj.has_pixels();
        assertFalse(pix);
    end

end
end
