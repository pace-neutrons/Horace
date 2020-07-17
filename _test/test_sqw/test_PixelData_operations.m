classdef test_PixelData_operations < TestCase

properties
    NUM_BYTES_IN_VALUE = 8;
    NUM_COLS_IN_PIX_BLOCK = 9;
    SIGNAL_IDX = 8;
    VARIANCE_IDX = 9;

    FLOAT_TOLERANCE = 4.75e-4;

    test_sqw_file_path = '../test_sqw_file/sqw_1d_1.sqw';
    ref_npix_data = [];
    ref_s_data = [];
    ref_e_data = [];

    pix_in_memory;
    pix_with_pages;
    page_size;

    config;
    old_config;
end

methods

    function obj = test_PixelData_operations(~)
        obj = obj@TestCase('test_PixelData_operations');

        sqw_test_obj = sqw(obj.test_sqw_file_path);
        obj.ref_npix_data = sqw_test_obj.data.npix;
        obj.ref_s_data = sqw_test_obj.data.s;
        obj.ref_e_data = sqw_test_obj.data.e;

        file_info = dir(obj.test_sqw_file_path);
        obj.page_size = file_info.bytes/6;  % Gives us 6 pages

        obj.pix_in_memory = sqw_test_obj.data.pix;
        obj.pix_with_pages = PixelData(obj.test_sqw_file_path, obj.page_size);
    end

    function setUp(obj)
        obj.config = hor_config;
        obj.old_config = obj.config.get_data_to_store();
    end

    function tearDown(obj)
        set(hor_config, obj.old_config);
    end

    function test_compute_bin_data_correct_output_in_memory_mex_1_thread(obj)
        obj.config.use_mex = true;
        obj.config.threads = 1;

        [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_in_memory_mex_4_threads(obj)
        obj.config.use_mex = true;
        obj.config.threads = 4;

        [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_all_data_in_memory_mex_off(obj)
        obj.config.use_mex = false;

        [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_file_backed_mex_1_thread(obj)
        obj.config.use_mex = true;
        obj.config.threads = 1;

        [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_5_pages_mex_1_thread(obj)
        obj.config.use_mex = true;
        obj.config.threads = 1;

        file_info = dir(obj.test_sqw_file_path);
        pg_size = file_info.bytes/5;
        pix = PixelData(obj.test_sqw_file_path, pg_size);
        [s, e] = pix.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_file_backed_mex_4_threads(obj)
        obj.config.use_mex = true;
        obj.config.threads = 4;

        [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_file_backed_mex_off(obj)
        obj.config.use_mex = false;

        [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_do_unary_op_returns_correct_output_with_cosine_gt_1_page(obj)
        data = rand(9, 50);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        pix = pix.do_unary_op(@cos_single);

        % Loop back through and validate values
        pix.move_to_first_page();
        iter = 0;
        while true
            start_idx = (iter*npix_in_page) + 1;
            end_idx = min(start_idx + npix_in_page - 1, pix.num_pixels);

            original_signal = data(obj.SIGNAL_IDX, start_idx:end_idx);
            original_variance = data(obj.VARIANCE_IDX, start_idx:end_idx);

            expected_data = data;
            expected_data(obj.SIGNAL_IDX, start_idx:end_idx) = ...
                    cos(original_signal);
            expected_data(obj.VARIANCE_IDX, start_idx:end_idx) = ...
                    abs(1 - pix.signal.^2).*original_variance;

            assertEqual(pix.data, expected_data(:, start_idx:end_idx), '', ...
                        obj.FLOAT_TOLERANCE);

            if pix.has_more()
                pix = pix.advance();
                iter = iter + 1;
            else
                break;
            end
        end
    end

    function test_paged_data_returns_same_unary_op_result_as_all_in_memory(obj)
        % the unary operation and the range the data it acts on should take
        unary_ops = {
            @acos, [0, 1], ...
            @acosh, [1, 3], ...
            @acot, [0, 1], ...
            @acoth, [10, 15], ...
            @acsc, [1, 3], ...
            @acsch, [1, 3], ...
            @asec, [1.5, 3], ...
            @asech, [0, 1], ...
            @asin, [0, 1], ...
            @asinh, [1, 3], ...
            @atan, [0, 1], ...
            @atanh, [0, 0.5], ...
            @cos, [0, 1], ...
            @cosh, [0, 1], ...
            @cot, [0, 1], ...
            @coth, [1.5, 3], ...
            @csc, [0.5, 2.5], ...
            @csch, [1, 3], ...
            @exp, [0, 1], ...
            @log, [1, 3], ...
            @log10, [1, 3], ...
            @sec, [2, 4], ...
            @sech, [0, 1.4], ...
            @sin, [0, 3], ...
            @sinh, [0, 3], ...
            @sqrt, [0, 3], ...
            @tan, [0, 1], ...
            @tanh [0, 3], ...
        };

        % For each unary operator, perform the operation on some file-backed
        % data and compare the result to the same operation used on the same
        % data all held in memory
        num_pix = 7;
        npix_in_page = 3;
        for i = 1:numel(unary_ops)/2
            unary_op = unary_ops{2*i - 1};
            data_range = unary_ops{2*i};

            data = obj.get_random_data_in_range(obj.NUM_COLS_IN_PIX_BLOCK, ...
                                                num_pix, data_range);
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix = pix.do_unary_op(unary_op);

            transformed_data = obj.concatenate_pixel_pages(pix);

            pix_in_mem = PixelData(data);
            pix_in_mem = pix_in_mem.do_unary_op(unary_op);
            expected_transformed_data = pix_in_mem.data;

            assertEqual(transformed_data, expected_transformed_data, ...
                        sprintf('Failure calculating ''%s''', char(unary_op)), ...
                        obj.FLOAT_TOLERANCE);
        end
    end

    function test_do_unary_op_returns_correct_output_with_cosine_1_page(obj)
        data = rand(9, 50);
        npix_in_page = 50;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        pix = pix.do_unary_op(@cos);

        original_signal = data(obj.SIGNAL_IDX, :);
        original_variance = data(obj.VARIANCE_IDX, :);

        expected_data = data;
        expected_data(obj.SIGNAL_IDX, :) = cos(original_signal);
        expected_data(obj.VARIANCE_IDX, :) = ...
                abs(1 - pix.signal.^2).*original_variance;

        assertEqual(pix.data, expected_data);
    end

    % -- Helpers --
    function pix = get_pix_with_fake_faccess(obj, data, npix_in_page)
        faccess = FakeFAccess(data);
        mem_alloc = npix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);
    end

    function data = concatenate_pixel_pages(obj, pix)
        pix = pix.move_to_first_page();
        base_pg_size = pix.page_size;
        data = zeros(obj.NUM_COLS_IN_PIX_BLOCK, pix.num_pixels);
        iter = 0;
        while true
            start_idx = (iter*base_pg_size) + 1;
            end_idx = min(start_idx + base_pg_size - 1, pix.num_pixels);
            data(:, start_idx:end_idx) = pix.data;
            iter = iter + 1;

            if pix.has_more()
                pix.advance();
            else
                break;
            end
        end
    end
end

methods (Static)
    function data = get_random_data_in_range(cols, rows, data_range)
        data = data_range(1) + (data_range(2) - data_range(1)).*rand(cols, rows);
    end
end

end
