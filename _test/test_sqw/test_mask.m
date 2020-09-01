classdef test_mask < TestCase

properties
    this_dir = fileparts(mfilename('fullpath'));
    old_warn_state;

    sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    sqw_2d;
    idxs_to_mask;
    mask_array_2d;
    masked_2d;
end

methods

    function obj = test_mask(~)
        obj = obj@TestCase('test_mask');

        addpath(fullfile(obj.this_dir, 'utils'));

        % Swallow any warnings for when pixel page size set too small
        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');

        obj.sqw_2d = sqw(obj.sqw_2d_file_path);

        obj.idxs_to_mask = [2, 46, 91, 93, 94, 107, 123, 166];
        obj.mask_array_2d = ones(size(obj.sqw_2d.data.npix), 'logical');
        obj.mask_array_2d(obj.idxs_to_mask) = 0;
        obj.masked_2d = mask(obj.sqw_2d, obj.mask_array_2d);
    end

    function delete(obj)
        rmpath(fullfile(obj.this_dir, 'utils'));
        warning(obj.old_warn_state);
    end

    function test_mask_sets_npix_in_masked_bins_to_zero(obj)
        assertEqual(sum(obj.masked_2d.data.npix(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_npix_in_masked_bins_to_zero_with_paged_pix(obj)
        sqw_2d_paged = obj.get_paged_data();
        masked_sqw = mask(sqw_2d_paged, obj.mask_array_2d);
        assertEqual(sum(masked_sqw.data.npix(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_signal_in_masked_bins_to_zero(obj)
        assertEqual(sum(obj.masked_2d.data.s(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_signal_in_masked_bins_to_zero_with_paged_pix(obj)
        sqw_2d_paged = obj.get_paged_data();
        masked_sqw = mask(sqw_2d_paged, obj.mask_array_2d);
        assertEqual(sum(masked_sqw.data.s(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_error_in_masked_bins_to_zero(obj)
        assertEqual(sum(obj.masked_2d.data.e(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_error_in_masked_bins_to_zero_with_paged_pix(obj)
        sqw_2d_paged = obj.get_paged_data();
        masked_sqw = mask(sqw_2d_paged, obj.mask_array_2d);
        assertEqual(sum(masked_sqw.data.e(~obj.mask_array_2d)), 0);
    end

    function test_mask_does_not_change_unmasked_bins_signal(obj)
        assertEqual(obj.masked_2d.data.s(obj.mask_array_2d), ...
                    obj.sqw_2d.data.s(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_signal_with_paged_pix(obj)
        sqw_2d_paged = obj.get_paged_data();
        masked_sqw = mask(sqw_2d_paged, obj.mask_array_2d);
        assertEqual(masked_sqw.data.s(obj.mask_array_2d), ...
                    obj.sqw_2d.data.s(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_error(obj)
        assertEqual(obj.masked_2d.data.e(obj.mask_array_2d), ...
                    obj.sqw_2d.data.e(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_error_with_paged_pix(obj)
        sqw_2d_paged = obj.get_paged_data();
        masked_sqw = mask(sqw_2d_paged, obj.mask_array_2d);
        assertEqual(masked_sqw.data.e(obj.mask_array_2d), ...
                    obj.sqw_2d.data.e(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_npix(obj)
        assertEqual(obj.masked_2d.data.npix(obj.mask_array_2d), ...
                    obj.sqw_2d.data.npix(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_npix_with_paged_pix(obj)
        sqw_2d_paged = obj.get_paged_data();
        masked_sqw = mask(sqw_2d_paged, obj.mask_array_2d);
        assertEqual(masked_sqw.data.npix(obj.mask_array_2d), ...
                    obj.sqw_2d.data.npix(obj.mask_array_2d));
    end

    function test_num_pixels_has_been_reduced_by_correct_amount(obj)
        expected_num_pix = sum(obj.sqw_2d.data.npix(obj.mask_array_2d));
        assertEqual(obj.masked_2d.data.pix.num_pixels, expected_num_pix);
    end

    function test_num_pix_has_been_reduced_by_correct_amount_with_paged_pix(obj)
        sqw_2d_paged = obj.get_paged_data();
        masked_sqw = mask(sqw_2d_paged, obj.mask_array_2d);

        expected_num_pix = sum(obj.sqw_2d.data.npix(obj.mask_array_2d));
        assertEqual(masked_sqw.data.pix.num_pixels, expected_num_pix);
    end

    function test_urange_recalculated_after_mask(obj)
        original_urange = obj.sqw_2d.data.urange;
        urange_diff = abs(original_urange - obj.masked_2d.data.urange);
        assertTrue(urange_diff(1) > 0.001);
        assertTrue(all(urange_diff(2:end) < 0.001));
    end

    function test_urange_recalculated_after_mask_with_paged_pix(obj)
        sqw_2d_paged = obj.get_paged_data();
        masked_sqw = mask(sqw_2d_paged, obj.mask_array_2d);

        original_urange = obj.sqw_2d.data.urange;
        urange_diff = abs(original_urange - masked_sqw.data.urange);
        assertTrue(urange_diff(1) > 0.001);
        assertTrue(all(urange_diff(2:end) < 0.001));
    end

    % -- Helpers --
    function paged_sqw = get_paged_data(obj)
        old_pg_size = get(hor_config, 'pixel_page_size');
        clean_up = onCleanup(@() set(hor_config, 'pixel_page_size', old_pg_size));

        file_info = dir(obj.sqw_2d_file_path);
        new_pg_size = file_info.bytes/6;
        set(hor_config, 'pixel_page_size', new_pg_size);

        paged_sqw = sqw(obj.sqw_2d_file_path);
    end

end

end
