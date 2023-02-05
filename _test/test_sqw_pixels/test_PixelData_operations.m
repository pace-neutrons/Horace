classdef test_PixelData_operations < TestCase & common_pix_class_state_holder

    properties
        BYTES_PER_PIX = 4*PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
        ALL_IN_MEM_PG_SIZE = 1e12;
        FLOAT_TOLERANCE = 4.75e-4;
    end

    methods

        function obj = test_PixelData_operations(~)
            obj = obj@TestCase('test_PixelData_operations');
        end

        function test_do_unary_op_returns_correct_output_with_cosine_gt_1_page(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')                                                            
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 50);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

            pix = pix.do_unary_op(@cos);
            % Loop back through and validate values

            file_backed_data = pix.get_all_prop('all');
            expected_data = data;
            expected_data(obj.SIGNAL_IDX, :) = ...
                cos(expected_data(obj.SIGNAL_IDX, :));

            expected_data(obj.VARIANCE_IDX, :) = ...
                abs(1 - expected_data(obj.SIGNAL_IDX, :).^2) .* ...
                expected_data(obj.VARIANCE_IDX, :);

            assertEqual(file_backed_data, expected_data, '', obj.FLOAT_TOLERANCE);

        end

        function test_do_unary_op_with_nargout_1_doesnt_affect_called_instance(~)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix = PixelDataBase.create(data);
            sin_pix = pix.do_unary_op(@sin);
            assertEqual(pix.data, data);
        end

        function test_paged_data_returns_same_unary_op_result_as_all_in_memory(obj)
            % the unary operation and the range the data it acts on should take
            skipTest('Re #928 THIS filebacked pixels operations have to be fixed')                                                            
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
                @cot, [0.1, 1], ...
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
                @tanh, [0, 3], ...
                };

            % For each unary operator, perform the operation on some file-backed
            % data and compare the result to the same operation used on the same
            % data all held in memory
            num_pix = 7;
            npix_in_page = 3;
            for i = 1:2:numel(unary_ops)
                unary_op = unary_ops{i};
                data_range = unary_ops{i+1};

                data = get_random_data_in_range( ...
                    PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix, data_range);
                pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
                pix.do_unary_op(unary_op);

                file_backed_data = pix.data;

                pix_in_mem = PixelDataBase.create(data);
                pix_in_mem = pix_in_mem.do_unary_op(unary_op);
                in_memory_data = pix_in_mem.data;

                assertElementsAlmostEqual( ...
                    file_backed_data, in_memory_data, ...
                    'relative',1e-4,... % Due to single precision errors
                    sprintf(['In-memory and file-backed data do not match after ' ...
                    'operation: ''%s''.'], char(unary_op)) );
            end
        end

        function test_mask_does_nothing_if_mask_array_eq_ones_when_pix_in_memory(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 11);
            ref_range = obj.get_ref_range(data);
            pix = PixelDataBase.create(data);
            mask_array = ones(1, pix.num_pixels);
            pix_out = pix.mask(mask_array);
            assertEqual(pix_out.data, data);
            assertEqual(pix_out.pix_range,ref_range);
        end

        function test_mask_returns_empty_PixelData_if_mask_array_all_zeros(~)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 11);
            pix = PixelDataMemory(data);
            mask_array = zeros(1, pix.num_pixels);
            pix_out = pix.mask(mask_array);
            assertTrue(isa(pix_out, 'PixelDataBase'));
            assertEqual(pix_out.num_pixels,0);
            assertEqual(pix_out.data_range,PixelDataBase.EMPTY_RANGE);
        end

        function test_mask_raises_if_mask_array_len_neq_to_pg_size_or_num_pixels(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')                                                
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 30);
            npix_in_page = 10;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            mask_array = zeros(5);
            f = @() pix.mask(mask_array);
            assertExceptionThrown(f, 'PIXELDATA:mask');
        end

        function test_mask_removes_in_memory_pix_if_len_mask_array_eq_num_pixels(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 11);
            pix = PixelDataBase.create(data);

            mask_array = ones(1, pix.num_pixels);
            pix_to_remove = [3, 6, 7];
            mask_array(pix_to_remove) = 0;
            ref_ds = data(:,logical(mask_array));
            ref_range = obj.get_ref_range(ref_ds);

            pix = pix.mask(mask_array);

            assertEqual(pix.num_pixels, size(data, 2) - numel(pix_to_remove));
            expected_data = data;
            expected_data(:, pix_to_remove) = [];
            assertEqual(pix.data, expected_data);
            assertEqual(pix.pix_range, ref_range);
        end

        function test_mask_throws_PIXELDATA_if_called_with_no_output_args(~)
            pix = PixelDataMemory(5);
            f = @() pix.mask(zeros(1, pix.num_pixels), 'logical');
            assertExceptionThrown(f, 'HORACE:PixelDataMemory:invalid_argument');
        end

        function test_mask_deletes_pixels_when_given_npix_argument_pix_in_pages(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')                                    
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 11;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

            mask_array = [0, 1, 1, 0, 1, 0];
            npix = [4, 5, 1, 2, 3, 5];

            pix = pix.mask(mask_array, npix);

            full_mask_array = repelem(mask_array, npix);
            expected_data = data(:, logical(full_mask_array));
            ref_range = obj.get_ref_range(expected_data);

            actual_data = pix.get_all_prop('all');
            assertElementsAlmostEqual(actual_data, expected_data,'relative',4e-8);
            assertElementsAlmostEqual(pix.pix_range, ref_range,'relative',4e-8);
        end

        function test_mask_deletes_pix_with_npix_argument_all_pages_full(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')                                    
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 10;
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

            mask_array = [0, 1, 1, 0, 1, 0];
            npix = [4, 5, 1, 2, 3, 5];

            pix = pix.mask(mask_array, npix);

            full_mask_array = repelem(mask_array, npix);
            expected_data = data(:, logical(full_mask_array));
            ref_range = obj.get_ref_range(expected_data);

            actual_data = pix.get_pixels(1:pix.num_pixels).data;
            assertElementsAlmostEqual(actual_data, expected_data,'relative',4e-8);
            assertElementsAlmostEqual(pix.pix_range, ref_range,'relative',4e-8);
        end

        function test_mask_deletes_pixels_when_given_npix_argument_pix_in_mem(obj)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            pix = PixelDataBase.create(data);

            mask_array = [0, 1, 1, 0, 1, 0];
            npix = [4, 5, 1, 2, 3, 5];

            pix = pix.mask(mask_array, npix);

            full_mask_array = repelem(mask_array, npix);
            expected_data = data(:, logical(full_mask_array));
            ref_range = obj.get_ref_range(expected_data);

            actual_data = pix.get_pixels(1:pix.num_pixels).data;
            assertEqual(actual_data, expected_data);
            assertEqual(pix.pix_range, ref_range);

        end

        function test_PIXELDATA_thrown_if_sum_of_npix_ne_to_num_pixels(~)
            pix = PixelDataMemory(5);
            npix = [1, 2];
            f = @() pix.mask([0, 1], npix);
            assertExceptionThrown(f, 'HORACE:PixelDataMemory:invalid_argument');
        end

        function test_error_if_passing_mask_npix_and_num_pix_len_mask_array(~)

            function out = f()
                num_pix = 10;
                pix = PixelDataMemory(rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix));
                mask_array = randi([0, 1], [1, num_pix]);
                npix = rand(1, 4);
                out = pix.mask(mask_array, npix);
            end

            assertExceptionThrown(@() f(), 'HORACE:PixelDataMemory:invalid_argument');
        end

        function test_not_enough_args_error_if_calling_mask_with_no_args(~)

            function pix = f()
                pix = PixelDataBase.create(rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10));
                pix = pix.mask();
            end

            assertExceptionThrown(@() f(), 'MATLAB:minrhs');
        end

        function test_PixelData_and_raw_arrays_are_not_equal_to_tol(~)
            raw_array = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix = PixelDataBase.create(raw_array);
            [ok, ~] = equal_to_tol(pix, raw_array);
            assertFalse(ok);
        end

        function test_equal_to_tol_err_msg_contains_argument_classes(~)
            raw_array = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix = PixelDataBase.create(raw_array);
            [~, mess] = equal_to_tol(pix, raw_array);
            assertTrue(contains(mess, 'PixelData'));
            assertTrue(contains(mess, 'double'));
        end

        function test_equal_to_tol_is_false_for_objects_with_unequal_num_pixels(~)
            data = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix1 = PixelDataBase.create(data);
            pix2 = PixelDataBase.create(data(:, 1:9));
            assertFalse(equal_to_tol(pix1, pix2));
        end

        function test_equal_to_tol_true_if_PixelData_objects_contain_same_data(~)
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
            pix1 = PixelDataBase.create(data);
            pix2 = PixelDataBase.create(data);
            assertTrue(equal_to_tol(pix1, pix2));
            assertTrue(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_true_if_pixels_paged_and_contain_same_data(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')                        
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 10;
            pix1 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix2 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            assertTrue(equal_to_tol(pix1, pix2));
            assertTrue(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_true_if_pixels_differ_less_than_tolerance(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')                        
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 10;
            tol = 0.1;
            pix1 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix2 = obj.get_pix_with_fake_faccess(data - (tol - 0.01), npix_in_page);
            assertTrue(equal_to_tol(pix1, pix2, tol));
            assertTrue(equal_to_tol(pix2, pix1, tol));
        end

        function test_equal_to_tol_false_if_pix_paged_and_contain_unequal_data(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')                        
            
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            data2 = data;
            data2(11) = 0.9;
            npix_in_page = 10;

            pix1 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix2 = obj.get_pix_with_fake_faccess(data2, npix_in_page);
            assertFalse(equal_to_tol(pix1, pix2));
            assertFalse(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_true_if_only_1_arg_paged_but_data_is_equal(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')                        
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 6;

            pix1 = PixelDataBase.create(data);
            pix2 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            assertTrue(equal_to_tol(pix1, pix2));
            assertTrue(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_false_if_only_1_arg_paged_and_data_not_equal(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')            
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            npix_in_page = 6;

            pix1 = PixelDataBase.create(data);
            pix2 = obj.get_pix_with_fake_faccess(data - 1, npix_in_page);
            assertFalse(equal_to_tol(pix1, pix2));
            assertFalse(equal_to_tol(pix2, pix1));
        end

        function test_equal_to_tol_throws_if_paged_pix_but_page_sizes_not_equal(obj)
            skipTest('Re #928 THIS DOES NOT LOOK LIKE RELEVANT TO NEW CONCEPT. TODO: clarify')

            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            data2 = data;
            npix_in_page = 5;

            pix1 = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix2 = obj.get_pix_with_fake_faccess(data2, npix_in_page - 1);

            assertFalse(equal_to_tol(pix1, pix2));
        end

        function test_equal_to_tol_true_when_comparing_NaNs_if_nan_equal_true(~)
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            data(:, [5, 10, 15]) = nan;
            pix1 = PixelDataBase.create(data);
            pix2 = PixelDataBase.create(data);

            assertTrue(equal_to_tol(pix1, pix2, 'nan_equal', true));
        end

        function test_equal_to_tol_false_when_comparing_NaNs_if_nan_equal_false(~)
            data = ones(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 20);
            data(:, [5, 10, 15]) = nan;
            pix1 = PixelDataBase.create(data);
            pix2 = PixelDataBase.create(data);

            assertFalse(equal_to_tol(pix1, pix2, 'nan_equal', false));
        end

    end

    methods (Static)
        % -- Helpers --
        function [pix,pix_range] = get_pix_with_fake_faccess(data, npix_in_page)
            pix_range = [min(data(1:4,:),[],2),max(data(1:4,:),[],2)]';
            faccess = FakeFAccess(data);
            % give it a real file path to trick code into thinking it exists
            faccess = faccess.set_filepath('fake_file');
            mem_alloc = npix_in_page;
            pix = PixelDataFileBacked(faccess, mem_alloc);
        end

        function ref_range = get_ref_range(data)
            ref_range = [
                min(data(1:4, :),[],2),...
                max(data(1:4, :),[],2)]';
        end
    end

end
