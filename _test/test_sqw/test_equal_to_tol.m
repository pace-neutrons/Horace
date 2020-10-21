classdef test_equal_to_tol < TestCase

properties
    old_config;
    old_warn_state;

    test_sqw_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    sqw_2d;
    sqw_2d_paged;
end

methods

    function obj = test_equal_to_tol(~)
        obj = obj@TestCase('test_equal_to_tol');

        % Swallow any warnings for when pixel page size set too small
        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');

        hc = hor_config();
        obj.old_config = hc.get_data_to_store();

        hc.log_level = 0;  % hide the (quite verbose) equal_to_tol output

        hc.pixel_page_size = 100e3;
        obj.sqw_2d_paged = sqw(obj.test_sqw_file_path);

        % set a large pixel page size so we're all in memory by default
        hc.pixel_page_size = 1e12;
        obj.sqw_2d = sqw(obj.test_sqw_file_path);
    end

    function delete(obj)
        set(hor_config, obj.old_config);
        warning(obj.old_warn_state);
    end

    function test_the_same_sqw_objects_are_equal(obj)
        sqw_copy = obj.sqw_2d;
        assertTrue(equal_to_tol(obj.sqw_2d, sqw_copy));
    end

    function test_the_same_sqw_objects_are_equal_with_no_pix_reorder(obj)
        sqw_copy = obj.sqw_2d;
        assertTrue(equal_to_tol(obj.sqw_2d, sqw_copy, 'reorder', false));
    end

    function test_the_same_sqw_objects_are_equal_if_testing_fraction_of_pix(obj)
        sqw_copy = obj.sqw_2d;
        assertTrue(equal_to_tol(obj.sqw_2d, sqw_copy, 'fraction', 0.5));
    end

    function test_same_sqw_objs_equal_if_pixels_in_each_bin_shuffled(obj)
        original_sqw = copy(obj.sqw_2d);
        pix = original_sqw.data.pix;
        npix = original_sqw.data.npix;

        shuffled_sqw = original_sqw;
        shuffled_sqw.data.pix = obj.shuffle_pixel_bin_rows(pix, npix);

        assertTrue(equal_to_tol(shuffled_sqw, original_sqw));
    end

    function test_paged_sqw_objects_equal_if_pix_within_each_bin_shuffled(obj)
        original_sqw = copy(obj.sqw_2d_paged);
        npix = [10, 5, 6, 3, 6];

        data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 30);
        shuffled_data = obj.shuffle_pixel_bin_rows(PixelData(data), npix).data;

        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
        shuffled_pix = obj.get_pix_with_fake_faccess(shuffled_data, npix_in_page);

        % Replace sqw objects' npix and pix arrays
        original_sqw.data.npix = npix;
        original_sqw.data.pix = pix;
        shuffled_sqw = copy(original_sqw);
        shuffled_sqw.data.pix = shuffled_pix;

        assertTrue(equal_to_tol(shuffled_sqw, original_sqw));
    end

    function test_paged_sqw_ne_if_pix_within_bin_shuffled_and_reorder_false(obj)
        original_sqw = copy(obj.sqw_2d_paged);
        npix = [10, 5, 6, 3, 6];

        data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 30);
        shuffled_data = obj.shuffle_pixel_bin_rows(PixelData(data), npix).data;

        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
        shuffled_pix = obj.get_pix_with_fake_faccess(shuffled_data, npix_in_page);

        % Replace sqw objects' npix and pix arrays
        original_sqw.data.npix = npix;
        original_sqw.data.pix = pix;
        shuffled_sqw = copy(original_sqw);
        shuffled_sqw.data.pix = shuffled_pix;

        assertFalse(equal_to_tol(shuffled_sqw, original_sqw, 'reorder', false));
    end

    function test_the_same_sqw_objects_are_equal_with_paged_pix(obj)
        sqw_copy = obj.sqw_2d_paged;
        assertTrue(equal_to_tol(obj.sqw_2d_paged, sqw_copy));
    end

    function test_the_same_sqw_objs_eq_if_fraction_of_pix_and_pix_paged(obj)
        sqw_copy = obj.sqw_2d_paged;
        assertTrue(equal_to_tol(obj.sqw_2d_paged, sqw_copy, 'fraction', 0.5));
    end

    function test_paged_and_non_paged_version_of_same_sqw_file_are_equal(obj)
        assertTrue(equal_to_tol(obj.sqw_2d_paged, obj.sqw_2d, 'fraction', 0.5));
    end

    function test_false_returned_if_NaNs_in_sqw_and_nan_equal_is_false(obj)
        original_sqw = copy(obj.sqw_2d);
        original_sqw.data.s(5) = nan;
        sqw_copy = copy(original_sqw);

        assertFalse(equal_to_tol(original_sqw, obj.sqw_2d, 'nan_equal', false));
        assertFalse(equal_to_tol(sqw_copy, original_sqw, 'nan_equal', false));
    end

    function test_true_returned_if_NaNs_in_sqw_and_nan_equal_is_true(obj)
        original_sqw = copy(obj.sqw_2d);
        original_sqw.data.s(5) = nan;
        sqw_copy = copy(original_sqw);

        assertFalse(equal_to_tol(original_sqw, obj.sqw_2d, 'nan_equal', true));
        assertTrue(equal_to_tol(sqw_copy, original_sqw, 'nan_equal', true));
    end

    function test_using_fraction_argument_only_tests_fraction_of_the_bins(obj)
        original_sqw = copy(obj.sqw_2d_paged);
        npix = [10, 5, 6, 3, 6];
        bin_end_idxs = cumsum(npix);
        bin_start_idxs = bin_end_idxs - npix + 1;

        fraction = 0.5;

        data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 30);
        edited_data = data;
        bins_to_edit = round(2:(1/fraction):numel(npix));

        for i = 1:numel(bins_to_edit)
            bin_num = bins_to_edit(i);
            edited_data(:, bin_start_idxs(bin_num):bin_end_idxs(bin_num)) = 0;
        end

        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
        edited_pix = obj.get_pix_with_fake_faccess(edited_data, npix_in_page);

        % Replace sqw objects' npix and pix arrays
        original_sqw.data.npix = npix;
        original_sqw.data.pix = pix;
        edited_sqw = copy(original_sqw);
        edited_sqw.data.pix = edited_pix;

        assertFalse(equal_to_tol(edited_sqw, original_sqw, 'fraction', 1));
        assertTrue(equal_to_tol(edited_sqw, original_sqw, 'fraction', fraction));
    end

    function test_using_fraction_argument_is_faster_than_comparing_all_pix(obj)
        sqw_copy = copy(obj.sqw_2d);

        num_reps = 5;
        num_iters = 1;

        f = @() equal_to_tol(sqw_copy, obj.sqw_2d);
        [~, median_time_full] = benchmark_function(f, num_iters, num_reps);

        f_partial = @() equal_to_tol(sqw_copy, obj.sqw_2d, 'fraction', 0.2);
        [~, median_time_partial] = benchmark_function(f_partial, num_iters, ...
                                                      num_reps);

        assertTrue(median_time_full > median_time_partial);
    end
end

methods (Static)

    function shuffled_pix = shuffle_pixel_bin_rows(pix, npix)
        % Shuffle the pixels in the bins defined by the npix array
        %
        npix_non_empty = npix(npix ~= 0);
        shuffled_pix = PixelData(pix.num_pixels);

        bin_end_idxs = cumsum(npix_non_empty(:));
        bin_start_idxs = bin_end_idxs - npix_non_empty(:) + 1;
        for i = 1:numel(npix_non_empty)
            bin_start = bin_start_idxs(i);
            bin_end = bin_end_idxs(i);

            pix_in_bin = pix.data(:, bin_start:bin_end);
            shuffled_bin_pix = pix_in_bin(:, randperm(size(pix_in_bin, 2)));
            shuffled_pix.data(:, bin_start:bin_end) = shuffled_bin_pix;

            % Checksum to ensure the bin's columns contain the same values
            assertEqual(sum(shuffled_bin_pix, 2), sum(pix_in_bin, 2), '', [0, 1e-8]);
        end
    end

    function pix = get_pix_with_fake_faccess(data, npix_in_page)
        faccess = FakeFAccess(data);
        bytes_in_pixel = PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
        pix = PixelData(faccess, npix_in_page*bytes_in_pixel);
    end

end

end
