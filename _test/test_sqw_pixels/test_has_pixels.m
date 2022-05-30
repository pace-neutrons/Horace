classdef test_has_pixels < TestCase
%% TEST_HAS_PIXELS tests the behaviour of the helper function
%
properties
    test_sqw_file_path = '../common_data/sqw_2d_1.sqw';
    base_sqw_obj;
    sqw_obj;
    no_pix_sqw_obj;
end

methods

    function obj = test_has_pixels(varargin)
        obj = obj@TestCase('test_has_pixels');
        obj.base_sqw_obj = sqw(obj.test_sqw_file_path);
    end

    function obj = setUp(obj)
        obj.sqw_obj = copy(obj.base_sqw_obj);
        obj.no_pix_sqw_obj = copy(obj.base_sqw_obj);
        obj.no_pix_sqw_obj.data.pix = PixelData();
    end

    function test_has_pixels_returns_true_for_full_sqw_object(obj);
        pix = obj.sqw_obj.has_pixels();
        assertTrue(pix);
    end

    function test_has_pixels_returns_false_for_no_pixel_sqw_object(obj);
        pix = obj.no_pix_sqw_obj.has_pixels();
        assertFalse(pix);
    end

    function test_has_pixels_returns_array_of_results_for_array_arg(obj);
        test_data = [obj.sqw_obj, obj.no_pix_sqw_obj, obj.sqw_obj, obj.sqw_obj];
        expected = [true, false, true, true];
        results = has_pixels(test_data);

        assertEqual(results, expected);
    end

end
end
