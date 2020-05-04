classdef test_PixelData < TestCase

properties
    raw_pix_data = rand(9, 10);
    pixel_data_obj;
end

methods (Access = private)

    function pix_data = get_random_pix_data_(obj, rows)
        data = rand(9, rows);
        pix_data = PixelData(data);
    end

end

methods

    function obj = test_PixelData(~)
        obj = obj@TestCase('test_PixelData');

        obj.pixel_data_obj = PixelData(obj.raw_pix_data);
    end

    function test_default_construction_sets_empty_pixel_data(obj)
        pix_data = PixelData();
        num_cols = 9;
        assertEqual(pix_data.data, zeros(num_cols, 0));
    end

    function test_PIXELDATA_raised_on_construction_with_data_with_lt_9_cols(obj)
        f = @() PixelData(ones(3, 3));
        assertExceptionThrown(f, 'PIXELDATA:data_error')
    end

    function test_coordinates_returns_empty_array_if_pixel_data_empty(obj)
        pix_data = PixelData();
        assertTrue(isempty(pix_data.coordinates));
    end

    function test_pixel_data_is_set_to_input_data_on_construction(obj)
        assertEqual(obj.pixel_data_obj.data, obj.raw_pix_data);
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

    function test_PIXELDATA_error_raised_if_setting_data_with_lt_9_cols(obj)
        f = @() PixelData(zeros(5, 10));
        assertExceptionThrown(f, 'PIXELDATA:data_error');
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

    function test_PixelData_objects_can_be_indexed_to_retrieve_data(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        assertEqual(pix_data_obj(1:5, 2:6), pix_data_obj.data(1:5, 2:6));
    end

    function test_PixelData_objects_can_be_indexed_to_set_data(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        new_data = ones(9, 4);
        pix_data_obj(:, 2:5) = new_data;
        assertEqual(pix_data_obj.data(:, 2:5), new_data);
    end

end

end
