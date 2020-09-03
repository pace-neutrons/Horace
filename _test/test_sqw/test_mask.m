classdef test_mask < TestCase

properties
    this_dir = fileparts(mfilename('fullpath'));
    old_warn_state;

    sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    sqw_2d;
    sqw_2d_paged;
    idxs_to_mask;
    mask_array_2d;
    masked_2d;
    masked_2d_paged;

    sqw_3d_file_path = '../test_rebin/w3d_sqw.sqw';
    sqw_3d;
    sqw_3d_paged;
    idxs_to_mask_3d;
    mask_array_3d;
    masked_3d;
    masked_3d_paged;
end

methods

    function obj = test_mask(~)
        obj = obj@TestCase('test_mask');

        addpath(fullfile(obj.this_dir, 'utils'));

        % Swallow any warnings for when pixel page size set too small
        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');

        % 2D case setup
        obj.sqw_2d = sqw(obj.sqw_2d_file_path);

        obj.idxs_to_mask = [2, 46, 91, 93, 94, 107, 123, 166];
        obj.mask_array_2d = ones(size(obj.sqw_2d.data.npix), 'logical');
        obj.mask_array_2d(obj.idxs_to_mask) = 0;

        obj.masked_2d = mask(obj.sqw_2d, obj.mask_array_2d);
        [obj.sqw_2d_paged, obj.masked_2d_paged] = ...
                obj.get_paged_sqw(obj.sqw_2d_file_path, obj.mask_array_2d);

        % 3D case setup
        obj.sqw_3d = sqw(obj.sqw_3d_file_path);

        num_bins = numel(obj.sqw_3d.data.npix);
        obj.idxs_to_mask_3d = linspace(1, num_bins/2, num_bins/2);
        obj.mask_array_3d = ones(size(obj.sqw_3d.data.npix), 'logical');
        obj.mask_array_3d(obj.idxs_to_mask_3d) = 0;

        obj.masked_3d = mask(obj.sqw_3d, obj.mask_array_3d);
        [obj.sqw_3d_paged, obj.masked_3d_paged] = ...
                obj.get_paged_sqw(obj.sqw_3d_file_path, obj.mask_array_3d);
    end

    function delete(obj)
        rmpath(fullfile(obj.this_dir, 'utils'));
        warning(obj.old_warn_state);
    end

    function test_mask_sets_npix_in_masked_bins_to_zero(obj)
        assertEqual(sum(obj.masked_2d.data.npix(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_npix_in_masked_bins_to_zero_with_paged_pix(obj)
        assertEqual(sum(obj.masked_2d_paged.data.npix(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_signal_in_masked_bins_to_zero(obj)
        assertEqual(sum(obj.masked_2d.data.s(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_signal_in_masked_bins_to_zero_with_paged_pix(obj)
        assertEqual(sum(obj.masked_2d_paged.data.s(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_error_in_masked_bins_to_zero(obj)
        assertEqual(sum(obj.masked_2d.data.e(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_error_in_masked_bins_to_zero_with_paged_pix(obj)
        assertEqual(sum(obj.masked_2d_paged.data.e(~obj.mask_array_2d)), 0);
    end

    function test_mask_does_not_change_unmasked_bins_signal(obj)
        assertEqual(obj.masked_2d.data.s(obj.mask_array_2d), ...
                    obj.sqw_2d.data.s(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_signal_with_paged_pix(obj)
        assertEqual(obj.masked_2d_paged.data.s(obj.mask_array_2d), ...
                    obj.sqw_2d.data.s(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_error(obj)
        assertEqual(obj.masked_2d.data.e(obj.mask_array_2d), ...
                    obj.sqw_2d.data.e(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_error_with_paged_pix(obj)
        assertEqual(obj.masked_2d_paged.data.e(obj.mask_array_2d), ...
                    obj.sqw_2d.data.e(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_npix(obj)
        assertEqual(obj.masked_2d.data.npix(obj.mask_array_2d), ...
                    obj.sqw_2d.data.npix(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_npix_with_paged_pix(obj)
        assertEqual(obj.masked_2d_paged.data.npix(obj.mask_array_2d), ...
                    obj.sqw_2d.data.npix(obj.mask_array_2d));
    end

    function test_num_pixels_has_been_reduced_by_correct_amount(obj)
        expected_num_pix = sum(obj.sqw_2d.data.npix(obj.mask_array_2d));
        assertEqual(obj.masked_2d.data.pix.num_pixels, expected_num_pix);
    end

    function test_num_pix_has_been_reduced_by_correct_amount_with_paged_pix(obj)
        expected_num_pix = sum(obj.sqw_2d.data.npix(obj.mask_array_2d));
        assertEqual(obj.masked_2d_paged.data.pix.num_pixels, expected_num_pix);
    end

    function test_urange_recalculated_after_mask(obj)
        original_urange = obj.sqw_2d.data.urange;
        new_urange = obj.masked_2d.data.urange;

        urange_diff = abs(original_urange - new_urange);
        assertTrue(urange_diff(1) > 0.001);
        assertElementsAlmostEqual(original_urange(2:end), new_urange(2:end), ...
                                  'absolute', 0.001);
    end

    function test_urange_recalculated_after_mask_with_paged_pix(obj)
        original_urange = obj.sqw_2d.data.urange;
        new_urange = obj.masked_2d_paged.data.urange;

        urange_diff = abs(original_urange - new_urange);
        assertTrue(urange_diff(1) > 0.001);
        assertElementsAlmostEqual(original_urange(2:end), new_urange(2:end), ...
                                  'absolute', 0.001);
    end

    function test_urange_equal_for_paged_and_non_paged_sqw_after_mask(obj)
        paged_urange = obj.masked_2d_paged.data.urange;
        mem_urange = obj.masked_2d.data.urange;
        assertElementsAlmostEqual(mem_urange, paged_urange, 'absolute', 0.001);
    end

    function test_paged_and_non_paged_sqw_have_equivalent_pixels_after_mask(obj)
        raw_paged_pix = concatenate_pixel_pages(obj.masked_2d_paged.data.pix);
        assertEqual(raw_paged_pix, obj.masked_2d.data.pix.data);
    end

    function test_mask_sets_npix_in_masked_bins_to_zero_3d(obj)
        assertEqual(sum(obj.masked_3d.data.npix(~obj.mask_array_3d)), 0);
    end

    function test_mask_sets_npix_in_masked_bins_to_zero_with_paged_pix_3d(obj)
        assertEqual(sum(obj.masked_3d_paged.data.npix(~obj.mask_array_3d)), 0);
    end

    function test_mask_sets_signal_in_masked_bins_to_zero_3d(obj)
        assertEqual(sum(obj.masked_3d.data.s(~obj.mask_array_3d)), 0);
    end

    function test_mask_sets_signal_in_masked_bins_to_zero_with_paged_pix_3d(obj)
        assertEqual(sum(obj.masked_3d_paged.data.s(~obj.mask_array_3d)), 0);
    end

    function test_mask_sets_error_in_masked_bins_to_zero_3d(obj)
        assertEqual(sum(obj.masked_3d.data.e(~obj.mask_array_3d)), 0);
    end

    function test_mask_sets_error_in_masked_bins_to_zero_with_paged_pix_3d(obj)
        assertEqual(sum(obj.masked_3d_paged.data.e(~obj.mask_array_3d)), 0);
    end

    function test_mask_does_not_change_unmasked_bins_signal_3d(obj)
        assertEqual(obj.masked_3d.data.s(obj.mask_array_3d), ...
                    obj.sqw_3d.data.s(obj.mask_array_3d));
    end

    function test_mask_doesnt_change_unmasked_bins_signal_with_paged_pix_3d(obj)
        assertEqual(obj.masked_3d_paged.data.s(obj.mask_array_3d), ...
                    obj.sqw_3d.data.s(obj.mask_array_3d));
    end

    function test_mask_does_not_change_unmasked_bins_error_3d(obj)
        assertEqual(obj.masked_3d.data.e(obj.mask_array_3d), ...
                    obj.sqw_3d.data.e(obj.mask_array_3d));
    end

    function test_mask_does_not_change_unmasked_bins_error_with_paged_pix_3d(obj)
        assertEqual(obj.masked_3d_paged.data.e(obj.mask_array_3d), ...
                    obj.sqw_3d.data.e(obj.mask_array_3d));
    end

    function test_mask_does_not_change_unmasked_bins_npix_3d(obj)
        assertEqual(obj.masked_3d.data.npix(obj.mask_array_3d), ...
                    obj.sqw_3d.data.npix(obj.mask_array_3d));
    end

    function test_mask_does_not_change_unmasked_bins_npix_with_paged_pix_3d(obj)
        assertEqual(obj.masked_3d_paged.data.npix(obj.mask_array_3d), ...
                    obj.sqw_3d.data.npix(obj.mask_array_3d));
    end

    function test_num_pixels_has_been_reduced_by_correct_amount_3d(obj)
        expected_num_pix = sum(obj.sqw_3d.data.npix(obj.mask_array_3d));
        assertEqual(obj.masked_3d.data.pix.num_pixels, expected_num_pix);
    end

    function test_num_pix_has_been_reduced_by_correct_amount_paged_pix_3d(obj)
        expected_num_pix = sum(obj.sqw_3d.data.npix(obj.mask_array_3d));
        assertEqual(obj.masked_3d_paged.data.pix.num_pixels, expected_num_pix);
    end

    function test_urange_recalculated_after_mask_3d(obj)
        original_urange = obj.sqw_3d.data.urange;
        urange_diff = abs(original_urange - obj.masked_3d.data.urange);
        assertTrue(~all(urange_diff < 0.001, 'all'));
    end

    function test_urange_recalculated_after_mask_with_paged_pix_3d(obj)
        original_urange = obj.sqw_3d.data.urange;
        urange_diff = abs(original_urange - obj.masked_3d_paged.data.urange);
        assertTrue(~all(urange_diff < 0.001, 'all'));
    end

    function test_paged_and_non_paged_sqw_have_same_pixels_after_mask_3d(obj)
        raw_paged_pix = concatenate_pixel_pages(obj.masked_3d_paged.data.pix);
        assertEqual(raw_paged_pix, obj.masked_3d.data.pix.data);
    end

    function test_urange_equal_for_paged_and_non_paged_sqw_after_mask_3d(obj)
        paged_urange = obj.masked_3d_paged.data.urange;
        mem_urange = obj.masked_3d.data.urange;
        assertElementsAlmostEqual(mem_urange, paged_urange, 'absolute', 0.001);
    end

end

methods (Static)

    % -- Helpers --
    function [paged_sqw, masked_sqw] = get_paged_sqw(file_path, mask_array)
        old_pg_size = get(hor_config, 'pixel_page_size');
        clean_up = onCleanup(@() set(hor_config, 'pixel_page_size', old_pg_size));

        file_info = dir(file_path);
        new_pg_size = file_info.bytes/6;
        set(hor_config, 'pixel_page_size', new_pg_size);

        paged_sqw = sqw(file_path);
        masked_sqw = mask(paged_sqw, mask_array);

        % make sure we're actually paging the pixel data
        assertTrue(paged_sqw.data.pix.page_size < paged_sqw.data.pix.num_pixels);
    end

end

end
