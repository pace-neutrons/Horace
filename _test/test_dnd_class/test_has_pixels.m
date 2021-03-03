classdef test_has_pixels < TestCase
%% TEST_HAS_PIXELS tests the behaviour of the helper function
%
properties
    test_sqw_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    d2d_obj;
end

methods

    function obj = test_has_pixels(varargin)
        obj = obj@TestCase('test_has_pixels');
        obj.d2d_obj = d2d(obj.test_sqw_file_path);
    end

    function test_has_pixels_returns_false_for_no_d2d_object(obj);
        pix = obj.d2d_obj.has_pixels();
        assertFalse(pix);
    end

end
end
