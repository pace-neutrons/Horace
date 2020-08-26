classdef test_mask < TestCase

properties
    sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    sqw_2d;
    idxs_to_mask;
    mask_array_2d;
    masked_2d;
end

methods

    function obj = test_mask(~)
        obj = obj@TestCase('test_mask');

        obj.sqw_2d = sqw(obj.sqw_2d_file_path);

        obj.idxs_to_mask = [2, 46, 91, 93, 94, 107, 123, 166];
        obj.mask_array_2d = ones(size(obj.sqw_2d.data.npix), 'logical');
        obj.mask_array_2d(obj.idxs_to_mask) = 0;
        obj.masked_2d = mask(obj.sqw_2d, obj.mask_array_2d);
    end

    function test_mask_sets_npix_in_masked_bins_to_zero(obj)
        assertEqual(sum(obj.masked_2d.data.npix(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_signal_in_masked_bins_to_zero(obj)
        assertEqual(sum(obj.masked_2d.data.s(~obj.mask_array_2d)), 0);
    end

    function test_mask_sets_error_in_masked_bins_to_zero(obj)
        assertEqual(sum(obj.masked_2d.data.e(~obj.mask_array_2d)), 0);
    end

    function test_mask_does_not_change_unmasked_bins_signal(obj)
        assertEqual(obj.masked_2d.data.s(obj.mask_array_2d), ...
                    obj.sqw_2d.data.s(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_error(obj)
        assertEqual(obj.masked_2d.data.e(obj.mask_array_2d), ...
                    obj.sqw_2d.data.e(obj.mask_array_2d));
    end

    function test_mask_does_not_change_unmasked_bins_npix(obj)
        assertEqual(obj.masked_2d.data.npix(obj.mask_array_2d), ...
                    obj.sqw_2d.data.npix(obj.mask_array_2d));
    end

    function test_num_pixels_has_been_reduced_by_correct_amount(obj)
        expected_num_pix = sum(obj.sqw_2d.data.npix(obj.mask_array_2d));
        assertEqual(obj.masked_2d.data.pix.num_pixels, expected_num_pix);
    end

    function test_urange_recalculated_after_mask(obj)
        original_urange = obj.sqw_2d.data.urange;
        urange_diff = abs(original_urange - obj.masked_2d.data.urange);
        assertTrue(urange_diff(1) > 0.001);
    end

end

end
