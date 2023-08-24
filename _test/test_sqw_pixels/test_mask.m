classdef test_mask < TestCase & common_pix_class_state_holder

    properties

        sqw_2d_file_path;
        sqw_2d_num_pixels;
        sqw_2d;
        idxs_to_mask;
        mask_array_2d;
        masked_2d_pix_range;
        masked_2d_img_range;
        masked_2d_paged_cache;

        sqw_3d_file_path;
        sqw_3d;
        sqw_3d_paged;
        idxs_to_mask_3d;
        mask_array_3d;
        masked_3d;
        masked_3d_paged;
        % function handle to compare different array ranges
        fh_range_check;
        %
        call_count_transfer_;
    end

    methods

        function obj = test_mask(name)
            if ~exist('name','var')
                name = 'test_mask';
            end
            obj = obj@TestCase(name);

            pths = horace_paths();
            obj.sqw_2d_file_path = fullfile(pths.test_common, 'sqw_2d_1.sqw');
            obj.sqw_3d_file_path = fullfile(pths.test_common, 'w3d_sqw.sqw');

            % 2D case setup
            obj.sqw_2d = sqw(obj.sqw_2d_file_path, 'file_backed', false);
            obj.sqw_2d_num_pixels = obj.sqw_2d.pix.num_pixels;
            pix = obj.sqw_2d.pix;
            pix = pix.recalc_data_range();
            obj.sqw_2d.pix = pix;

            obj.idxs_to_mask = [2, 46, 91, 93, 94, 107, 123, 166];
            obj.mask_array_2d = true(size(obj.sqw_2d.data.npix));
            obj.mask_array_2d(obj.idxs_to_mask) = false;


            % 3D case setup
            obj.sqw_3d = sqw(obj.sqw_3d_file_path, 'file_backed', false);

            num_bins = numel(obj.sqw_3d.data.npix);
            obj.idxs_to_mask_3d = 1:num_bins/2;
            obj.mask_array_3d = true(size(obj.sqw_3d.data.npix));
            obj.mask_array_3d(obj.idxs_to_mask_3d) = false;

            obj.masked_3d = mask(obj.sqw_3d, obj.mask_array_3d);
            [obj.sqw_3d_paged, obj.masked_3d_paged,clPageConfig] = ...
                obj.get_paged_sqw(obj.sqw_3d_file_path, obj.mask_array_3d);

            obj.fh_range_check = @(data, limit) all(data<limit, 'all');

        end

        function test_mem_fb_equal_after_mask(obj)
            masked_2d = mask(obj.sqw_2d, obj.mask_array_2d);
            test_mask.check_filebacked_signal_averages(masked_2d);
            [~, masked_2d_paged,clPageConfig] = ...
                obj.get_paged_sqw(obj.sqw_2d_file_path, obj.mask_array_2d);

            assertEqualToTol(masked_2d_paged.pix, masked_2d.pix);
        end


        function test_mask_works_with_paged(obj)

            if isempty(obj.masked_2d_paged_cache)
                [~, masked_2d_paged,clPageConfig] = ...
                    obj.get_paged_sqw(obj.sqw_2d_file_path, obj.mask_array_2d);
                obj.masked_2d_paged_cache = masked_2d_paged;
                test_mask.check_filebacked_signal_averages(masked_2d_paged);
            else
                masked_2d_paged = obj.masked_2d_paged_cache;
            end


            %function test_mask_sets_npix_in_masked_bins_to_zero_with_paged_pix(obj)
            assertEqual(sum(masked_2d_paged.data.npix(~obj.mask_array_2d)), 0);
            %function test_mask_sets_signal_in_masked_bins_to_zero_with_paged_pix(obj)
            assertEqual(sum(masked_2d_paged.data.s(~obj.mask_array_2d)), 0);
            %function test_mask_sets_error_in_masked_bins_to_zero_with_paged_pix(obj)
            assertEqual(sum(masked_2d_paged.data.e(~obj.mask_array_2d)), 0);
            %end

            %function test_mask_does_not_change_unmasked_bins_signal_with_paged_pix(obj)
            assertEqual(masked_2d_paged.data.s(obj.mask_array_2d), ...
                obj.sqw_2d.data.s(obj.mask_array_2d));
            %function test_mask_does_not_change_unmasked_bins_error_with_paged_pix(obj)
            assertEqual(masked_2d_paged.data.e(obj.mask_array_2d), ...
                obj.sqw_2d.data.e(obj.mask_array_2d));
            %function test_mask_does_not_change_unmasked_bins_npix_with_paged_pix(obj)
            assertEqual(masked_2d_paged.data.npix(obj.mask_array_2d), ...
                obj.sqw_2d.data.npix(obj.mask_array_2d));

            % function test_num_pix_has_been_reduced_by_correct_amount_with_paged_pix(obj)
            expected_num_pix = sum(obj.sqw_2d.data.npix(obj.mask_array_2d));
            assertEqual(masked_2d_paged.pix.num_pixels, expected_num_pix);

            %function test_pix_range_recalculated_after_mask_with_paged_pix(obj)
            original_pix_range = obj.sqw_2d.pix.pix_range;
            new_pix_range = masked_2d_paged.pix.pix_range;

            img_range_diff = abs(original_pix_range - new_pix_range);
            assertTrue(img_range_diff(1) > 0.001);
            assertElementsAlmostEqual(original_pix_range(2,[1,2,4]), new_pix_range(2,[1,2,4]), ...
                'absolute', 0.001);
            assertElementsAlmostEqual(original_pix_range(1,3:end), new_pix_range(1,3:end), ...
                'absolute', 0.001);
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
            assertEqual(obj.masked_3d.pix.num_pixels, expected_num_pix);
        end

        function test_num_pix_has_been_reduced_by_correct_amount_paged_pix_3d(obj)
            expected_num_pix = sum(obj.sqw_3d.data.npix(obj.mask_array_3d));
            assertEqual(obj.masked_3d_paged.pix.num_pixels, expected_num_pix);
        end

        function test_img_range_recalculated_after_mask_3d(obj)
            original_img_range = obj.sqw_3d.data.img_range;
            img_range_diff = abs(original_img_range - obj.masked_3d.data.img_range);
            assertTrue(obj.fh_range_check(img_range_diff,1.e-7));
        end

        function test_img_range_recalculated_after_mask_with_paged_pix_3d(obj)
            original_img_range = obj.sqw_3d.data.img_range;
            img_range_diff = abs(original_img_range - obj.masked_3d_paged.data.img_range);
            assertTrue(obj.fh_range_check(img_range_diff ,1.e-7));
        end

        function test_paged_and_non_paged_sqw_have_same_pixels_after_mask_3d(obj)
            raw_paged_pix = PixelDataMemory(obj.masked_3d_paged.pix);
            assertEqualToTol(raw_paged_pix, obj.masked_3d.pix);
        end

        function test_img_range_equal_for_paged_and_non_paged_sqw_after_mask_3d(obj)
            paged_img_range = obj.masked_3d_paged.data.img_range;
            mem_img_range = obj.masked_3d.data.img_range;
            assertElementsAlmostEqual(mem_img_range, paged_img_range, 'absolute', 0.001);
        end

        function test_mask_pixels_removes_pixels_given_in_mask_array(obj)
            sqw_obj = sqw(obj.sqw_2d_file_path,'file_backed',false);
            mask_array = true(1, sqw_obj.pix.num_pixels);

            % Remove all pix where u1 greater than median u1
            % This ensures img_range and pix_range will be sufficiently different
            median_u1_range = median(sqw_obj.pix.u1);
            pix_to_remove = sqw_obj.pix.u1 > median_u1_range;

            mask_array(pix_to_remove) = false;
            new_sqw = mask_pixels(sqw_obj, mask_array);

            assertEqual(new_sqw.pix.num_pixels, sum(mask_array));
            %             assertEqualToTol(new_sqw.data.s, sqw_obj.data.s, [0, 1e-4]);
            % masking has not changed binning, so img_range remains the
            % same
            assertEqualToTol(new_sqw.data.img_range, sqw_obj.data.img_range, [0, 1e-7]);
            test_mask.check_filebacked_signal_averages(new_sqw);
        end

        function test_mask_works_in_memory(obj)
            masked_2d = mask(obj.sqw_2d, obj.mask_array_2d);

            test_mask.check_filebacked_signal_averages(masked_2d);

            %mask_sets_npix_in_masked_bins_to_zero
            assertEqual(sum(masked_2d.data.npix(~obj.mask_array_2d)), 0);
            %test_mask_sets_signal_in_masked_bins_to_zero
            assertEqual(sum(masked_2d.data.s(~obj.mask_array_2d)), 0);
            %test_mask_sets_error_in_masked_bins_to_zero
            assertEqual(sum(masked_2d.data.e(~obj.mask_array_2d)), 0);

            %test_mask_does_not_change_unmasked_bins_signal
            assertEqual(masked_2d.data.s(obj.mask_array_2d), ...
                obj.sqw_2d.data.s(obj.mask_array_2d));
            % test_mask_does_not_change_unmasked_bins_error
            assertEqual(masked_2d.data.s(obj.mask_array_2d), ...
                obj.sqw_2d.data.s(obj.mask_array_2d));
            % test_mask_does_not_change_unmasked_bins_npix
            assertEqual(masked_2d.data.npix(obj.mask_array_2d), ...
                obj.sqw_2d.data.npix(obj.mask_array_2d));

            % test_num_pixels_has_been_reduced_by_correct_amount
            expected_num_pix = sum(obj.sqw_2d.data.npix(obj.mask_array_2d));
            assertEqual(masked_2d.pix.num_pixels, expected_num_pix);

            % test_img_range_recalculated_after_mask

            original_pix_range = obj.sqw_2d.pix.pix_range;
            new_pix_range = masked_2d.pix.pix_range;
            obj.masked_2d_pix_range = new_pix_range;

            pix_range_diff = abs(original_pix_range - new_pix_range);
            assertTrue(pix_range_diff(1) > 0.001);

            assertElementsAlmostEqual(original_pix_range(2,:), new_pix_range(2,:), ...
                'absolute', 0.001);
            assertElementsAlmostEqual(original_pix_range(1,3:end), new_pix_range(1,3:end), ...
                'absolute', 0.001);

            if isempty(obj.masked_2d_paged_cache)
                [~, masked_2d_paged,clPageConfig] = ...
                    obj.get_paged_sqw(obj.sqw_2d_file_path, obj.mask_array_2d);
                obj.masked_2d_paged_cache = masked_2d_paged;
            else
                masked_2d_paged = obj.masked_2d_paged_cache;
            end

            % test_paged_and_non_paged_sqw_have_equivalent_pixels_after_mask
            raw_paged_pix = concatenate_pixel_pages(masked_2d_paged.pix);
            assertEqual(raw_paged_pix, masked_2d.pix.data);
        end

        function test_mask_random_fraction_removes_perc_of_pix_in_mem(obj)
            sqw_obj = sqw(obj.sqw_2d_file_path,'file_backed',false);

            frac_to_keep = 0.8;
            new_sqw = mask_random_fraction_pixels(sqw_obj, frac_to_keep);

            expected_num_pix = round(frac_to_keep*sqw_obj.pix.num_pixels);
            assertEqual(new_sqw.pix.num_pixels, expected_num_pix);

            test_mask.check_filebacked_signal_averages(new_sqw);

        end

        function test_mask_random_retains_correct_number_of_pix_on_file(obj)
            sqw_obj = sqw(obj.sqw_2d_file_path,'file_backed',true);
            new_pg_size = floor(obj.sqw_2d_num_pixels/6);
            clOb  = set_temporary_config_options(hor_config(), 'mem_chunk_size',new_pg_size);

            num_pix_to_keep = 5000;
            new_sqw = mask_random_pixels(sqw_obj, num_pix_to_keep);

            assertEqual(new_sqw.pix.num_pixels, num_pix_to_keep);

            test_mask.check_filebacked_signal_averages(new_sqw);
        end

        function test_mask_random_retains_correct_number_of_pix_in_mem(obj)
            sqw_obj = sqw(obj.sqw_2d_file_path,'file_backed',false);

            num_pix_to_keep = 5000;
            new_sqw = mask_random_pixels(sqw_obj, num_pix_to_keep);

            assertEqual(new_sqw.pix.num_pixels, num_pix_to_keep);

            test_mask.check_filebacked_signal_averages(new_sqw);
        end

    end

    methods (Static)
        function check_filebacked_signal_averages(sqw_to_check)
            assertEqual(sqw_to_check.pix.num_pixels, sum(sqw_to_check.data.npix(:)));
            ssignal = 0;
            serror  = 0;
            pix = sqw_to_check.pix;
            for i=1:pix.num_pages
                pix.page_num = i;
                ssignal = ssignal  + sum(pix.signal);
                serror  = serror   + sum(pix.variance);
            end
            assertEqualToTol(ssignal, ...
                sum(sqw_to_check.data.s(:).*sqw_to_check.data.npix(:)),'reltol',1.e-7);

            assertEqualToTol(serror, ...
                sum(sqw_to_check.data.e(:).*sqw_to_check.data.npix(:).^2),'reltol',1.e-7);


        end

        % -- Helpers --
        function [paged_sqw, masked_sqw,clOb] = get_paged_sqw(file_path, mask_array)

            paged_sqw = sqw(file_path,'file_backed', true);
            new_pg_size = floor(paged_sqw.pix.num_pixels/6);
            clOb  = set_temporary_config_options(hor_config(), 'mem_chunk_size',new_pg_size);
            masked_sqw = mask(paged_sqw, mask_array);

            test_mask.check_filebacked_signal_averages(paged_sqw);

        end

    end
end
