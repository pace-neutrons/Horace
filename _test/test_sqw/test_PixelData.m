classdef test_PixelData < TestCase

properties
    old_warn_state;

    raw_pix_data = rand(9, 10);
    small_page_size_ = 1e6;  % 1Mb
    test_sqw_file_path = '../test_sqw_file/sqw_1d_1.sqw';
    test_sqw_file_full_path = '';
    this_dir = fileparts(mfilename('fullpath'));

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

        addpath(fullfile(obj.this_dir, 'utils'));

        % Swallow any warnings for when pixel page size set too small
        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');

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

    function delete(obj)
        rmpath(fullfile(obj.this_dir, 'utils'));
        warning(obj.old_warn_state);
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
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
        assertEqual(size(pix.signal), [1, pix.page_size]);
        assertEqual(pix.signal, data(8, 1:11));
    end

    function test_calling_get_data_returns_data_for_single_page(obj)
        data = rand(9, 30);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
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

    function test_number_of_pixels_in_page_matches_memory_usage_size(obj)
        data = rand(9, 30);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
        pix.u1;
        assertEqual(size(pix.data, 2), npix_in_page);
    end

    function test_has_more_rets_true_if_there_are_subsequent_pixels_in_file(obj)
        data = rand(9, 12);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
        assertTrue(pix.has_more());
    end

    function test_has_more_rets_false_if_all_data_in_page(obj)
        data = rand(9, 11);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
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
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        f = @() obj.advance_pix(pix, floor(npix/npix_in_page + 1));
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
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

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

    function test_move_to_first_page_resets_to_first_page_in_file(obj)
        data = rand(9, 30);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
        pix.advance();
        assertEqual(pix.u1, data(1, 12:22));  % currently on the second page
        pix.move_to_first_page();
        assertEqual(pix.u1, data(1, 1:11));  % should be back to the first page
    end

    function test_move_to_first_page_keeps_data_if_pix_not_file_backed(obj)
        pix = obj.get_random_pix_data_(30);
        u1 = pix.u1;
        pix.move_to_first_page();
        assertEqual(pix.u1, u1);
    end

    function test_instance_has_page_size_after_construction(~)
        data = rand(9, 10);
        faccess = FakeFAccess(data);
        pix = PixelData(faccess);
        assertEqual(pix.page_size, 10);
    end

    function test_editing_a_field_loads_page(obj)
        data = rand(9, 10);
        faccess = FakeFAccess(data);
        for i = 1:numel(obj.pix_fields)
            pix = PixelData(faccess);
            pix.(obj.pix_fields{i}) = 1;
            assertEqual(pix.page_size, 10);
        end
    end

    function test_setting_file_backed_pixels_preserves_changes_after_advance(obj)
        data = rand(9, 30);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        pix.u1 = 1;  % sets page 1 of u1 to all ones
        pix.advance();  % move to second page
        assertEqual(pix.u1, data(1, (npix_in_page + 1):(2*npix_in_page)));
        pix.move_to_first_page();
        assertEqual(pix.u1, ones(1, npix_in_page));
    end

    function test_dirty_pix_tmp_files_are_deleted_when_pix_out_of_scope(obj)
        old_rng_state = rng();
        fixed_seed = 774015;
        rng(fixed_seed, 'twister');  % this seed gives an expected object_id_ = 54452
        expected_tmp_dir = fullfile(tempdir(), 'sqw_pix54452');
        clean_up = onCleanup(@() rng(old_rng_state));

        function do_pix_creation_and_delete()
            data = rand(9, 30);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

            pix.u1 = 1;
            pix.advance();  % creates tmp file for first page
            assertTrue(logical(exist(expected_tmp_dir, 'dir')), ...
                       'Temp directory not created');
        end

        do_pix_creation_and_delete();
        assertFalse(logical(exist(expected_tmp_dir, 'dir')), ...
                    'Temp directory not deleted');
    end

    function test_all_page_changes_saved_after_edit_advance_and_reset(obj)
        data = zeros(9, 30);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        % set all u1 values in each page to 1
        pix.u1 = 1;
        while pix.has_more()
            pix.advance();  % move to second page
            pix.u1 = 1;  % sets page 1 of u1 to all ones
        end
        pix.move_to_first_page();

        % check all u1 values are still 1
        assertEqual(pix.u1, ones(1, pix.page_size));
        while pix.has_more()
            pix.advance();
            assertEqual(pix.u1, ones(1, pix.page_size));
        end
    end

    function test_correct_values_returned_with_mix_of_clean_and_dirty_pages(obj)
        data = zeros(9, 30);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        % set coordinates of page 1 and 3 to all ones
        pix.u1 = 1;
        pix.advance();  % move to second page
        pix.advance();  % move to third page
        pix.u1 = 1;

        pix.move_to_first_page();

        assertEqual(pix.u1, ones(1, pix.page_size));
        pix.advance();
        assertEqual(pix.u1, zeros(1, pix.page_size));
        pix.advance();
        assertEqual(pix.u1, ones(1, pix.page_size));
    end

    function test_you_cannot_set_page_of_data_with_smaller_sized_array(obj)
        data = zeros(9, 30);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        function set_pix(data)
            pix.data = data;
        end

        f = @() set_pix(ones(9, 10));
        assertExceptionThrown(f, 'PIXELDATA:data');
    end

    function test_you_cannot_set_page_of_data_with_larger_sized_array(obj)
        data = zeros(9, 30);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        function set_pix(data)
            pix.data = data;
        end

        f = @() set_pix(ones(9, 20));
        assertExceptionThrown(f, 'PIXELDATA:data');
    end

    function test_num_pixels_is_a_double_if_faccess_returns_uint(~)
        npix = 30;
        data = rand(9, npix);
        faccess = FakeFAccess(data);
        faccess = faccess.set_npixels(uint64(npix));

        pix = PixelData(faccess);
        assertEqual(class(pix.num_pixels), 'double');
    end

    function test_num_pixels_is_a_double_if_data_in_memory(obj)
        assertEqual(class(obj.pixel_data_obj.num_pixels), 'double');
    end

    function test_num_pixels_is_a_double_if_more_than_one_page_of_data(obj)
        assertEqual(class(obj.pix_data_small_page.num_pixels), 'double');
    end

    function test_copy_on_same_page_as_original_when_more_than_1_page(obj)
        pix_original = PixelData(obj.test_sqw_file_path, 1e6);
        pix_original.signal = 1;
        pix_original.advance();

        pix_copy = copy(pix_original);

        assertEqual(pix_copy.data, pix_original.data);
        while pix_original.has_more()
            pix_original.advance();
            pix_copy.advance();
            assertEqual(pix_copy.data, pix_original.data);
        end

        pix_copy.move_to_first_page();
        pix_original.move_to_first_page();
        assertEqual(pix_copy.data, pix_original.data);
    end

    function test_copy_on_same_pg_as_original_when_more_than_1_pg_no_advance(obj)
        pix_original = PixelData(obj.test_sqw_file_path, 1e6);
        pix_original.signal = 1;

        pix_copy = copy(pix_original);

        assertEqual(pix_copy.data, pix_original.data);
        while pix_original.has_more()
            pix_original.advance();
            pix_copy.advance();
            assertEqual(pix_copy.data, pix_original.data);
        end
    end

    function test_changes_to_original_persistent_in_copy_if_1_page_in_file(obj)
        pix_original = PixelData(obj.test_sqw_file_path, 1e9);
        pix_original.signal = 1;
        pix_original.advance();

        pix_copy = copy(pix_original);

        assertEqual(pix_copy.data, pix_original.data);
        while pix_original.has_more()
            % we shouldn't enter here, but we should check the same API for
            % data with > 1 page works for single page
            pix_original.advance();
            pix_copy.advance();
            assertEqual(pix_copy.data, pix_original.data);
        end

        pix_copy.move_to_first_page();
        pix_original.move_to_first_page();
        assertEqual(pix_copy.data, pix_original.data);
    end

    function test_changes_to_orig_persistent_in_copy_if_1_pg_in_file_no_adv(obj)
        pix_original = PixelData(obj.test_sqw_file_path, 1e9);
        pix_original.signal = 1;

        pix_copy = copy(pix_original);

        assertEqual(pix_copy.data, pix_original.data);
        while pix_original.has_more()
            % we shouldn't enter here, but we should check the same API for
            % data with > 1 page works for single page
            pix_original.advance();
            pix_copy.advance();
            assertEqual(pix_copy.data, pix_original.data);
        end
    end

    function test_changes_to_copy_have_no_affect_on_original_after_advance(obj)
        data = zeros(9, 30);
        npix_in_page = 11;
        pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
        pix_original.signal = 1;
        pix_original.advance();

        pix_copy = copy(pix_original);
        pix_copy.move_to_first_page();
        pix_copy.signal = 2;
        pix_copy.advance();

        pix_original.move_to_first_page();
        assertEqual(pix_original.signal, ones(1, numel(pix_original.signal)));

        pix_copy.move_to_first_page();
        assertEqual(pix_copy.signal, 2*ones(1, numel(pix_copy.signal)));
    end

    function test_changes_to_copy_have_no_affect_on_original_no_advance(obj)
        data = zeros(9, 30);
        npix_in_page = 11;
        pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
        pix_original.signal = 1;

        pix_copy = copy(pix_original);
        pix_copy.move_to_first_page();
        pix_copy.signal = 2;

        assertEqual(pix_original.signal, ones(1, numel(pix_original.signal)));
        assertEqual(pix_copy.signal, 2*ones(1, numel(pix_copy.signal)));
    end

    function test_changes_to_original_before_copy_are_reflected_in_copies(obj)
        data = zeros(9, 30);
        npix_in_page = 11;
        pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
        pix_original.signal = 1;
        pix_original.advance();

        pix_copy = copy(pix_original);
        pix_copy.move_to_first_page();

        assertEqual(pix_copy.signal, ones(1, numel(pix_copy.signal)));
    end

    function test_changes_to_original_kept_in_copy_after_advance(obj)
        pix_original = PixelData(obj.test_sqw_file_path, 1e2);
        pix_original.signal = 1;

        pix_copy = copy(pix_original);
        pix_copy.advance();

        pix_copy.move_to_first_page();
        assertEqual(pix_copy.signal, ones(1, numel(pix_copy.signal)));
    end

    function test_change_to_original_after_copy_does_not_affect_copy(obj)
        data = zeros(9, 30);
        npix_in_page = 11;
        pix_original = obj.get_pix_with_fake_faccess(data, npix_in_page);
        pix_copy = copy(pix_original);

        pix_copy.signal = 1;
        pix_copy.advance();

        pix_original.signal = 2;
        pix_original.advance();

        pix_copy.move_to_first_page();
        assertEqual(pix_copy.signal, ones(1, numel(pix_copy.signal)));
    end

    function test_page_written_correctly_when_page_size_gt_mem_chunk_size(obj)
        warning('off', 'HOR_CONFIG:set_mem_chunk_size');
        hc = hor_config;
        old_config = hc.get_data_to_store();
        npix_to_write = 28;
        size_of_float = 4;
        hc.mem_chunk_size = npix_to_write*size_of_float;

        function clean_up_func(conf_to_restore)
            set(hor_config, conf_to_restore);
            warning('on', 'HOR_CONFIG:set_mem_chunk_size');
        end

        clean_up = onCleanup(@() clean_up_func(old_config));

        npix_in_page = 90;
        data = zeros(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page + 10);
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        pix.data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
        pix.advance();
        pix.move_to_first_page();

        assertEqual(pix.data, ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page));
    end

    function test_pixels_read_correctly_if_final_pg_has_1_pixel(obj)
        data = rand(9, 10);
        npix_in_page = 3;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        assertEqual(pix.data, data(:, 1:3));
        pix.advance();
        assertEqual(pix.data, data(:, 4:6));
        pix.advance();
        assertEqual(pix.data, data(:, 7:9));
        pix.advance();
        assertEqual(pix.data, data(:, 10));
    end

    function test_unedited_dirty_pages_are_not_rewritten(obj)
        old_rng_state = rng();
        fixed_seed = 774015;  % this seed gives an expected object_id_ = 06706
        rng(fixed_seed, 'twister');
        expected_tmp_dir = fullfile(tempdir(), 'sqw_pix06706');
        clean_up = onCleanup(@() rng(old_rng_state));

        data = rand(9, 10);
        npix_in_page = 3;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        % edit a page such that it must be written to a file
        pix.signal = 1;
        pix = pix.advance();
        tmp_file_path = fullfile(expected_tmp_dir, '000000001.tmp');
        assertTrue(logical(exist(tmp_file_path, 'file')));

        % record the temp file's original timestamp
        original_timestamp = java.io.File(tmp_file_path).lastModified();

        % move to first page and advance again
        pix = pix.move_to_first_page();
        pix.signal;  % make sure there's data in memory
        pix.advance();  % no writing should happen here

        pause(0.2)  % let the file system catch up
        % get most recent timestamp
        new_timestamp = java.io.File(tmp_file_path).lastModified();

        assertEqual(new_timestamp, original_timestamp, ...
                    'Temporary file timestamps are not equal.');
    end

    function test_cannot_append_more_pixels_than_can_fit_in_page(obj)
        npix_in_page = 5;
        mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
        pix = PixelData(zeros(9, 0), mem_alloc);

        data = ones(obj.NUM_COLS_IN_PIX_BLOCK, 11);
        pix_to_append = PixelData(data);

        f = @() pix.append(pix_to_append);
        assertExceptionThrown(f, 'PIXELDATA:append');
    end

    function test_you_can_append_to_empty_PixelData_object(obj)
        npix_in_page = 11;
        mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
        pix = PixelData(zeros(9, 0), mem_alloc);

        data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
        pix_to_append = PixelData(data);

        pix.append(pix_to_append);
        assertEqual(pix.data, data);
    end

    function test_you_can_append_to_partially_full_PixelData_page(obj)
        npix_in_page = 11;
        nexisting_pix = 5;
        mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
        existing_data = rand(9, nexisting_pix);
        pix = PixelData(existing_data, mem_alloc);

        data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
        pix_to_append = PixelData(data);

        pg_offset = npix_in_page - nexisting_pix;
        expected_pg_1_data = horzcat(existing_data, data(:, 1:pg_offset));
        expected_pg_2_data = data(:, (pg_offset + 1):end);

        pix.append(pix_to_append);

        pix.move_to_first_page();
        assertEqual(pix.data, expected_pg_1_data, '', 1e-7);

        pix.advance();
        assertEqual(pix.data, expected_pg_2_data, '', 1e-7);
    end

    function test_you_can_append_to_PixelData_with_full_page(obj)
        npix_in_page = 11;
        nexisting_pix = 11;
        mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
        existing_data = rand(9, nexisting_pix);
        pix = PixelData(existing_data, mem_alloc);

        appended_data = ones(obj.NUM_COLS_IN_PIX_BLOCK, npix_in_page);
        pix_to_append = PixelData(appended_data);

        pix.append(pix_to_append);

        pix.move_to_first_page();
        assertEqual(pix.data, existing_data, '', 1e-7);

        pix.advance();
        assertEqual(pix.data, appended_data, '', 1e-7);
    end

    function test_appending_pixels_after_page_edited_preserves_changes(obj)
        npix_in_page = 11;
        num_pix = 24;
        mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
        original_data = rand(9, num_pix);

        pix = PixelData(original_data(:, 1:npix_in_page), mem_alloc);
        assertEqual(pix.data, original_data(:, 1:npix_in_page));
        pix.signal = ones(1, npix_in_page);

        for i = 2:ceil(num_pix/npix_in_page)
            start_idx = (i - 1)*npix_in_page + 1;
            end_idx = min(start_idx + npix_in_page - 1, num_pix);
            pix.append(PixelData(original_data(:, start_idx:end_idx)));
            assertEqual(pix.data, original_data(:, start_idx:end_idx));
        end

        pix.move_to_first_page();
        expected_pg_1_data = original_data(:, 1:npix_in_page);
        expected_pg_1_data(8, :) = 1;
        assertEqual(pix.data, expected_pg_1_data, '', 1e-7);
    end

    function test_you_can_append_to_file_backed_PixelData(obj)
        npix_in_page = 11;
        data = rand(9, 25);
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        data_to_append = rand(9, 8);
        pix_to_append = PixelData(data_to_append);

        pix.append(pix_to_append);

        expected_final_pg = horzcat(data(:, 23:end), data_to_append);
        assertEqual(pix.data, expected_final_pg);

        pix.move_to_first_page();
        assertEqual(pix.data, data(:, 1:npix_in_page), '', 1e-7);

        pix.advance();
        assertEqual(pix.data, data(:, (npix_in_page + 1):(2*npix_in_page)), ...
                    '', 1e-7);

        pix.advance();
        assertEqual(pix.data, expected_final_pg, '', 1e-7);
    end

    function test_error_if_append_called_with_non_PixelData_object(~)
        pix = PixelData(rand(9, 1));
        f = @() pix.append(rand(9, 1));
        assertExceptionThrown(f, 'PIXELDATA:append');
    end

    function test_error_if_appending_pix_with_multiple_pages(obj)
        npix_in_page = 11;
        mem_alloc = npix_in_page*obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
        pix = PixelData(rand(9, 5), mem_alloc);

        pix_to_append = obj.get_pix_with_fake_faccess(rand(9, 23), npix_in_page);
        f = @() pix.append(pix_to_append);
        assertExceptionThrown(f, 'PIXELDATA:append');
    end

    function test_append_does_not_edit_calling_instance_if_nargout_eq_1(obj)
        data = rand(9, 30);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
        pix_to_append = PixelData(rand(9, 5));

        out_pix = pix.append(pix_to_append);

        assertEqual(pix.num_pixels, size(data, 2));
        pix_data = concatenate_pixel_pages(pix);
        assertEqual(pix_data, data);
    end

    function test_append_returns_editied_pix_if_nargout_eq_1(obj)
        pix = PixelData(obj.test_sqw_file_path);
        npix_to_append = 5;
        pix_to_append = PixelData(rand(9, npix_to_append));

        out_pix = pix.append(pix_to_append);

        assertEqual(out_pix.num_pixels, pix.num_pixels + pix_to_append.num_pixels);
        original_pix_data = concatenate_pixel_pages(pix);
        out_pix_data = concatenate_pixel_pages(out_pix);
        assertEqual(out_pix_data, horzcat(original_pix_data, pix_to_append.data));
    end

    function test_calling_append_with_empty_pixel_data_does_nothing(~)
        pix = PixelData(rand(9, 5));
        pix_to_append = PixelData();
        appended_pix = pix.append(pix_to_append);
        assertEqual(appended_pix.data, pix.data);
    end

    function test_copied_pix_that_has_been_appended_to_has_correct_num_pix(~)
        data = rand(9, 30);
        pix = PixelData(data);
        num_appended_pix = 5;
        pix_to_append = PixelData(rand(9, num_appended_pix));
        pix.append(pix_to_append);

        pix_copy = copy(pix);
        assertEqual(pix.num_pixels, size(data, 2) + num_appended_pix);
        assertEqual(pix_copy.num_pixels, size(data, 2) + num_appended_pix);
    end

    function test_has_more_is_true_after_appending_page_to_non_file_backed(obj)
        num_pix = 10;
        mem_alloc = (num_pix + 1)*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(rand(9, 10), mem_alloc);

        pix_to_append = PixelData(rand(9, 5));
        pix.append(pix_to_append);

        pix.move_to_first_page();
        assertTrue(pix.has_more());
        pix.advance();
        assertFalse(pix.has_more());
    end

    function test_max_page_size_set_by_pixel_page_size_config_option(obj)
        hc = hor_config();
        old_config = hc.get_data_to_store();
        clean_up = onCleanup(@() set(hor_config, old_config));

        new_pix_page_size = 1000;  % bytes
        hc.pixel_page_size = new_pix_page_size;

        bytes_in_pixel = obj.NUM_COLS_IN_PIX_BLOCK*obj.NUM_BYTES_IN_VALUE;
        expected_page_size = floor(new_pix_page_size/bytes_in_pixel);
        pix = PixelData(obj.test_sqw_file_path);
        assertEqual(pix.page_size, expected_page_size);
    end

    function test_error_when_setting_mem_alloc_lt_one_pixel(~)
        pix_size = PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;

        f = @() PixelData(rand(9, 10), pix_size - 1);
        assertExceptionThrown(f, 'PIXELDATA:validate_mem_alloc');
    end

    % -- Helpers --
    function pix = get_pix_with_fake_faccess(obj, data, npix_in_page)
        faccess = FakeFAccess(data);
        % give it a real file path to trick code into thinking it exists
        faccess = faccess.set_filepath(obj.test_sqw_file_full_path);
        mem_alloc = npix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);
    end

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
        % Advance the pixel pages by 'niters'
        for i = 1:niters
            pix.advance();
        end
    end

end

end
