classdef test_PixelData_binary_ops < TestCase & common_pix_class_state_holder

    properties
        BYTES_PER_PIX = PixelDataBase.DATA_POINT_SIZE*PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;

        FLOAT_TOLERANCE = 4.75e-4;

        test_sqw_file_path = '../common_data/sqw_1d_1.sqw';
        test_sqw_2d_file_path = '../common_data/sqw_2d_1.sqw';
        ref_raw_pix_data = [];

        pix_in_memory_base;
        pix_in_memory;
        pix_with_pages_base;
        pix_with_pages;

        old_warn_state;
        %
        call_count_transfer_;
    end

    methods

        function obj = test_PixelData_binary_ops(name)
            if ~exist('name','var')
                name = 'test_PixelData_binary_ops';
            end
            obj = obj@TestCase(name);

            % Load a 1D SQW file
            sqw_test_obj = sqw(obj.test_sqw_file_path);
            obj.ref_raw_pix_data = sqw_test_obj.pix.data;

            page_size = floor(sqw_test_obj.pix.num_pixels/6)*obj.BYTES_PER_PIX;
            obj.pix_in_memory_base = sqw_test_obj.pix;
            obj.pix_with_pages_base = PixelDataBase.create(obj.test_sqw_file_path, page_size);
        end

        function setUp(obj)
            obj.pix_in_memory = copy(obj.pix_in_memory_base);
            obj.pix_with_pages = copy(obj.pix_with_pages_base);
        end

        function test_plus_with_scalar_adds_operand_to_signal_with_unpaged_pix(obj)
            pix = obj.pix_in_memory;
            operand = 3;

            pix_result = pix.do_binary_op(operand, @plus);

            assertEqual(pix_result.signal, operand + pix.signal);
            assertEqual(pix_result.data([1:7, 9], :), pix.data([1:7, 9], :));
        end

        function test_plus_with_scalar_adds_operand_to_signal_with_paged_pix(obj)
            pix = obj.pix_with_pages;
            operand = 3;

            pix_result = pix.do_binary_op(operand, @plus);
            new_pix_data = concatenate_pixel_pages(pix_result);

            assertEqual( ...
                new_pix_data(obj.SIGNAL_IDX, :), ...
                operand + obj.pix_in_memory.signal, ...
                '', obj.FLOAT_TOLERANCE ...
                );
            assertEqual( ...
                new_pix_data([1:7, 9], :), ...
                obj.ref_raw_pix_data([1:7, 9], :), ...
                '', obj.FLOAT_TOLERANCE ...
                );
        end

        function test_scalar_minus_pix_subtracts_signal_from_operand_unpaged_pix(obj)
            pix = obj.pix_in_memory;
            operand = 3;

            pix_result = pix.do_binary_op(operand, @minus, 'flip', true);

            assertEqual(pix_result.signal, operand - pix.signal);
            assertEqual(pix_result.data([1:7, 9], :), pix.data([1:7, 9], :));
        end

        function test_pix_minus_scalar_subtracts_operand_from_pix_unpaged_pix(obj)
            pix = obj.pix_in_memory;
            operand = 3;

            pix_result = pix.do_binary_op(operand, @minus);

            assertEqual(pix_result.signal, pix.signal - operand);
            assertEqual(pix_result.data([1:7, 9], :), pix.data([1:7, 9], :));
        end

        function test_scalar_minus_subtracts_operand_from_signal_with_paged_pix(obj)
            pix = obj.pix_with_pages;
            operand = 3;

            pix_result = pix.do_binary_op(operand, @minus);
            new_pix_data = concatenate_pixel_pages(pix_result);

            assertEqual(new_pix_data(8, :), obj.pix_in_memory.signal - operand, ...
                '', obj.FLOAT_TOLERANCE);
            assertEqual(new_pix_data([1:7, 9], :), ...
                obj.ref_raw_pix_data([1:7, 9], :), ...
                '', obj.FLOAT_TOLERANCE);
        end

        function test_mtimes_with_scalar_returns_correct_data_1_page(obj)
            pix = obj.pix_in_memory;
            operand = 1.5;

            pix_result = pix.do_binary_op(operand, @mtimes, 'flip', true);

            assertEqual(pix_result.signal, operand*pix.signal);
            assertEqual(pix_result.variance, (operand.^2).*pix.variance);
            assertEqual(pix_result.data(1:7, :), pix.data(1:7, :));
        end

        function test_mtimes_with_scalar_returns_correct_data_gt_1_page(obj)
            pix = obj.pix_with_pages;
            operand = 1.5;

            pix_result = pix.do_binary_op(operand, @mtimes);
            new_pix_data = concatenate_pixel_pages(pix_result);

            assertElementsAlmostEqual(new_pix_data(obj.SIGNAL_IDX, :), ...
                obj.pix_in_memory.signal*operand, ...
                'relative', obj.FLOAT_TOLERANCE);
            assertElementsAlmostEqual(new_pix_data(obj.VARIANCE_IDX, :), ...
                (operand.^2).*obj.pix_in_memory.variance, ...
                'relative', obj.FLOAT_TOLERANCE);
            assertEqual(new_pix_data(1:7, :), obj.ref_raw_pix_data(1:7, :), ...
                '', obj.FLOAT_TOLERANCE);
        end

        function test_mrdivide_with_scalar_returns_correct_data_1_page(obj)
            pix = obj.pix_in_memory;
            operand = 1.5;

            pix_result = pix.do_binary_op(operand, @mrdivide, 'flip', true);

            assertEqual(pix_result.signal, operand./pix.signal);
            expected_var = pix.variance.*((pix_result.signal./pix.signal).^2);
            assertEqual(pix_result.variance, expected_var);
            assertEqual(pix_result.data(1:7, :), pix.data(1:7, :));
        end

        function test_mrdivide_with_scalar_returns_correct_data_gt_1_page(obj)
            pix = obj.pix_with_pages;
            operand = 1.5;

            pix_result = pix.do_binary_op(operand, @mrdivide);
            new_pix_data = concatenate_pixel_pages(pix_result);

            assertElementsAlmostEqual(new_pix_data(obj.SIGNAL_IDX, :), ...
                obj.pix_in_memory.signal./operand, ...
                'relative', obj.FLOAT_TOLERANCE);

            original_variance = obj.ref_raw_pix_data(obj.VARIANCE_IDX, :);
            expected_var = original_variance/(operand^2);
            expected_var(isnan(expected_var)) = 0;
            assertElementsAlmostEqual(new_pix_data(obj.VARIANCE_IDX, :), ...
                expected_var, ...
                'relative', obj.FLOAT_TOLERANCE);

            assertEqual(new_pix_data(1:7, :), obj.ref_raw_pix_data(1:7, :), ...
                '', obj.FLOAT_TOLERANCE);
        end

        function test_with_double_array_with_size_eq_to_num_pixels(obj)
            pix = obj.pix_with_pages;
            operand = ones(1, pix.num_pixels);

            pix_result = pix.do_binary_op(operand, @minus, 'flip', true);
            full_pix_array = concatenate_pixel_pages(pix_result);

            expected_signal = 1 - obj.pix_in_memory.signal;
            assertElementsAlmostEqual(full_pix_array(obj.SIGNAL_IDX, :), ...
                expected_signal, ...
                'relative', obj.FLOAT_TOLERANCE);
            assertElementsAlmostEqual(full_pix_array([1:7, 9], :), ...
                obj.ref_raw_pix_data([1:7, 9], :), ...
                'relative', obj.FLOAT_TOLERANCE);
        end

        function test_error_adding_double_with_length_neq_num_pixels(obj)
            pix = obj.pix_with_pages;
            operand = ones(1, pix.num_pixels - 1);

            f = @() pix.do_binary_op(operand, @plus);
            assertExceptionThrown(f, 'PIXELDATA:do_binary_op');
        end

        function test_error_two_PixelData_with_different_num_pixels(~)
            pix1 = PixelDataBase.create(rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10));
            pix2 = PixelDataBase.create(rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 11));
            f = @() pix1.do_binary_op(pix2, @plus);
            assertExceptionThrown(f, 'PIXELDATA:do_binary_op');
        end

        function test_minus_two_in_memory_PixelData_objects(obj)
            data1 = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix1 = PixelDataBase.create(data1);
            data2 = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix2 = PixelDataBase.create(data2);

            pix_diff = pix1.do_binary_op(pix2, @minus);

            expected_diff = data1;
            expected_diff(obj.SIGNAL_IDX, :) = pix1.signal - pix2.signal;
            expected_diff(obj.VARIANCE_IDX, :) = pix1.variance + pix2.variance;

            assertElementsAlmostEqual(pix_diff.data, expected_diff);
        end

        function test_subtracting_two_PixelData_objects_with_multiple_pages(obj)
            pix1 = obj.pix_with_pages;
            pix2 = copy(obj.pix_with_pages);
            % make sure we can deal with case where operand not on first page
            pix2.advance();

            pix_diff = pix1.do_binary_op(pix2, @minus);
            full_pix_diff = concatenate_pixel_pages(pix_diff);

            expected_diff = obj.ref_raw_pix_data;
            expected_diff(obj.SIGNAL_IDX, :) = 0;
            expected_diff(obj.VARIANCE_IDX, :) = 2*obj.ref_raw_pix_data(obj.VARIANCE_IDX, :);
            assertEqual(full_pix_diff, expected_diff);
        end

        function test_minus_2_PixelData_objects_1_in_mem_1_with_pages(obj)
            pix1 = obj.pix_with_pages;
            pix2 = obj.pix_in_memory;

            pix_diff = pix1.do_binary_op(pix2, @minus);
            full_pix_diff = concatenate_pixel_pages(pix_diff);

            expected_diff = obj.ref_raw_pix_data;
            expected_diff(obj.SIGNAL_IDX, :) = 0;
            expected_diff(obj.VARIANCE_IDX, :) = 2*obj.ref_raw_pix_data(obj.VARIANCE_IDX, :);
            assertEqual(full_pix_diff, expected_diff);
        end

        function test_plus_with_signal_array_and_npix_multiple_pages(obj)
            data = rand(obj.VARIANCE_IDX, 10);
            npix_in_page = 3;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

            npix = [1, 3, 0; 1, 1, 2; 0, 1, 1];
            sig_array = npix*rand(3);

            pix.do_binary_op(sig_array, @plus, 'npix', npix);
            new_pix_data = concatenate_pixel_pages(pix);

            expected_pix = data;
            expected_pix(obj.SIGNAL_IDX, :) = ...
                expected_pix(obj.SIGNAL_IDX, :) + repelem(sig_array(:), npix(:))';
            assertEqual(new_pix_data, expected_pix, '', obj.FLOAT_TOLERANCE);
        end

        function test_plus_with_signal_array_and_npix_1_page(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix = PixelDataBase.create(data);

            npix = [1, 3, 0; 1, 1, 2; 0, 1, 1];
            sig_array = npix*rand(3);

            new_pix = pix.do_binary_op(sig_array, @plus, 'npix', npix);

            expected_pix = data;
            expected_pix(obj.SIGNAL_IDX, :) = ...
                expected_pix(obj.SIGNAL_IDX, :) + repelem(sig_array(:), npix(:))';
            assertEqual(new_pix.data, expected_pix);
        end

        function test_PIXELDATA_error_on_where_npix_ne_num_pixels(~)
            num_pixels = 11;
            pix = PixelDataBase.create(num_pixels);
            npix = [3, 4, 3];
            sig = [0.5, 0.6, 0.7];

            f = @() pix.do_binary_op(sig, @plus, 'npix', npix);
            assertExceptionThrown(f, 'PIXELDATA:binary_op_double_');
        end

        function test_PIXELDATA_error_on_with_dnd_of_wrong_size(obj)
            dnd_obj = read_dnd(obj.test_sqw_file_path);
            pix = PixelDataBase.create(zeros(9, 2));
            f = @() pix.do_binary_op(dnd_obj, @plus);
            assertExceptionThrown(f, 'PIXELDATA:do_binary_op');
        end

        function test_with_1d_dnd_returns_correct_pix_with_single_page(obj)
            dnd_obj = read_dnd(obj.test_sqw_file_path);
            npix = dnd_obj.npix;
            pix = PixelDataBase.create(ones(9, sum(npix)));

            new_pix = pix.do_binary_op(dnd_obj, @plus, 'flip', false, ...
                'npix', npix);

            original_pix_data = concatenate_pixel_pages(pix);
            new_pix_data = concatenate_pixel_pages(new_pix);

            expected_pix = original_pix_data;
            expected_pix(obj.SIGNAL_IDX, :) = ...
                expected_pix(obj.SIGNAL_IDX, :) + repelem(dnd_obj.s(:), npix(:))';
            expected_pix(obj.VARIANCE_IDX, :) = ...
                expected_pix(obj.VARIANCE_IDX, :) + repelem(dnd_obj.e(:), npix(:))';
            assertEqual(new_pix_data, expected_pix);
        end

        function test_with_sigvar_returns_correct_pix_with_single_page(obj)
            dnd_obj = read_dnd(obj.test_sqw_file_path);
            npix = dnd_obj.npix;
            svar = sigvar(dnd_obj.s, dnd_obj.e);

            pix = PixelDataBase.create(ones(9, sum(dnd_obj.npix)));

            new_pix = pix.do_binary_op(svar, @plus, 'flip', false, ...
                'npix', npix);

            original_pix_data = concatenate_pixel_pages(pix);
            new_pix_data = concatenate_pixel_pages(new_pix);

            expected_pix = original_pix_data;
            expected_pix(obj.SIGNAL_IDX, :) = ...
                expected_pix(obj.SIGNAL_IDX, :) + repelem(svar.s(:), npix(:))';
            expected_pix(obj.VARIANCE_IDX, :) = ...
                expected_pix(obj.VARIANCE_IDX, :) + repelem(svar.e(:), npix(:))';
            assertEqual(new_pix_data, expected_pix);
        end

        function test_with_1d_dnd_returns_correct_pix_with_gt_1_page(obj)
            dnd_obj = read_dnd(obj.test_sqw_file_path);
            npix = dnd_obj.npix;

            pix_per_page = floor(sum(npix)/6);
            pix = PixelDataBase.create(obj.test_sqw_file_path, pix_per_page*obj.BYTES_PER_PIX);

            new_pix = pix.do_binary_op(dnd_obj, @plus, 'flip', false, ...
                'npix', npix);

            original_pix_data = concatenate_pixel_pages(pix);
            new_pix_data = concatenate_pixel_pages(new_pix);

            expected_pix = original_pix_data;
            expected_pix(obj.SIGNAL_IDX, :) = ...
                expected_pix(obj.SIGNAL_IDX, :) + repelem(dnd_obj.s(:), npix(:))';
            expected_pix(obj.VARIANCE_IDX, :) = ...
                expected_pix(obj.VARIANCE_IDX, :) + repelem(dnd_obj.e(:), npix(:))';
            assertElementsAlmostEqual(new_pix_data, expected_pix, 'relative', ...
                obj.FLOAT_TOLERANCE);
        end

        function test_with_sigvar_returns_correct_pix_with_gt_1_page(obj)
            dnd_obj = read_dnd(obj.test_sqw_file_path);
            npix = dnd_obj.npix;
            svar = sigvar(dnd_obj.s, dnd_obj.e);

            pix_per_page = floor(sum(npix)/6);
            mem_alloc = pix_per_page*obj.BYTES_PER_PIX;
            pix = PixelDataBase.create(obj.test_sqw_file_path, mem_alloc);

            new_pix = pix.do_binary_op(svar, @plus, 'flip', false, ...
                'npix', npix);

            original_pix_data = concatenate_pixel_pages(pix);
            new_pix_data = concatenate_pixel_pages(new_pix);

            expected_pix = original_pix_data;
            expected_pix(obj.SIGNAL_IDX, :) = ...
                expected_pix(obj.SIGNAL_IDX, :) + repelem(dnd_obj.s(:), npix(:))';
            expected_pix(obj.VARIANCE_IDX, :) = ...
                expected_pix(obj.VARIANCE_IDX, :) + repelem(dnd_obj.e(:), npix(:))';
            assertElementsAlmostEqual(new_pix_data, expected_pix, 'relative', ...
                obj.FLOAT_TOLERANCE);
        end

        function test_PIXELDATA_error_in_sigvar_if_sum_npix_ne_num_pix(obj)
            dnd_obj = read_dnd(obj.test_sqw_file_path);
            svar = sigvar(dnd_obj.s, dnd_obj.e);

            pix = PixelDataBase.create(ones(9, sum(dnd_obj.npix) + 1));

            f = @() pix.do_binary_op(svar, @plus, 'flip', false, ...
                'npix', dnd_obj.npix);
            assertExceptionThrown(f, 'PIXELDATA:binary_op_sigvar_');
        end

        function test_adding_2Dsigvar_returns_correct_pix_with_gt_1_page(obj)
            dnd_obj = read_dnd(obj.test_sqw_2d_file_path);
            npix = dnd_obj.npix;
            svar = sigvar(dnd_obj.s, dnd_obj.e);

            pix_per_page = floor(sum(npix(:)/6));
            mem_alloc = pix_per_page*obj.BYTES_PER_PIX;
            pix = PixelDataBase.create(obj.test_sqw_2d_file_path, mem_alloc);

            new_pix = pix.do_binary_op(svar, @plus, 'flip', false, ...
                'npix', npix);

            original_pix_data = concatenate_pixel_pages(pix);
            new_pix_data = concatenate_pixel_pages(new_pix);

            expected_pix = original_pix_data;
            expected_pix(obj.SIGNAL_IDX, :) = ...
                expected_pix(obj.SIGNAL_IDX, :) + repelem(svar.s(:), npix(:))';
            expected_pix(obj.VARIANCE_IDX, :) = ...
                expected_pix(obj.VARIANCE_IDX, :) + repelem(svar.e(:), npix(:))';
            assertElementsAlmostEqual(new_pix_data, expected_pix, 'relative', 1e-7);
        end

        function test_multiplying_with_2D_dnd_returns_correct_pix_with_gt_1_page(obj)
            dnd_obj = read_dnd(obj.test_sqw_2d_file_path);
            npix = dnd_obj.npix;

            pix_per_page = floor(sum(npix(:)/6));
            mem_alloc = pix_per_page*obj.BYTES_PER_PIX;
            pix = PixelDataBase.create(obj.test_sqw_2d_file_path, mem_alloc);

            new_pix = pix.do_binary_op(dnd_obj, @mtimes, 'flip', false, ...
                'npix', npix);

            original_pix_data = concatenate_pixel_pages(pix);
            new_pix_data = concatenate_pixel_pages(new_pix);

            s_dnd = repelem(dnd_obj.s(:), npix(:))';
            e_dnd = repelem(dnd_obj.e(:), npix(:))';
            s_pix = original_pix_data(obj.SIGNAL_IDX, :);
            e_pix = original_pix_data(obj.VARIANCE_IDX, :);

            expected_pix = original_pix_data;
            expected_pix(obj.SIGNAL_IDX, :) = s_pix.*s_dnd;

            % See mtimes_single for variance calculation
            expected_variance = (s_dnd.^2).*e_pix + (s_pix.^2).*e_dnd;
            expected_pix(obj.VARIANCE_IDX, :) = expected_variance;

            assertElementsAlmostEqual(new_pix_data, expected_pix, 'relative', 1e-7);
        end

        % -- Helpers --
        function pix = get_pix_with_fake_faccess(obj, data, npix_in_page)
            faccess = FakeFAccess(data);
            pix_size = obj.BYTES_PER_PIX;
            pix = PixelDataBase.create(faccess, npix_in_page*pix_size);
        end

    end

end
