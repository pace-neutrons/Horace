classdef test_PixelData_operations < TestCase
    
    properties
        BYTES_PER_PIX = PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
        
        ALL_IN_MEM_PG_SIZE = 1e12;
        FLOAT_TOLERANCE = 4.75e-4;
        
        this_dir = fileparts(mfilename('fullpath'));
        test_sqw_file_path = '../test_sqw_file/sqw_1d_1.sqw';
        test_sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw';
        ref_npix_data = [];
        ref_s_data = [];
        ref_e_data = [];
        
        pix_in_memory_base;
        pix_in_memory;
        pix_with_pages_base;
        pix_with_pages;
        
        pix_with_pages_2d;
        ref_npix_data_2d;
        ref_s_data_2d;
        ref_e_data_2d;
        
        old_warn_state;
    end
    
    methods
        
        function obj = test_PixelData_operations(~)
            obj = obj@TestCase('test_PixelData_operations');
            
            addpath(fullfile(obj.this_dir, 'utils'));
            
            % Swallow any warnings for when pixel page size set too small
            obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');
            
            % Load a 1D SQW file
            sqw_test_obj = sqw(obj.test_sqw_file_path);
            obj.ref_npix_data = sqw_test_obj.data.npix;
            obj.ref_s_data = sqw_test_obj.data.s;
            obj.ref_e_data = sqw_test_obj.data.e;
            
            num_pix_pages = 6;
            page_size = floor(sqw_test_obj.data.pix.num_pixels/num_pix_pages)*obj.BYTES_PER_PIX;
            obj.pix_in_memory_base = sqw_test_obj.data.pix;
            obj.pix_with_pages_base = PixelData(obj.test_sqw_file_path, page_size);
            
            % Load 2D SQW file
            sqw_2d_test_object = sqw(obj.test_sqw_2d_file_path);
            obj.ref_npix_data_2d = sqw_2d_test_object.data.npix;
            obj.ref_s_data_2d = sqw_2d_test_object.data.s;
            obj.ref_e_data_2d = sqw_2d_test_object.data.e;
            
            num_pix = sqw_2d_test_object.data.pix.num_pixels;
            page_size_2d = floor(num_pix/num_pix_pages)*obj.BYTES_PER_PIX;
            obj.pix_with_pages_2d = PixelData(obj.test_sqw_2d_file_path, ...
                page_size_2d);
        end
        
        function delete(obj)
            rmpath(fullfile(obj.this_dir, 'utils'));
            warning(obj.old_warn_state);
        end
        
        function setUp(obj)
            obj.pix_in_memory = copy(obj.pix_in_memory_base);
            obj.pix_with_pages = copy(obj.pix_with_pages_base);
        end
        
        function test_compute_bin_data_correct_output_in_memory_mex_1_thread(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', true, 'threads', 1);
            
            [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_compute_bin_data_correct_output_in_memory_mex_4_threads(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', true, 'threads', 4);
            
            [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_compute_bin_data_correct_output_all_data_in_memory_mex_off(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', false);
            
            [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_compute_bin_data_correct_output_file_backed_mex_1_thread(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', true, 'threads', 1);
            
            [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_compute_bin_data_correct_output_5_pages_mex_1_thread(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', true, 'threads', 1);
            
            file_info = dir(obj.test_sqw_file_path);
            pg_size = file_info.bytes/5;
            pix = PixelData(obj.test_sqw_file_path, pg_size);
            [s, e] = pix.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_compute_bin_data_correct_output_file_backed_mex_4_threads(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', true, 'threads', 4);
            
            [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_compute_bin_data_file_backed_2d_data_mex_4_threads(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', true, 'threads', 4);
            
            [s, e] = obj.pix_with_pages_2d.compute_bin_data(obj.ref_npix_data_2d);
            persistent all_max;
            if isempty(all_max)
                try
                    all_max = @(x)max(x,[],'all');
                    mm = all_max(1:10);
                catch
                    all_max = @(x)max(reshape(x,[1,numel(x)]));
                end
            end
            
            % Scale the signal and error to account for rounding errors
            max_s = all_max(s);
            scaled_s = s/max_s;
            scaled_ref_s = obj.ref_s_data_2d/max_s;
            
            max_e = all_max(e);
            scaled_e = e/max_e;
            scaled_ref_e = obj.ref_e_data_2d/max_e;
            
            assertEqual(scaled_s, scaled_ref_s, '', obj.FLOAT_TOLERANCE);
            assertEqual(scaled_e, scaled_ref_e, '', obj.FLOAT_TOLERANCE);
            
        end
        
        function test_compute_bin_data_correct_output_file_backed_mex_off(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', false);
            
            [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);
            
            assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
            assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
        end
        
        function test_compute_bin_data_mex_rets_empty_arrays_if_num_pix_is_zero(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', true);
            
            p = PixelData();
            [s, e] = p.compute_bin_data([]);
            
            assertTrue(isempty(s));
            assertTrue(isempty(e));
        end
        
        function test_compute_bin_data_nomex_empty_arrays_if_npix_is_zero(obj)
            cleanup_handle = ...
                set_temporary_config_options(hor_config(), 'use_mex', false);
            
            p = PixelData();
            [s, e] = p.compute_bin_data([]);
            
            assertTrue(isempty(s));
            assertTrue(isempty(e));
        end
        
        function test_do_unary_op_returns_correct_output_with_cosine_gt_1_page(obj)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 50);
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
                % Use the formulas used in sqw.cos to get the expected sig/var data
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
        
        function test_do_unary_op_with_nargout_1_doesnt_affect_called_instance(obj)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 10);
            pix = PixelData(data);
            sin_pix = pix.do_unary_op(@sin);
            assertEqual(pix.data, data);
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
                
                data = obj.get_random_data_in_range( ...
                    PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix, data_range);
                pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
                pix.do_unary_op(unary_op);
                
                file_backed_data = concatenate_pixel_pages(pix);
                
                pix_in_mem = PixelData(data);
                pix_in_mem = pix_in_mem.do_unary_op(unary_op);
                in_memory_data = pix_in_mem.data;
                
                assertEqual( ...
                    file_backed_data, in_memory_data, ...
                    sprintf(['In-memory and file-backed data do not match after ' ...
                    'operation: ''%s''.'], char(unary_op)), ...
                    obj.FLOAT_TOLERANCE);
            end
        end
        
        function test_mask_does_nothing_if_mask_array_eq_ones_when_pix_in_memory(~)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 11);
            pix = PixelData(data);
            mask_array = ones(1, pix.num_pixels);
            pix_out = pix.mask(mask_array);
            assertEqual(pix_out.data, data);
        end
        
        function test_mask_returns_empty_PixelData_if_mask_array_all_zeros(~)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 11);
            pix = PixelData(data);
            mask_array = zeros(1, pix.num_pixels);
            pix_out = pix.mask(mask_array);
            assertTrue(isa(pix_out, 'PixelData'));
            assertTrue(isempty(pix_out));
        end
        
        function test_mask_raises_if_mask_array_len_neq_to_pg_size_or_num_pixels(obj)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 30);
            npix_in_page = 10;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            mask_array = zeros(5);
            f = @() pix.mask(mask_array);
            assertExceptionThrown(f, 'PIXELDATA:mask');
        end
        
        function test_mask_removes_in_memory_pix_if_len_mask_array_eq_num_pixels(~)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 11);
            pix = PixelData(data);
            mask_array = ones(1, pix.num_pixels);
            pix_to_remove = [3, 6, 7];
            mask_array(pix_to_remove) = 0;
            
            pix = pix.mask(mask_array);
            
            assertEqual(pix.num_pixels, size(data, 2) - numel(pix_to_remove));
            expected_data = data;
            expected_data(:, pix_to_remove) = [];
            assertEqual(pix.data, expected_data);
        end
        
        function test_mask_throws_PIXELDATA_if_called_with_no_output_args(~)
            pix = PixelData(5);
            f = @() pix.mask(zeros(1, pix.num_pixels), 'logical');
            assertExceptionThrown(f, 'PIXELDATA:mask');
        end
        
        function test_mask_deletes_pixels_when_given_npix_argument_pix_in_pages(obj)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            mask_array = [0, 1, 1, 0, 1, 0];
            npix = [4, 5, 1, 2, 3, 5];
            
            pix = pix.mask(mask_array, npix);
            
            full_mask_array = repelem(mask_array, npix);
            expected_data = data(:, logical(full_mask_array));
            
            actual_data = concatenate_pixel_pages(pix);
            assertEqual(actual_data, expected_data);
        end
        
        function test_mask_deletes_pix_with_npix_argument_all_pages_full(obj)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 10;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            
            mask_array = [0, 1, 1, 0, 1, 0];
            npix = [4, 5, 1, 2, 3, 5];
            
            pix = pix.mask(mask_array, npix);
            
            full_mask_array = repelem(mask_array, npix);
            expected_data = data(:, logical(full_mask_array));
            
            actual_data = concatenate_pixel_pages(pix);
            assertEqual(actual_data, expected_data);
        end
        
        function test_mask_deletes_pixels_when_given_npix_argument_pix_in_mem(obj)
            data = rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            pix = PixelData(data, obj.ALL_IN_MEM_PG_SIZE);
            
            mask_array = [0, 1, 1, 0, 1, 0];
            npix = [4, 5, 1, 2, 3, 5];
            
            pix = pix.mask(mask_array, npix);
            
            full_mask_array = repelem(mask_array, npix);
            expected_data = data(:, logical(full_mask_array));
            
            actual_data = concatenate_pixel_pages(pix);
            assertEqual(actual_data, expected_data);
        end
        
        function test_PIXELDATA_thrown_if_sum_of_npix_ne_to_num_pixels(~)
            pix = PixelData(5);
            npix = [1, 2];
            f = @() pix.mask([0, 1], npix);
            assertExceptionThrown(f, 'PIXELDATA:mask');
        end
        
        function test_error_if_passing_mask_npix_and_num_pix_len_mask_array(~)
            
            function out = f()
                num_pix = 10;
                pix = PixelData(rand(PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix));
                mask_array = randi([0, 1], [1, num_pix]);
                npix = rand(1, 4);
                out = pix.mask(mask_array, npix);
            end
            
            assertExceptionThrown(@() f(), 'PIXELDATA:mask');
        end
        
        function test_not_enough_args_error_if_calling_mask_with_no_args(~)
            
            function pix = f()
                pix = PixelData(rand(PixelData.DEFAULT_NUM_PIX_FIELDS, 10));
                pix = pix.mask();
            end
            
            assertExceptionThrown(@() f(), 'MATLAB:minrhs');
        end
        
        function test_PixelData_and_raw_arrays_are_not_equal_to_tol(~)
            raw_array = zeros(PixelData.DEFAULT_NUM_PIX_FIELDS, 10);
            pix = PixelData(raw_array);
            [ok, ~] = pix.equal_to_tol(raw_array);
            assertFalse(ok);
        end
        
        function test_equal_to_tol_err_msg_contains_argument_classes(~)
            raw_array = zeros(PixelData.DEFAULT_NUM_PIX_FIELDS, 10);
            pix = PixelData(raw_array);
            [~, mess] = pix.equal_to_tol(raw_array);
            assertTrue(contains(mess, 'PixelData'));
            assertTrue(contains(mess, 'double'));
        end
        
        function test_equal_to_tol_is_false_for_objects_with_unequal_num_pixels(~)
            data = zeros(PixelData.DEFAULT_NUM_PIX_FIELDS, 10);
            pix1 = PixelData(data);
            pix2 = PixelData(data(:, 1:9));
            assertFalse(pix1.equal_to_tol(pix2));
        end
        
        function test_equal_to_tol_true_if_PixelData_objects_contain_same_data(~)
            data = ones(PixelData.DEFAULT_NUM_PIX_FIELDS, 10);
            pix1 = PixelData(data);
            pix2 = PixelData(data);
            assertTrue(pix1.equal_to_tol(pix2));
            assertTrue(pix2.equal_to_tol(pix1));
        end
        
        function test_equal_to_tol_true_if_pixels_paged_and_contain_same_data(obj)
            data = ones(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 10;
            pix1 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix2 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            assertTrue(pix1.equal_to_tol(pix2));
            assertTrue(pix2.equal_to_tol(pix1));
        end
        
        function test_equal_to_tol_true_if_pixels_differ_less_than_tolerance(obj)
            data = ones(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 10;
            tol = 0.1;
            pix1 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix2 = obj.get_pix_with_fake_faccess(data - (tol - 0.01), npix_in_page);
            assertTrue(pix1.equal_to_tol(pix2, tol));
            assertTrue(pix2.equal_to_tol(pix1, tol));
        end
        
        function test_equal_to_tol_false_if_pix_paged_and_contain_unequal_data(obj)
            data = ones(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            data2 = data;
            data2(11) = 0.9;
            npix_in_page = 10;
            
            pix1 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix2 = obj.get_pix_with_fake_faccess(data2, npix_in_page);
            assertFalse(pix1.equal_to_tol(pix2));
            assertFalse(pix2.equal_to_tol(pix1));
        end
        
        function test_equal_to_tol_true_if_only_1_arg_paged_but_data_is_equal(obj)
            data = ones(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 6;
            
            pix1 = PixelData(data);
            pix2 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            assertTrue(pix1.equal_to_tol(pix2));
            assertTrue(pix2.equal_to_tol(pix1));
        end
        
        function test_equal_to_tol_false_if_only_1_arg_paged_and_data_not_equal(obj)
            data = ones(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 6;
            
            pix1 = PixelData(data);
            pix2 = obj.get_pix_with_fake_faccess(data - 1, npix_in_page);
            assertFalse(pix1.equal_to_tol(pix2));
            assertFalse(pix2.equal_to_tol(pix1));
        end
        
        function test_equal_to_tol_throws_if_paged_pix_but_page_sizes_not_equal(obj)
            data = ones(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            data2 = data;
            npix_in_page = 10;
            
            pix1 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix2 = obj.get_pix_with_fake_faccess(data2, npix_in_page - 1);
            f = @() pix1.equal_to_tol(pix2);
            assertExceptionThrown(f, 'PIXELDATA:equal_to_tol');
        end
        
        function test_equal_to_tol_true_when_comparing_NaNs_if_nan_equal_true(~)
            data = ones(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            data(:, [5, 10, 15]) = nan;
            pix1 = PixelData(data);
            pix2 = PixelData(data);
            
            assertTrue(pix1.equal_to_tol(pix2, 'nan_equal', true));
        end
        
        function test_equal_to_tol_false_when_comparing_NaNs_if_nan_equal_false(~)
            data = ones(PixelData.DEFAULT_NUM_PIX_FIELDS, 20);
            data(:, [5, 10, 15]) = nan;
            pix1 = PixelData(data);
            pix2 = PixelData(data);
            
            assertFalse(pix1.equal_to_tol(pix2, 'nan_equal', false));
        end
        
        % -- Helpers --
        function pix = get_pix_with_fake_faccess(obj, data, npix_in_page)
            faccess = FakeFAccess(data);
            pix = PixelData(faccess, npix_in_page*obj.BYTES_PER_PIX);
        end
        
    end
    
    methods (Static)
        
        function data = get_random_data_in_range(cols, rows, data_range)
            data = data_range(1) + (data_range(2) - data_range(1)).*rand(cols, rows);
        end
        
    end
    
end
