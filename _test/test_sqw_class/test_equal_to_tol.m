classdef test_equal_to_tol < TestCase & common_sqw_class_state_holder

    properties
        horace_config;

        ALL_IN_MEM_PG_SIZE = 1e12;

        test_sqw_file_path;
        sqw_2d;
        sqw_2d_paged;

        test_dnd_file_path;
        dnd_2d;
    end

    methods

        function obj = test_equal_to_tol(~)
            obj = obj@TestCase('test_equal_to_tol');

            hc = hor_config();
            obj.horace_config = hc.get_data_to_store();

            pths = horace_paths;
            obj.test_sqw_file_path = fullfile(pths.test_common, 'sqw_2d_1.sqw');
            obj.test_dnd_file_path = fullfile(pths.test_common, 'dnd_2d.sqw');

            % sqw_2d_1.sqw has ~25,000 pixels, at 5000 pixels per page gives us 5
            % pages of pixel data
            %pixel_page_size = 5000; --> set page_size in configuration
            obj.sqw_2d_paged = sqw(obj.test_sqw_file_path,'file_backed', true);

            pix = obj.sqw_2d_paged.pix;
            assertTrue(pix.is_filebacked);

            obj.sqw_2d = sqw(obj.test_sqw_file_path);
        end

        function delete(obj)
            delete@common_sqw_class_state_holder(obj)
            set(hor_config, obj.horace_config);
        end

        function setUp(~)
            hc = hor_config();
            hc.saveable = false;
            hc.log_level = 0;  % hide the (quite verbose) equal_to_tol output
        end

        function tearDown(obj)
            set(hor_config,obj.horace_config);
        end

        function test_the_same_sqw_objects_are_equal(obj)
            sqw_copy = obj.sqw_2d;
            assertEqualToTol(obj.sqw_2d, sqw_copy);
        end

        function test_sqw_and_d2d_objects_are_not_equal(obj)
            dnd_2d_ = read_dnd(obj.test_dnd_file_path);
            [ok, mess] = equal_to_tol(obj.sqw_2d, dnd_2d_);
            assertFalse(ok);
            assertEqual(mess, 'Objects being compared are not the same type');
        end

        function test_the_same_sqw_objects_are_equal_with_no_pix_reorder(obj)
            sqw_copy = obj.sqw_2d;
            assertEqualToTol(obj.sqw_2d, sqw_copy, 'reorder', false);
        end

        function test_the_same_sqw_objects_are_equal_if_testing_fraction_of_pix(obj)
            sqw_copy = obj.sqw_2d;
            assertEqualToTol(obj.sqw_2d, sqw_copy, 'fraction', 0.5);
        end

        function test_same_sqw_objs_equal_if_pixels_in_each_bin_shuffled(obj)
            original_sqw = copy(obj.sqw_2d);
            pix = original_sqw.pix;
            npix = original_sqw.data.npix;

            shuffled_sqw = original_sqw;
            shuffled_sqw.pix = obj.shuffle_pixel_bin_rows(pix, npix);

            assertEqualToTol(shuffled_sqw, original_sqw);
        end

        function test_paged_sqw_objects_equal_if_pix_within_each_bin_shuffled(obj)
            original_sqw = copy(obj.sqw_2d_paged);
            npix = [10, 5, 6, 3, 6];

            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 30);
            shuffled_data = obj.shuffle_pixel_bin_rows(PixelDataBase.create(data), npix).data;

            pix = obj.get_pix_with_fake_faccess(data);
            shuffled_pix = obj.get_pix_with_fake_faccess(shuffled_data);

            % Replace sqw objects' npix and pix arrays
            original_sqw.data.do_check_combo_arg = false;
            original_sqw.data.npix = npix;
            original_sqw.pix = pix;
            shuffled_sqw = copy(original_sqw);
            shuffled_sqw.pix = shuffled_pix;

            assertEqualToTol(shuffled_sqw, original_sqw);
        end

        function test_paged_sqw_ne_if_pix_within_bin_shuffled_and_reorder_false(obj)
            original_sqw = copy(obj.sqw_2d_paged);
            npix = [10, 5, 6, 3, 6];

            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 30);
            shuffled_data = obj.shuffle_pixel_bin_rows(PixelDataBase.create(data), npix).data;

            pix = obj.get_pix_with_fake_faccess(data);
            shuffled_pix = obj.get_pix_with_fake_faccess(shuffled_data);

            % Replace sqw objects' npix and pix arrays
            original_sqw.data.do_check_combo_arg = false;
            original_sqw.data.npix = npix;
            original_sqw.pix = pix;
            shuffled_sqw = copy(original_sqw);
            shuffled_sqw.pix = shuffled_pix;

            assertFalse(equal_to_tol(shuffled_sqw, original_sqw, 'reorder', false));
        end

        function test_the_same_sqw_objects_are_equal_with_paged_pix(obj)
            sqw_copy = obj.sqw_2d_paged;
            assertEqualToTol(obj.sqw_2d_paged, sqw_copy);
        end

        function test_the_same_sqw_objs_eq_if_fraction_of_pix_and_pix_are_paged(obj)
            sqw_copy = obj.sqw_2d_paged;
            assertEqualToTol(obj.sqw_2d_paged, sqw_copy, 'fraction', 0.5);
        end

        function test_paged_and_non_paged_version_of_same_sqw_file_are_equal(obj)
            pobj = obj.sqw_2d_paged;
            pobj.experiment_info = obj.sqw_2d.experiment_info;
            pobj.main_header.nfiles = obj.sqw_2d.main_header.nfiles;
            %pobj.main_header.creation_date = obj.sqw_2d.main_header.creation_date;
            assertEqualToTol(pobj, obj.sqw_2d, 'fraction', 0.5,'-ignore_date');
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
            assertEqualToTol(sqw_copy, original_sqw, 'nan_equal', true);
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
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 30);
            edited_data = data;

            fraction = 0.5;
            % get the bins to zero out
            edited_data(:, 11:15) = 0;
            edited_data(:, 22:24) = 0;

            pix = obj.get_pix_with_fake_faccess(data);
            edited_pix = obj.get_pix_with_fake_faccess(edited_data);

            % Replace sqw objects' npix and pix arrays
            original_sqw.data.do_check_combo_arg = false;
            original_sqw.data.npix = npix;
            original_sqw.pix = pix;
            edited_sqw = copy(original_sqw);
            edited_sqw.pix = edited_pix;

            % check equal_to_tol false when comparing all bins
            assertFalse(equal_to_tol(edited_sqw, original_sqw, 'fraction', 1));
            % check equal_to_tol true when comparing a fraction of the bins
            assertEqualToTol(edited_sqw, original_sqw, 'fraction', fraction, 'reorder', true);
        end

        function test_using_fraction_argument_is_faster_than_comparing_all_pix(obj)
            skipTest('Regularly failing, so skipping to avoid test noise');
            sqw_copy = copy(obj.sqw_2d);

            num_reps = 5;
            num_iters = 5;

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
            assertEqualToTol(obj.sqw_2d_paged, sqw_copy, 'fraction', 0.5, ...
                'reorder', false);
        end

        function test_equal_to_tol_can_be_called_with_negative_tol_for_rel_tol(obj)
            sqw_copy = copy(obj.sqw_2d_paged);
            rel_tol = 1e-5;
            assertEqualToTol(sqw_copy, obj.sqw_2d_paged, -rel_tol);

            % find first non-zero signal value
            sig_idx = find(sqw_copy.data.s > 0, 1);

            % increase the difference in the value by 1% more than rel_tol
            value_diff = 1.01*rel_tol*obj.sqw_2d_paged.data.s(sig_idx);
            sqw_copy.data.s(sig_idx) = obj.sqw_2d_paged.data.s(sig_idx) + value_diff;

            assertFalse(equal_to_tol(sqw_copy, obj.sqw_2d_paged, -rel_tol));

            % check increasing the rel_tol by 1% returns true
            assertEqualToTol(sqw_copy, obj.sqw_2d_paged, -rel_tol*1.01);

            % check absolute tolerance still true
            assertEqualToTol(sqw_copy, obj.sqw_2d_paged, value_diff + 1e-8);
        end
    end

    methods (Static)

        function shuffled_pix = shuffle_pixel_bin_rows(pix, npix)
            % Shuffle the pixels in the bins defined by the npix array
            %
            npix_non_empty = npix(npix ~= 0);
            shuffled_pix = PixelDataBase.create(pix.num_pixels);

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

        function pix = get_pix_with_fake_faccess(data)
            pix = PixelDataFileBacked(data);
        end

    end

end
