classdef test_func_eval < TestCase

    properties
        sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw'
        sqw_1d_file_path = '../test_sqw_file/sqw_1d_1.sqw'
    end

    methods
        function test_you_apply_func_eval_to_an_sqw_object(obj)
            sqw_in = sqw(obj.sqw_2d_file_path);

            func = @(x1, x2, a, b, c) a*x1.^2 + b*x1 + c + a*x2.^2 + b*x2;
            pars = {2, 3, 6};
            sqw_out = func_eval(sqw_in, func, pars);

            assertElementsAlmostEqual( ...
                sqw_out.data.s(end, :), ...
                [4.0150, 4.0238, 4.0342, 4.0462, 4.0598, 4.0750, 4.0918, ...
                 4.1102, 4.1302, 4.1518, 4.1750] ...
            );
            obj.validate_func_eval_output(sqw_in, sqw_out);
        end

        function test_you_can_apply_func_eval_to_array_of_sqw_objects(obj)
            sqw_in = sqw(obj.sqw_2d_file_path);
            sqws_in = repmat(sqw_in, [2, 3]);

            func = @(x1, x2, a, b, c) a*x1.^2 + b*x1 + c + a*x2.^2 + b*x2;
            pars = {2, 3, 6};
            sqws_out = func_eval(sqws_in, func, pars);

            assertEqual(size(sqws_out), size(sqws_in));
            for i = 1:numel(sqws_in)
                assertElementsAlmostEqual( ...
                sqws_out(i).data.s(end, :), ...
                    [4.0150, 4.0238, 4.0342, 4.0462, 4.0598, 4.0750, 4.0918, ...
                     4.1102, 4.1302, 4.1518, 4.1750] ...
                );
                obj.validate_func_eval_output(sqw_in, sqws_out(i));
            end
        end

        function test_SQW_error_if_sqws_in_array_have_different_dimensions(obj)
            sqws_in = [sqw(obj.sqw_1d_file_path), sqw(obj.sqw_2d_file_path)];

            func = @(x1, x2, a, b, c) a*x1.^2 + b*x1 + c + a*x2.^2 + b*x2;
            pars = {2, 3, 6};
            f = @() func_eval(sqws_in, func, pars);
            assertExceptionThrown(f, 'SQW:func_eval');
        end

        function test_you_can_apply_func_eval_to_an_sqw_file(obj)
        end

        function test_you_can_apply_func_eval_to_cell_array_of_sqw_files(obj)
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
    end

end
