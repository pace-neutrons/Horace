classdef test_PixelData < TestCase

properties
    raw_pix_data = rand(9, 10);
    pixel_data_obj;
end

methods (Access = private)

    function pix_data = get_random_pix_data_(~, rows)
        data = rand(9, rows);
        pix_data = PixelData(data);
    end

end

methods

    function obj = test_PixelData(~)
        obj = obj@TestCase('test_PixelData');

        obj.pixel_data_obj = PixelData(obj.raw_pix_data);
    end

    function test_default_construction_sets_empty_pixel_data(~)
        pix_data = PixelData();
        num_cols = 9;
        assertEqual(pix_data.data, zeros(num_cols, 0));
    end

    function test_PIXELDATA_raised_on_construction_with_data_with_lt_9_cols(~)
        f = @() PixelData(ones(3, 3));
        assertExceptionThrown(f, 'PIXELDATA:data')
    end

    function test_PIXELDATA_raised_on_construction_with_data_with_gt_9_cols(~)
        f = @() PixelData(ones(10, 3));
        assertExceptionThrown(f, 'PIXELDATA:data')
    end

    function test_coordinates_returns_empty_array_if_pixel_data_empty(~)
        pix_data = PixelData();
        assertTrue(isempty(pix_data.coordinates));
    end

    function test_pixel_data_is_set_to_input_data_on_construction(obj)
        assertEqual(obj.pixel_data_obj.data, obj.raw_pix_data);
    end

    function test_coordinate_data_can_be_retrieved_using_get_function(obj)
        assertEqual(get(obj.pixel_data_obj, 'coordinates'), ...
                    obj.pixel_data_obj.coordinates);
    end

    function test_coordinate_data_can_be_set_using_set_function(obj)
        num_rows = 10;
        pix_data_obj = obj.get_random_pix_data_(num_rows);
        new_coord_data = ones(4, num_rows);
        set(pix_data_obj, 'coordinates', new_coord_data);
        assertEqual(pix_data_obj.coordinates, new_coord_data);
    end

    function test_get_coordinates_returns_coordinate_data(obj)
        coord_data = obj.raw_pix_data(1:4, :);
        assertEqual(obj.pixel_data_obj.coordinates, coord_data);
    end

    function test_irun_returns_run_index_data(obj)
        run_indices = obj.raw_pix_data(5, :);
        assertEqual(obj.pixel_data_obj.irun, run_indices)
    end

    function test_idet_returns_detector_index_data(obj)
        detector_indices = obj.raw_pix_data(6, :);
        assertEqual(obj.pixel_data_obj.idet, detector_indices)
    end

    function test_ienergy_returns_energy_bin_number_data(obj)
        energy_bin_nums = obj.raw_pix_data(7, :);
        assertEqual(obj.pixel_data_obj.ienergy, energy_bin_nums)
    end

    function test_signals_returns_signal_array(obj)
        signal_array = obj.raw_pix_data(8, :);
        assertEqual(obj.pixel_data_obj.signals, signal_array)
    end

    function test_errors_returns_error_array(obj)
        error_array = obj.raw_pix_data(9, :);
        assertEqual(obj.pixel_data_obj.errors, error_array)
    end

    function test_PIXELDATA_error_raised_if_setting_data_with_lt_9_cols(~)
        f = @() PixelData(zeros(5, 10));
        assertExceptionThrown(f, 'PIXELDATA:data');
    end

    function test_num_pixels_returns_the_number_of_rows_in_the_data_block(obj)
        assertEqual(obj.pixel_data_obj.num_pixels, 10);
    end

    function test_coordinate_data_is_settable(obj)
        num_rows = 10;
        pix_data_obj = obj.get_random_pix_data_(num_rows);

        new_coord_data = ones(4, num_rows);
        pix_data_obj.coordinates = new_coord_data;
        assertEqual(pix_data_obj.coordinates, new_coord_data);
        assertEqual(pix_data_obj.data(1:4, :), new_coord_data);
    end

    function test_error_raised_if_setting_coordinates_with_wrong_num_rows(obj)
        num_rows = 10;
        pix_data_obj = obj.get_random_pix_data_(num_rows);

        new_coord_data = ones(4, num_rows - 1);
        f = @() (set(pix_data_obj, 'coordinates', new_coord_data));
        assertExceptionThrown(f, 'MATLAB:subsassigndimmismatch')
    end

    function test_error_raised_if_setting_coordinates_with_wrong_num_cols(obj)
        num_rows = 10;
        pix_data_obj = obj.get_random_pix_data_(num_rows);

        new_coord_data = ones(3, num_rows);
        f = @() (set(pix_data_obj, 'coordinates', new_coord_data));
        assertExceptionThrown(f, 'MATLAB:subsassigndimmismatch')
    end

    function test_size_of_PixelData_object_returns_underlying_data_size(obj)
        % This may no longer be true if we start adding additional columns that
        % are not part of the underlying pixel block
        assertEqual(size(obj.pixel_data_obj), [9, 10]);
        assertEqual(size(obj.pixel_data_obj, 1), 9);
        assertEqual(size(obj.pixel_data_obj, 2), 10);
    end

    function test_PixelData_object_with_underlying_data_is_not_empty(obj)
        assertFalse(isempty(obj.pixel_data_obj));
    end

    function test_default_PixelData_object_is_empty(~)
        pix_data_obj = PixelData();
        assertTrue(isempty(pix_data_obj));
    end

    function test_PIXELDATA_error_if_constructed_with_non_numeric_type(~)
        f = @() PixelData('non_numeric');
        assertExceptionThrown(f, 'PIXELDATA:data')
    end

    function test_PIXELDATA_error_if_data_set_with_non_numeric_type(~)
        pix_data_obj = PixelData();
        f = @() set(pix_data_obj, 'data', {1, 'abc'});
        assertExceptionThrown(f, 'PIXELDATA:data')
    end

end

end
