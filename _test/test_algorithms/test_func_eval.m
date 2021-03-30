classdef test_func_eval < TestCase

    properties (Constant)
        FLOAT_TOL = 1e-5;
    end

    properties
        old_warn_state;

        d2d_file_path = '../test_symmetrisation/w2d_qq_small_d2d.sqw'
        d2d_obj;
        sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw'
        sqw_1d_file_path = '../test_sqw_file/sqw_1d_1.sqw'
        sqw_2d_obj;

        quadratic = @(x1, x2, a, b, c) a*x1.^2 + b*x1 + c + a*x2.^2 + b*x2;
        quadratic_params = {2, 3, 6};
        % Reference data for the final row of the expected output image signal
        final_img_signal_row_sqw_2d = [...
            4.0150, 4.0238, 4.0342, 4.0462, 4.0598, 4.0750, 4.0918, ...
            4.1102, 4.1302, 4.1518, 4.1750 ...
        ];
        final_img_signal_row_dnd = [ ...
            7.5200, 7.5962, 7.6750, 7.7562, 7.8400, 7.9262, 8.0150, 8.1062, ...
            8.2000, 8.2962, 8.3950, 8.4962, 8.6000, 8.7062, 8.8150, 8.9262, ...
            9.0400
        ];
    end

    methods
        function obj = test_func_eval(~)
            obj = obj@TestCase('test_func_eval');
            obj.d2d_obj = d2d(obj.d2d_file_path);
            obj.sqw_2d_obj = sqw(obj.sqw_2d_file_path);

            obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');
        end

        function delete(obj)
            warning(obj.old_warn_state);
        end

        %% Input validation
        function test_SQW_error_if_func_handle_arg_is_not_a_function_handle(obj)
            sqw_in = sqw();
            f = @() func_eval(sqw_in, 'not_a_handle', obj.quadratic_params);
            assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
        end

        function test_SQW_error_applying_func_eval_to_0D_sqw(obj)
            sqw_in = sqw();
            f = @() func_eval(sqw_in, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'SQW:func_eval:zero_dim_object');
        end

        function test_SQW_error_if_sqws_in_array_have_different_dimensions(obj)
            sqws_in = [sqw(obj.sqw_1d_file_path), obj.sqw_2d_obj];
            f = @() func_eval(sqws_in, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'SQW:func_eval:unequal_dims');
        end

        function test_SQW_error_if_num_input_objects_gt_num_outfiles(obj)
            sqws_in = [obj.sqw_2d_obj, obj.sqw_2d_obj];
            outfile = 'some_path';

            f = @() func_eval( ...
                sqws_in, obj.quadratic, obj.quadratic_params, 'outfile', outfile ...
            );
            assertExceptionThrown(f, 'SQW:func_eval:invalid_arguments');
        end

        function test_SQW_error_if_num_input_objects_lt_num_outfiles(obj)
            sqws_in = obj.sqw_2d_obj;
            outfiles = {'some_path', 'some_other_path'};

            f = @() func_eval( ...
                sqws_in, obj.quadratic, obj.quadratic_params, 'outfile', outfiles ...
            );
            assertExceptionThrown(f, 'SQW:func_eval:invalid_arguments');
        end

        function test_error_raised_if_func_eval_called_with_mix_of_sqw_and_dnd(obj)
            inputs = {obj.sqw_2d_obj, d2d(obj.sqw_2d_obj)};
            f = @() func_eval(inputs, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'HORACE:func_eval:input_type_error');
        end

        function test_error_if_func_eval_input_arrays_within_a_cell_array(obj)
            inputs = {[obj.sqw_2d_obj, obj.sqw_2d_obj], obj.sqw_2d_file_path};
            f = @() func_eval(inputs, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'HORACE:func_eval:too_many_elements');
        end

        function test_error_raised_if_filebacked_arg_not_scalar_logical(obj)
            invalid_vals = {'not-a-logical', [true, false, true], 2};
            for i = 1:numel(invalid_vals)
                f = @() func_eval( ...
                    obj.sqw_2d_file_path, obj.quadratic, obj.quadratic_params, ...
                    'filebacked', invalid_vals{i} ...
                );
                assertExceptionThrown(f, 'MATLAB:InputParser:ArgumentFailedValidation');
            end
        end

        %% SQW tests
        function test_applying_func_eval_to_sqw_object_returns_correct_sqw_data(obj)
            sqw_out = obj.sqw_2d_obj.func_eval(obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d ...
            );
            obj.validate_func_eval_sqw_output(obj.sqw_2d_obj, sqw_out);
        end

        function test_func_eval_on_array_of_sqw_objects_returns_correct_sqw_data(obj)
            sqws_in = repmat(obj.sqw_2d_obj, [2, 3]);

            sqws_out = func_eval(sqws_in, obj.quadratic, obj.quadratic_params);

            assertEqual(size(sqws_out), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertElementsAlmostEqual( ...
                    sqws_out(i).data.s(end, :), ...
                    obj.final_img_signal_row_sqw_2d ...
                );
                obj.validate_func_eval_sqw_output(obj.sqw_2d_obj, sqws_out(i));
            end
        end

        function test_func_eval_on_array_of_sqw_objs_with_cell_arr_of_outfiles(obj)
            sqws_in = [obj.sqw_2d_obj, obj.sqw_2d_obj];
            outfiles = {obj.get_tmp_file_path('1'), obj.get_tmp_file_path('2')};
            tmp_file_cleanup = onCleanup(@() cellfun(@(x) clean_up_file(x), outfiles));

            func_eval(sqws_in, obj.quadratic, obj.quadratic_params, 'outfile', outfiles);

            sqws_out = cellfun(@(x) sqw(x), outfiles, 'UniformOutput', false);
            assertEqual(size(sqws_out), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertElementsAlmostEqual( ...
                    sqws_out{i}.data.s(end, :), ...
                    obj.final_img_signal_row_sqw_2d, ...
                    'relative', obj.FLOAT_TOL ...
                );
                obj.validate_func_eval_sqw_output(obj.sqw_2d_obj, sqws_out{i});
            end
        end

        function test_applying_func_eval_to_an_sqw_file_returns_correct_sqw_data(obj)
            sqw_out = func_eval(obj.sqw_2d_obj, obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d ...
            );

            obj.validate_func_eval_sqw_output(obj.sqw_2d_obj, sqw_out);
        end

        function test_applying_func_eval_to_sqw_obj_with_outfile_outputs_to_file(obj)
            outfile = obj.get_tmp_file_path();
            func_eval( ...
                obj.sqw_2d_file_path, ...
                obj.quadratic, ...
                obj.quadratic_params, ...
                'outfile', outfile ...
            );
            tmp_file_cleanup = onCleanup(@() clean_up_file(outfile));

            assertTrue(logical(exist(outfile, 'file')));

            sqw_out = sqw(outfile);
            assertEqualToTol( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d, ...
                'reltol', obj.FLOAT_TOL ...
            );
            obj.validate_func_eval_sqw_output(obj.sqw_2d_obj, sqw_out);
        end

        function test_input_cell_array_of_sqw_files_rets_array_of_sqw(obj)
            sqw_files_in = {obj.sqw_2d_file_path, obj.sqw_2d_file_path};

            sqws_out = func_eval(sqw_files_in, obj.quadratic, obj.quadratic_params);

            assertEqual(size(sqws_out), [1, 2]);
            for i = 1:numel(sqw_files_in)
                obj.validate_func_eval_sqw_output(obj.sqw_2d_obj, sqws_out(i));
            end
        end

        function test_output_file_of_out_of_memory_op_matches_reference_data(obj)
            config_cleanup = set_temporary_config_options( ...
                hor_config, 'pixel_page_size', 3e5 ...
            );
            sqw_out_file = func_eval( ...
                obj.sqw_2d_file_path, obj.quadratic, obj.quadratic_params, ...
                'filebacked', true ...
            );
            tmp_file_cleanup = onCleanup(@() clean_up_file(sqw_out_file));

            assertTrue(isa(sqw_out_file, 'char'));
            sqw_out = sqw(sqw_out_file);
            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d, ...
                'relative', obj.FLOAT_TOL ...
            );
            obj.validate_func_eval_sqw_output(obj.sqw_2d_obj, sqw_out);
        end

        function test_output_files_of_cell_array_of_files_on_out_of_memory_data(obj)
            sqw_files_in = {obj.sqw_2d_file_path, obj.sqw_2d_file_path};
            sqw_out_files = func_eval( ...
                sqw_files_in, obj.quadratic, obj.quadratic_params, ...
                'filebacked', true ...
            );
            tmp_file_cleanup = onCleanup( ...
                @() cellfun(@(x) clean_up_file(x), sqw_out_files) ...
            );

            assertTrue(isa(sqw_out_files, 'cell'));
            for i = 1:numel(sqw_out_files)
                sqw_out = sqw(sqw_out_files{i});
                assertElementsAlmostEqual( ...
                    sqw_out.data.s(end, :), ...
                    obj.final_img_signal_row_sqw_2d, ...
                    'relative', obj.FLOAT_TOL ...
                );
                obj.validate_func_eval_sqw_output(obj.sqw_2d_obj, sqw_out);
            end
        end

        function test_output_on_cell_arr_with_files_and_objects_matches_ref(obj)
            sqws_in = {obj.sqw_2d_file_path, obj.sqw_2d_obj};
            sqws_out = func_eval(sqws_in, obj.quadratic, obj.quadratic_params);

            assertTrue(isa(sqws_out, 'sqw'));
            assertEqual(numel(sqws_out), numel(sqws_in));
            for i = 1:numel(sqws_out)
                assertElementsAlmostEqual( ...
                    sqws_out(i).data.s(end, :), ...
                    obj.final_img_signal_row_sqw_2d, ...
                    'relative', obj.FLOAT_TOL ...
                );
                obj.validate_func_eval_sqw_output(obj.sqw_2d_obj, sqws_out(i));
            end
        end

        function test_outfile_path_equal_to_input_outfile_if_filebacked(obj)
            outfile = obj.get_tmp_file_path();
            sqw_out_file = func_eval( ...
                obj.sqw_2d_file_path, obj.quadratic, obj.quadratic_params, ...
                'filebacked', true, ...
                'outfile', outfile ...
            );
            tmp_file_cleanup = onCleanup(@() clean_up_file(outfile));

            assertEqual(sqw_out_file, outfile)
            assertEqual(exist(sqw_out_file, 'file'), 2);
        end

        function test_npix_all_ones_if_all_flag_given_and_no_pixels(obj)
            sqw_in = obj.sqw_2d_obj;
            sqw_in.data.pix = PixelData();
            sqw_out = func_eval( ...
                sqw_in, obj.quadratic, obj.quadratic_params, '-all' ...
            );

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row_sqw_2d ...
            );
            assertEqual(sqw_out.data.npix, ones(size(obj.sqw_2d_obj.data.npix)));
        end

        %% DnD tests
        function test_applying_func_eval_to_dnd_object_returns_correct_dnd_data(obj)
            dnd_out = func_eval(obj.d2d_obj, obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                dnd_out.s(end, :), ...
                obj.final_img_signal_row_dnd, ...
                'relative', obj.FLOAT_TOL ...
            );
            obj.validate_func_eval_dnd_output(obj.d2d_obj, dnd_out);
        end

        function test_func_eval_on_array_of_dnd_objects_returns_correct_dnd_data(obj)
            d2ds_in = repmat(obj.d2d_obj, [1, 2]);
            d2ds_out = func_eval(d2ds_in, obj.quadratic, obj.quadratic_params);

            assertEqual(size(d2ds_out), size(d2ds_in));
            for i = 1:numel(d2ds_out)
                assertElementsAlmostEqual( ...
                    d2ds_out(i).s(end, :), ...
                    obj.final_img_signal_row_dnd, ...
                    'relative', obj.FLOAT_TOL ...
                );
                obj.validate_func_eval_dnd_output(obj.d2d_obj, d2ds_out(i));
            end
        end

        function test_applying_func_eval_to_a_dnd_file_returns_correct_dnd_data(obj)
            dnd_out = func_eval(obj.d2d_file_path, obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                dnd_out.s(end, :), ...
                obj.final_img_signal_row_dnd, ...
                'relative', obj.FLOAT_TOL ...
            );
            obj.validate_func_eval_dnd_output(obj.d2d_obj, dnd_out);
        end

        function test_func_eval_on_cell_array_of_dnd_files_rets_dnd_array(obj)
            dnds_in = {obj.d2d_file_path, obj.d2d_file_path};
            dnds_out = func_eval(dnds_in, obj.quadratic, obj.quadratic_params);

            assertEqual(size(dnds_out), size(dnds_in));
            for i = 1:numel(dnds_out)
                dnd_out = dnds_out(i);
                assertElementsAlmostEqual( ...
                    dnd_out.s(end, :), ...
                    obj.final_img_signal_row_dnd, ...
                    'relative', obj.FLOAT_TOL ...
                );
                obj.validate_func_eval_dnd_output(obj.d2d_obj, dnd_out);
            end
        end

        function test_for_dnd_input_npix_are_all_ones_if_all_flag_given(obj)
            dnd_out = func_eval( ...
                obj.d2d_obj, obj.quadratic, obj.quadratic_params, '-all' ...
            );

            assertElementsAlmostEqual( ...
                dnd_out.s(end, :), ...
                obj.final_img_signal_row_dnd, ...
                'relative', obj.FLOAT_TOL ...
            );
            assertEqual(dnd_out.npix, ones(size(obj.d2d_obj.npix)));
        end

        function test_for_dnd_input_npix_are_all_ones_if_kwarg_all_is_true(obj)
            dnd_out = func_eval( ...
                obj.d2d_obj, obj.quadratic, obj.quadratic_params, 'all', true ...
            );

            assertElementsAlmostEqual( ...
                dnd_out.s(end, :), ...
                obj.final_img_signal_row_dnd, ...
                'relative', obj.FLOAT_TOL ...
            );
            assertEqual(dnd_out.npix, ones(size(obj.d2d_obj.npix)));
        end
    end

    methods (Static)
        function validate_func_eval_sqw_output(sqw_in, sqw_out)
            % Check output image size is equal to input image size
            assertEqual(size(sqw_out.data.s), size(sqw_in.data.s));
            % Check all output errors are zero with equal size to image
            assertEqual(sqw_out.data.e, zeros(size(sqw_in.data.e)));
            % Check that data.npix is unchanged
            assertEqual(sqw_out.data.npix, sqw_in.data.npix);

            sig_var = sqw_out.data.pix.get_data({'signal', 'variance'});
            % Check that all pixel signals for each bin are equal to the value
            % of the image signal in the corresponding bin
            signal = sig_var(1, :);
            expected_signal = repelem(sqw_out.data.s(:), sqw_out.data.npix(:))';
            assertEqual(signal, expected_signal);

            % Check that all pixel variances are set to zero
            variance = sig_var(2, :);
            assertEqual(variance, zeros(1, sum(sqw_out.data.npix(:))));
        end

        function validate_func_eval_dnd_output(dnd_in, dnd_out)
            % Check output image size is equal to input image size
            assertEqual(size(dnd_in.s), size(dnd_in.s));
            % Check all output errors are zero with equal size to image
            assertEqual(dnd_out.e, zeros(size(dnd_in.e)));
            % Check that data.npix is unchanged
            assertEqual(dnd_out.npix, dnd_in.npix);
        end

        function tmp_file_path = get_tmp_file_path(suffix)
            % Get a temporary file path, with file name the name of the caller
            % function.
            % This indicates where the tmp file originated from and makes sure
            % tmp files have unique if tests are run in parallel.
            if nargin == 0
                suffix = '';
            end
            call_stack = dbstack();
            caller_name = call_stack(2).name;
            tmp_file_path = fullfile(tmp_dir(), [caller_name, suffix, '.tmp']);
        end
    end

end
