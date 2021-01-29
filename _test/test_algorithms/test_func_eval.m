classdef test_func_eval < TestCase

    properties (Constant)
        FLOAT_TOL = 1e-5;
    end

    properties
        sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw'
        sqw_1d_file_path = '../test_sqw_file/sqw_1d_1.sqw'
        sqw_2d;

        quadratic = @(x1, x2, a, b, c) a*x1.^2 + b*x1 + c + a*x2.^2 + b*x2;
        quadratic_params = {2, 3, 6};
        % Reference data for the final row of the expected output image signal
        final_img_signal_row = [...
            4.0150, 4.0238, 4.0342, 4.0462, 4.0598, 4.0750, 4.0918, ...
            4.1102, 4.1302, 4.1518, 4.1750 ...
        ];
    end

    methods
        function obj = test_func_eval(~)
            obj = obj@TestCase('test_func_eval');
            obj.sqw_2d = sqw(obj.sqw_2d_file_path);
        end

        %% Input validation
        function test_SQW_error_if_func_handle_arg_is_not_a_function_handle(obj)
            sqw_in = sqw();
            f = @() func_eval(sqw_in, 'not_a_handle', obj.quadratic_params);
            assertExceptionThrown(f, 'SQW:func_eval:invalid_argument');
        end

        function test_SQW_error_applying_func_eval_to_0D_sqw(obj)
            sqw_in = sqw();
            f = @() func_eval(sqw_in, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'SQW:func_eval:zero_dim_object');
        end

        function test_SQW_error_if_sqws_in_array_have_different_dimensions(obj)
            sqws_in = [sqw(obj.sqw_1d_file_path), obj.sqw_2d];
            f = @() func_eval(sqws_in, obj.quadratic, obj.quadratic_params);
            assertExceptionThrown(f, 'SQW:func_eval:unequal_dims');
        end

        function test_SQW_error_if_num_input_objects_ne_to_num_outfiles(obj)
            sqws_in = [obj.sqw_2d, obj.sqw_2d];
            outfile = 'some_path';

            f = @() func_eval( ...
                sqws_in, obj.quadratic, obj.quadratic_params, 'outfile', outfile ...
            );
            assertExceptionThrown(f, 'SQW:func_eval:invalid_arguments');
        end

        %% In memory execution
        function test_applying_func_eval_to_sqw_object_returns_correct_sqw_data(obj)
            sqw_out = func_eval(obj.sqw_2d, obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row ...
            );
            obj.validate_func_eval_output(obj.sqw_2d, sqw_out);
        end

        function test_func_eval_on_array_of_sqw_objects_returns_correct_sqw_data(obj)
            sqws_in = repmat(obj.sqw_2d, [2, 3]);

            sqws_out = func_eval(sqws_in, obj.quadratic, obj.quadratic_params);

            assertEqual(size(sqws_out), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertElementsAlmostEqual( ...
                    sqws_out(i).data.s(end, :), ...
                    obj.final_img_signal_row ...
                );
                obj.validate_func_eval_output(obj.sqw_2d, sqws_out(i));
            end
        end

        %% File-backed operation
        function test_applying_func_eval_to_an_sqw_file_returns_correct_sqw_data(obj)
            sqw_out = func_eval(obj.sqw_2d, obj.quadratic, obj.quadratic_params);

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row ...
            );

            obj.validate_func_eval_output(obj.sqw_2d, sqw_out);
        end

        function test_applying_func_eval_to_sqw_obj_with_outfile_outputs_to_file(obj)
            pars = obj.quadratic_params;
            outfile = obj.get_tmp_file_path();
            func_eval( ...
                obj.sqw_2d_file_path, ...
                obj.quadratic, ...
                pars, ...
                'outfile', outfile ...
            );
            tmp_file_cleanup = @() clean_up_file(outfile);

            assertTrue(logical(exist(outfile, 'file')));

            sqw_out = sqw(outfile);
            assertEqualToTol( ...
                sqw_out.data.s(end, :), ...
                obj.final_img_signal_row, ...
                'reltol', obj.FLOAT_TOL ...
            );
            obj.validate_func_eval_output(obj.sqw_2d, sqw_out);
        end

        function test_you_can_apply_func_eval_to_cell_array_of_sqw_files(obj)
        end

        function test_you_can_apply_func_eval_to_mix_of_sqw_objects_and_files(obj)
        end

        function test_you_can_apply_func_eval_to_a_dnd_object(obj)
        end

        function test_you_can_apply_func_eval_to_array_of_dnd_objects(obj)
        end

        function test_you_can_apply_func_eval_to_a_dnd_file(obj)
        end

        function test_you_can_apply_func_eval_to_a_cell_array_of_dnd_file(obj)
        end

        function test_you_can_apply_func_eval_to_sqw_with_file_backed_pix(obj)
        end

        function test_you_can_apply_func_eval_on_out_of_memory_data(obj)
        end
    end

    methods (Static)
        function validate_func_eval_output(sqw_in, sqw_out)
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

        function tmp_file_path = get_tmp_file_path()
            % Get a temporary file path, with file name the name of the caller
            % function.
            % This indicates where the tmp file originated from and makes sure
            % tmp files have unique if tests are run in parallel.
            call_stack = dbstack();
            caller_name = call_stack(2).name;
            tmp_file_path = fullfile(tmp_dir(), [caller_name, '.tmp']);
        end
    end

end
