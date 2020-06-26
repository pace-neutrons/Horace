classdef test_PixelData < TestCase

properties
    raw_pix_data = rand(9, 10);
    small_page_size_ = 1e6;  % 1Mb
    test_sqw_file_path = '../test_sqw_file/sqw_1d_1.sqw';
    test_sqw_file_full_path = '';

    pixel_data_obj;
    pix_data_from_file;
    pix_data_from_faccess;
    pix_data_small_page;
    pix_fields = {'u1', 'u2', 'u3', 'dE', 'coordinates', 'q_coordinates', ...
                  'run_idx', 'detector_idx', 'energy_idx', 'signal', ...
                  'variance'};
end

properties (Constant)
    NUM_BYTES_IN_VALUE = 8;
    NUM_COLS_IN_PIX_BLOCK = 9;
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

        test_sqw_file = java.io.File(pwd(), obj.test_sqw_file_path);
        obj.test_sqw_file_full_path = char(test_sqw_file.getCanonicalPath());

        % Construct an object from raw data
        obj.pixel_data_obj = PixelData(obj.raw_pix_data);
        % Construct an object from a file
        obj.pix_data_from_file = PixelData(obj.test_sqw_file_path);
        % Construct an object from a file accessor
        f_accessor = sqw_formats_factory.instance().get_loader(obj.test_sqw_file_path);
        obj.pix_data_from_faccess = PixelData(f_accessor);
        % Construct an object from file accessor with small page size
        obj.pix_data_small_page = PixelData(f_accessor, obj.small_page_size_);
    end

    % --- Tests for in-memory operations ---
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

    function test_u1_returns_first_dim_in_coordinates_array(obj)
        u1 = obj.pixel_data_obj.u1;
        assertEqual(u1, obj.pixel_data_obj.coordinates(1, :));
    end

    function test_u1_sets_the_first_dim_in_coordinates_array(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        pix_data_obj.u1 = 1;
        assertEqual(pix_data_obj.coordinates(1, :), ones(1, 10));
    end

    function test_u2_returns_second_dim_in_coordinates_array(obj)
        u2 = obj.pixel_data_obj.u2;
        assertEqual(u2, obj.pixel_data_obj.coordinates(2, :));
    end

    function test_u2_sets_the_second_dim_in_coordinates_array(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        pix_data_obj.u2 = 1;
        assertEqual(pix_data_obj.coordinates(2, :), ones(1, 10));
    end

    function test_u3_returns_third_dim_in_coordinates_array(obj)
        u3 = obj.pixel_data_obj.u3;
        assertEqual(u3, obj.pixel_data_obj.coordinates(3, :));
    end

    function test_u3_sets_the_third_dim_in_coordinates_array(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        pix_data_obj.u3 = 1;
        assertEqual(pix_data_obj.coordinates(3, :), ones(1, 10));
    end

    function test_dE_returns_fourth_dim_in_coordinates_array(obj)
        dE = obj.pixel_data_obj.dE;
        assertEqual(dE, obj.pixel_data_obj.coordinates(4, :));
    end

    function test_dE_sets_the_fourth_dim_in_coordinates_array(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        pix_data_obj.dE = 1;
        assertEqual(pix_data_obj.coordinates(4, :), ones(1, 10));
    end

    function test_q_coordinates_returns_first_3_dims_of_coordinates(obj)
        q_coords = obj.pixel_data_obj.q_coordinates;
        assertEqual(q_coords, obj.pixel_data_obj.q_coordinates);
    end

    function test_setting_q_coordinates_updates_u1_u2_and_u3(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        pix_data_obj.q_coordinates = ones(3, 10);
        assertEqual(pix_data_obj.u1, ones(1, 10));
        assertEqual(pix_data_obj.u2, ones(1, 10));
        assertEqual(pix_data_obj.u3, ones(1, 10));
    end

    function test_get_coordinates_returns_coordinate_data(obj)
        coord_data = obj.raw_pix_data(1:4, :);
        assertEqual(obj.pixel_data_obj.coordinates, coord_data);
    end

    function test_run_idx_returns_run_index_data(obj)
        run_indices = obj.raw_pix_data(5, :);
        assertEqual(obj.pixel_data_obj.run_idx, run_indices)
    end

    function test_detector_idx_returns_detector_index_data(obj)
        detector_indices = obj.raw_pix_data(6, :);
        assertEqual(obj.pixel_data_obj.detector_idx, detector_indices)
    end

    function test_energy_idx_returns_energy_bin_number_data(obj)
        energy_bin_nums = obj.raw_pix_data(7, :);
        assertEqual(obj.pixel_data_obj.energy_idx, energy_bin_nums)
    end

    function test_signal_returns_signal_array(obj)
        signal_array = obj.raw_pix_data(8, :);
        assertEqual(obj.pixel_data_obj.signal, signal_array)
    end

    function test_variance_returns_variance_array(obj)
        variance_array = obj.raw_pix_data(9, :);
        assertEqual(obj.pixel_data_obj.variance, variance_array)
    end

    function test_PIXELDATA_error_raised_if_setting_data_with_lt_9_cols(~)
        f = @(x) PixelData(zeros(x, 10));
        for i = [-10, -5, 0, 5]
            assertExceptionThrown(@() f(i), 'PIXELDATA:data');
        end
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

        function set_coordinates(data)
            pix_data_obj.coordinates = data;
        end

        f = @() (set_coordinates(new_coord_data));
        assertExceptionThrown(f, 'MATLAB:subsassigndimmismatch')
    end

    function test_error_raised_if_setting_coordinates_with_wrong_num_cols(obj)
        num_rows = 10;
        pix_data_obj = obj.get_random_pix_data_(num_rows);

        function set_coordinates(data)
            pix_data_obj.coordinates = data;
        end

        new_coord_data = ones(3, num_rows);
        f = @() set_coordinates(new_coord_data);
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

    function test_PIXELDATA_error_if_constructed_with_struct(~)
        s = struct();
        f = @() PixelData(s);
        assertExceptionThrown(f, 'PIXELDATA:data')
    end

    function test_PIXELDATA_error_if_constructed_with_cell_array(~)
        s = {'a', 1};
        f = @() PixelData(s);
        assertExceptionThrown(f, 'PIXELDATA:data')
    end

    function test_PIXELDATA_error_if_data_set_with_non_numeric_type(~)
        pix_data_obj = PixelData();

        function set_data(data)
            pix_data_obj.data = data;
        end

        f = @() set_data({1, 'abc'});
        assertExceptionThrown(f, 'PIXELDATA:data')
    end

    function test_numel_returns_the_number_of_elements_in_the_data(obj)
        assertEqual(numel(obj.pixel_data_obj), numel(obj.pixel_data_obj.data));
    end

    function test_can_construct_from_another_PixelData_object(obj)
        pixel_data_obj_copy = PixelData(obj.pixel_data_obj);
        assertEqual(pixel_data_obj_copy.data, obj.pixel_data_obj.data);
    end

    function test_get_data_returns_coordinates_for_given_index_range(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        coords = pix_data_obj.get_data({'coordinates'}, 2:6);
        assertEqual(coords, pix_data_obj.coordinates(:, 2:6));
    end

    function test_get_data_returns_multiple_fields_for_given_index_range(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        coord_sig = pix_data_obj.get_data({'coordinates', 'signal'}, 4:9);
        expected_coord_sig = [pix_data_obj.coordinates(:, 4:9); ...
                              pix_data_obj.signal(4:9)];
        assertEqual(coord_sig, expected_coord_sig);
    end

    function test_get_data_returns_full_pixel_range_if_no_range_given(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        coord_sig = pix_data_obj.get_data({'coordinates', 'signal'});
        expected_coord_sig = [pix_data_obj.coordinates; pix_data_obj.signal];
        assertEqual(coord_sig, expected_coord_sig);
    end

    function test_get_data_allows_data_retrieval_for_single_field(obj)
        for i = 1:numel(obj.pix_fields)
            field_data = obj.pixel_data_obj.get_data(obj.pix_fields{i});
            assertEqual(field_data, obj.pixel_data_obj.(obj.pix_fields{i}));
        end
    end

    function test_get_data_throws_PIXELDATA_on_non_valid_field_name(obj)
        f = @() obj.pixel_data_obj.get_data('not_a_field');
        assertExceptionThrown(f, 'PIXELDATA:get_data');
    end

    function test_get_data_orders_columns_corresponding_to_input_cell_array(obj)
        pix_data_obj = obj.get_random_pix_data_(10);
        data_subset = pix_data_obj.get_data({'detector_idx', 'signal', 'run_idx'});
        assertEqual(data_subset(1, :), pix_data_obj.detector_idx);
        assertEqual(data_subset(2, :), pix_data_obj.signal);
        assertEqual(data_subset(3, :), pix_data_obj.run_idx);
    end

    function test_cat_combines_given_PixelData_objects(obj)
        pix_data_obj1 = obj.get_random_pix_data_(10);
        pix_data_obj2 = obj.get_random_pix_data_(5);

        combined_pix = PixelData.cat(pix_data_obj1, pix_data_obj2);

        assertEqual(combined_pix.num_pixels, 15);
        assertEqual(combined_pix.data, ...
                    horzcat(pix_data_obj1.data, pix_data_obj2.data));
    end

    function test_get_pixels_returns_PixelData_obj_with_given_pix_indices(~)
        data = rand(9, 10);
        pix = PixelData(data);
        sub_pix = pix.get_pixels([3, 5, 7]);
        assertTrue(isa(pix, 'PixelData'));
        assertEqual(sub_pix.data, data(:, [3, 5, 7]));
    end

    function test_get_pixels_returns_PixelData_with_equal_num_cols(obj)
        pix = obj.get_random_pix_data_(10);
        orignal_size = size(pix.data, 1);
        sub_pix = pix.get_pixels(1:5);
        assertEqual(size(sub_pix.data, 1), orignal_size);
    end

    function test_load_obj_returns_equivalent_object(~)
        pix = PixelData.loadobj(PixelData(ones(9, 10)));
        assertEqual(pix.data, ones(9, 10));
    end

    function test_construction_with_int_fills_underlying_data_with_zeros(~)
        npix = 20;
        pix = PixelData(npix);
        assertEqual(pix.num_pixels, npix);
        assertEqual(pix.data, zeros(9, npix));
        assertEqual(pix.variance, zeros(1, npix));
    end

    function test_construction_with_float_raises_PIXELDATA_error(~)
        f = @() PixelData(1.2);
        assertExceptionThrown(f, 'PIXELDATA:data');
    end

    % --- Tests for file-backed operations ---
    function test_construction_with_file_path_sets_file_path_on_object(obj)
        assertEqual(obj.pix_data_from_file.file_path, obj.test_sqw_file_full_path);
    end

    function test_construction_with_file_path_populates_data_from_file(obj)
        assertFalse(isempty(obj.pix_data_from_file));
        expected_signal_chunk = [0, 0, 0, 0, 0483.5, 4463.0, 1543.0, 0, 0, 0];
        assertEqual(obj.pix_data_from_file.signal(9825:9834), ...
                    expected_signal_chunk);
    end

    function test_construction_with_file_path_sets_num_pixels_in_file(obj)
        f_accessor = sqw_formats_factory.instance().get_loader(...
                obj.test_sqw_file_path);
        assertEqual(obj.pix_data_from_file.num_pixels, f_accessor.npixels);
    end

    function test_construction_with_file_path_sets_size(obj)
        f_accessor = sqw_formats_factory.instance().get_loader(...
                obj.test_sqw_file_path);
        size_ax_1 = size(obj.pix_data_from_file, 1);
        assertEqual(size_ax_1, 9);

        size_ax_2 = size(obj.pix_data_from_file, 2);
        assertEqual(size_ax_2, f_accessor.npixels);
        assertEqual(obj.pix_data_from_file.num_pixels, f_accessor.npixels);
    end

    function test_error_on_construction_with_non_existent_file(~)
        file_path = 'not-a-file';
        f = @() PixelData(file_path);
        assertExceptionThrown(f, 'SQW_FILE_IO:runtime_error');
    end

    function test_construction_with_faccess_populates_data_from_file(obj)
        assertFalse(isempty(obj.pix_data_from_faccess));
        expected_signal_chunk = [0, 0, 0, 0, 0483.5, 4463.0, 1543.0, 0, 0, 0];
        assertEqual(obj.pix_data_from_faccess.signal(9825:9834), ...
                    expected_signal_chunk);
    end

    function test_construction_with_faccess_sets_file_path(obj)
        assertEqual(obj.pix_data_from_faccess.file_path, obj.test_sqw_file_full_path);
    end

    function test_page_size_is_set_after_getter_call_when_given_as_argument(obj)
        mem_alloc = obj.small_page_size_;  % 1Mb
        expected_page_size = floor(...
                mem_alloc/(obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK));
        % the first page is loaded on access, so this first assert which accesses
        % .variance is necessary to set pix.page_size
        assertEqual(size(obj.pix_data_small_page.variance), ...
                    [1, obj.pix_data_small_page.page_size]);
        assertEqual(obj.pix_data_small_page.page_size, expected_page_size);
    end

    function test_calling_getter_returns_data_for_single_page(obj)
        data = rand(9, 30);
        faccess = FakeFAccess(data);
        page_size = 11;
        mem_alloc = page_size*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);
        assertEqual(size(pix.signal), [1, pix.page_size]);
        assertEqual(pix.signal, data(8, 1:11));
    end

    function test_calling_get_data_returns_data_for_single_page(obj)
        data = rand(9, 30);
        faccess = FakeFAccess(data);
        page_size = 11;
        mem_alloc = page_size*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);
        sig_var = pix.get_data({'signal', 'variance'}, 3:8);
        assertEqual(sig_var, data(8:9, 3:8));
    end

    function test_data_values_are_not_effected_by_changes_in_copies(~)
        n_rows = 5;
        p1 = PixelData(ones(9, n_rows));
        p2 = copy(p1);
        p2.u1 = zeros(1, n_rows);
        assertEqual(p2.u1, zeros(1, n_rows));
        assertEqual(p1.u1, ones(1, n_rows));
    end

    function test_file_data_not_loaded_on_init_if_page_size_lt_num_pixels(obj)
        data = rand(9, 30);
        faccess = FakeFAccess(data);
        page_size = 11;
        mem_alloc = page_size*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);
        assertEqual(pix.page_size, 0);
        pix.u1;
        assertFalse(pix.page_size == 0);
    end

    function test_number_of_pixels_in_page_matches_memory_usage_size(obj)
        data = rand(9, 30);
        pix_in_page = 11;
        faccess = FakeFAccess(data);
        mem_alloc = pix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);
        pix.u1;
        assertEqual(size(pix.data, 2), pix_in_page);
    end

    function test_has_more_rets_true_if_there_are_subsequent_pixels_in_file(obj)
        data = rand(9, 12);
        pix_in_page = 11;
        mem_alloc = pix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        faccess = FakeFAccess(data);
        pix = PixelData(faccess, mem_alloc);
        assertTrue(pix.has_more());
    end

    function test_has_more_rets_false_if_all_data_in_page(obj)
        data = rand(9, 11);
        pix_in_page = 11;
        mem_alloc = pix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        faccess = FakeFAccess(data);
        pix = PixelData(faccess, mem_alloc);
        assertFalse(pix.has_more());
    end

    function test_has_more_rets_false_if_all_data_created_in_memory(~)
        data = rand(9, 30);
        pix = PixelData(data);
        assertFalse(pix.has_more());
    end

    function test_advance_loads_next_page_of_data_into_memory_for_props(obj)
        data = rand(9, 30);
        f = @(pix, iter) assertEqual(pix.signal, ...
                data(8, (iter*11 + 1):((iter*11 + 1) + pix.page_size - 1)));
        obj.do_pixel_data_loop_with_f(f, data);
    end

    function test_advance_loads_next_page_of_data_into_memory_for_get_data(obj)
        data = rand(9, 30);
        f = @(pix, iter) assertEqual(pix.get_data('signal'), ...
                data(8, (iter*11 + 1):((iter*11 + 1) + pix.page_size - 1)));

        obj.do_pixel_data_loop_with_f(f, data);
    end

    function test_advance_raises_PIXELDATA_if_at_end_of_data(obj)
        npix = 30;
        data = rand(9, npix);
        faccess = FakeFAccess(data);

        pix_in_page = 11;
        mem_alloc = pix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);

        f = @() obj.advance_pix(pix, floor(npix/pix_in_page + 1));
        assertExceptionThrown(f, 'PIXELDATA:advance')
    end

    function test_advance_does_nothing_if_PixelData_not_file_backed(~)
        data = rand(9, 10);
        pix = PixelData(data);
        pix.advance();
        assertEqual(pix.data, data);
    end

    function test_advance_while_loop_to_sum_signal_data(obj)
        data = randi([0, 99], 9, 30);
        faccess = FakeFAccess(data);

        pix_in_page = 11;
        mem_alloc = pix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);

        signal_sum = sum(pix.signal);
        while pix.has_more()
            pix.advance();
            signal_sum = signal_sum + sum(pix.signal);
        end

        assertEqual(signal_sum, sum(data(8, :)));
    end

    function test_page_size_returns_size_of_data_held_in_memory(obj)
        pix = obj.get_random_pix_data_(10);
        assertEqual(pix.page_size, 10);
        pix.data = zeros(9, 12);
        assertEqual(pix.page_size, 12);
    end

    function test_empty_PixelData_object_has_page_size_zero(~)
        pix = PixelData();
        assertEqual(pix.page_size, 0);
    end

    function test_constructing_from_PixelData_with_valid_file_inits_faccess(obj)
        new_pix = PixelData(obj.pix_data_small_page);
        assertEqual(new_pix.file_path, obj.test_sqw_file_full_path);
        assertEqual(new_pix.num_pixels, obj.pix_data_small_page.num_pixels);
        assertEqual(new_pix.signal, obj.pix_data_small_page.signal);
        assertTrue(new_pix.has_more());
    end

    % -- Helpers --
    function do_pixel_data_loop_with_f(obj, func, data)
        % func should be a function handle, it is evaluated within a
        % while-advance block over some pixel data
        faccess = FakeFAccess(data);

        pix_in_page = 11;
        mem_alloc = pix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);

        func(pix, 0)
        iter = 1;
        while pix.has_more()
            pix.advance();
            func(pix, iter)
            iter = iter + 1;
        end
    end

end

methods (Static)

    function advance_pix(pix, niters)
        for i = 1:niters
            pix.advance();
        end
    end

end

end
