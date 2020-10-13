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

end

methods (Static)

    function shuffled_pix = shuffle_pixel_bin_rows(pix, npix)
        % Shuffle the pixels in the bins defined by the npix array
        %
        npix_non_empty = npix(npix ~= 0);
        shuffled_pix = PixelData(pix.num_pixels);

        bin_start_idxs = cumsum(npix_non_empty(:)) - npix_non_empty(:) + 1;
        bin_end_idxs = cumsum(npix_non_empty(:));
        for i = 1:numel(npix_non_empty)
            bin_start = bin_start_idxs(i);
            bin_end = bin_end_idxs(i);

            pix_in_bin = pix.data(:, bin_start:bin_end);
            shuffled_bin_pix = pix_in_bin(:, randperm(size(pix_in_bin, 2)));
            shuffled_pix.data(:, bin_start:bin_end) = shuffled_bin_pix;

            % Checksum to ensure the bins columns contain the same values
            assertEqual(sum(shuffled_bin_pix, 2), sum(pix_in_bin, 2));
        end

    end

end

end
