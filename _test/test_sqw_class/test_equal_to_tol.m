classdef test_equal_to_tol < TestCase

properties
    old_config;
    old_warn_state;

    ALL_IN_MEM_PG_SIZE = 1e12;

    test_sqw_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    test_dnd_file_path = '../test_sqw_file/dnd_2d.sqw';

    dnd_2d;
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

        % sqw_2d_1.sqw has ~1.8 MB of pixels, a 400 kB page size gives us 5
        % pages of pixel data
        hc.pixel_page_size = 400e3;
        obj.sqw_2d_paged = sqw(obj.test_sqw_file_path);

        % set a large pixel page size so we're all in memory by default
        hc.pixel_page_size = obj.ALL_IN_MEM_PG_SIZE;
        obj.sqw_2d = sqw(obj.test_sqw_file_path);
        obj.dnd_2d = d2d(obj.test_dnd_file_path);
    end

    function delete(obj)
        set(hor_config, obj.old_config);
        warning(obj.old_warn_state);
    end

    function test_the_same_sqw_objects_are_equal(obj)
        sqw_copy = obj.sqw_2d;
        assertEqualToTol(obj.sqw_2d, sqw_copy);
    end

    function test_the_same_d2d_objects_are_equal(obj)
        dnd_copy = obj.dnd_2d;
        assertEqualToTol(obj.dnd_2d, dnd_copy);
    end

    function test_the_sqw_and_d2d_objects_are_not_equal(obj)
        [ok, mess] = equal_to_tol(obj.dnd_2d, obj.sqw_2d);
        assertFalse(ok);
        assertEqual(mess, 'Objects being compared are not both sqw-type or both dnd-type');
    end

    function test_the_different_sqw_objects_are_not_equal(obj)
        sqw_copy = obj.sqw_2d;
        class_fields = properties(sqw_copy);
        for idx = 1:numel(class_fields)
            field_name = class_fields{idx};
            
            if isstruct(sqw_copy.(field_name))
                sqw_copy.(field_name).test_field = 'test_value';
            elseif isstring(sqw_copy.(field_name))
                sqw_copy.(field_name) = 'test_value';
            else
                sqw_copy.(field_name) = [];
            end
            
            [ok, mess] = equal_to_tol(obj.sqw_2d, sqw_copy);
            assertFalse(ok, ['Expected ', field_name, ' to be not equal']);
        end
    end

    function test_the_different_d2d_objects_are_not_equal(obj)
        dnd_copy = obj.dnd_2d;
        class_fields = properties(dnd_copy);
        for idx = 1:numel(class_fields)
            field_name = class_fields{idx};
            if isstruct(dnd_copy.(field_name))
                dnd_copy.(field_name).test_field = 'test_value';
            elseif isstring(dnd_copy.(field_name))
                dnd_copy.(field_name) = 'test_value';
            else
                dnd_copy.(field_name) = [];
            end
            
            [ok, mess] = equal_to_tol(obj.dnd_2d, dnd_copy);
            assertFalse(ok, ['Expected ', field_name, ' to be not equal']);
        end
    end

    function test_the_different_d2d_objects_not_equal(obj)
        dnd_copy = obj.dnd_2d;
        dnd_copy.p = [];
        assertFalse(equal_to_tol(obj.dnd_2d, dnd_copy));
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

    function test_the_same_sqw_objs_eq_if_fraction_of_pix_and_pix_are_paged(obj)
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
        % Here we test that only a fraction of the pixels are compared when
        % using the 'fraction' argument.
        % A fraction value of 0.5 means that every other bin will be tested for
        % equality of pixels. So, in one of the sqw objects, we zero out all
        % the bins we do not intend to compare. This way, if we do compare any
        % of those bins, there will be a mismatch.
        original_sqw = copy(obj.sqw_2d_paged);
        npix = [10, 5, 6, 3, 6];
        data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 30);
        edited_data = data;

        fraction = 0.5;
        % get the bins to zero out
        bins_to_edit = round(2:(1/fraction):numel(npix));

        bin_end_idxs = cumsum(npix);
        bin_start_idxs = bin_end_idxs - npix + 1;
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

        % check equal_to_tol false when comparing all bins
        assertFalse(equal_to_tol(edited_sqw, original_sqw, 'fraction', 1));
        % check equal_to_tol true when comparing a fraction of the bins
        assertTrue(equal_to_tol(edited_sqw, original_sqw, 'fraction', fraction));
    end

    function test_using_fraction_argument_is_faster_than_comparing_all_pix(obj)
        sqw_copy = copy(obj.sqw_2d);

        num_reps = 10;
        num_iters = 1;

        f = @() equal_to_tol(sqw_copy, obj.sqw_2d);
        times_taken = benchmark_function(f, num_iters, num_reps);
        median_time_full = median(times_taken);

        f_partial = @() equal_to_tol(sqw_copy, obj.sqw_2d, 'fraction', 0.2);
        times_taken_partial = benchmark_function(f_partial, num_iters, num_reps);
        median_time_partial = median(times_taken_partial);

        assertTrue(median_time_full > median_time_partial);
    end

    function test_equal_to_tol_true_for_eq_sqw_reorder_false_with_fraction(obj)
        sqw_copy = copy(obj.sqw_2d_paged);
        assertTrue( ...
            equal_to_tol( ...
                obj.sqw_2d_paged, ...
                sqw_copy, ...
                'fraction', 0.5, ...
                'reorder', false ...
            ) ...
        );
    end

    function test_equal_to_tol_can_be_called_with_negative_tol_for_rel_tol(obj)
        sqw_copy = copy(obj.sqw_2d_paged);
        rel_tol = 1e-5;
        assertTrue(equal_to_tol(sqw_copy, obj.sqw_2d_paged, -rel_tol));

        % find first non-zero signal value
        sig_idx = find(sqw_copy.data.s > 0, 1);

        % increase the difference in the value by 1% more than rel_tol
        value_diff = 1.01*rel_tol*obj.sqw_2d_paged.data.s(sig_idx);
        sqw_copy.data.s(sig_idx) = obj.sqw_2d_paged.data.s(sig_idx) + value_diff;

        assertFalse(equal_to_tol(sqw_copy, obj.sqw_2d_paged, -rel_tol));

        % check increasing the rel_tol by 1% returns true
        assertTrue(equal_to_tol(sqw_copy, obj.sqw_2d_paged, -rel_tol*1.01))

        % check absolute tolerance still true
        assertTrue(equal_to_tol(sqw_copy, obj.sqw_2d_paged, value_diff + 1e-8));
    end

    function test_objects_are_not_equal_if_one_has_empty_pixeldata(obj)
        non_empty_sqw = obj.sqw_2d;
        empty_sqw = obj.sqw_2d;
        empty_sqw.data.pix = PixelData();

        assertFalse(equal_to_tol(empty_sqw, non_empty_sqw));
        assertFalse(equal_to_tol(non_empty_sqw, empty_sqw));
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

            % Checksum to ensure the bins' columns contain the same values
            assertEqual(sum(shuffled_bin_pix, 2), sum(pix_in_bin, 2), '', 1e-8);
        end
    end

    function pix = get_pix_with_fake_faccess(data, npix_in_page)
        faccess = FakeFAccess(data);
        bytes_in_pixel = PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
        pix = PixelData(faccess, npix_in_page*bytes_in_pixel);
    end

end

end
